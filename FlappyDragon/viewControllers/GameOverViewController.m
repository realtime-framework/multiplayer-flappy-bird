//
//  GameOverViewController.m
//  FlappyDragon
//
//  Created by iOSdev on 11/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "GameOverViewController.h"
#import "GameData.h"
#import "WaitingViewController.h"
#import "AcceptViewController.h"


@interface GameOverViewController ()

@property BOOL gameIsRestarting;
@property DragonChallenge* handlerChallenge;
@property (nonatomic)  AdUnitUIkit *adUnitView;
@end

@implementation GameOverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_iWon = -1;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[_titleLabel setFont:[UIFont fontWithName:@"Floraless" size:18]];
	_titleLabel.minimumScaleFactor = 0.5;
	_titleLabel.adjustsFontSizeToFitWidth = YES;
	_titleLabel.textColor = TEXT_COLOR;
	_titleLabel.shadowColor = TEXT_SHADOW_COLOR;
	_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Do any additional setup after loading the view from its nib.
	_gameIsRestarting = NO;
	
	if (_iWon == 1) {
		[_titleLabel setText:@"You Won!"];
		[[GameData localPlayer] incrementScore:_score :^(NSError *error) {
			if (error == nil) {
				
				[[GameData localPlayer] changeStatus:PLAYER_STATE_WAITING :^(NSError *error) {
					if (error == nil) {
					}
					else {
						//NSLog(@"Error Seting STATUS: %@", [error localizedDescription]);
					}
				}];
			}
			else {
				//NSLog(@"Error Seting SCORE: %@", [error localizedDescription]);
			}
		}];
	}
	else if (_iWon == 0) {
		[_titleLabel setText:@"You Lost!"];
	}
	
	DragonPlayer *localPlayer = [GameData localPlayer];
	
	[localPlayer onChallenge:^(NSString *nickName, NSString *gameId) {
		[GameData getChallenge:[GameData localPlayer].gameId :gameId :^(DragonChallenge *challenge, NSError *error) {
			if (error == nil) {
				AcceptViewController* acceptViewController = [[AcceptViewController alloc] initWithNibName:@"AcceptViewController" bundle:nil];
				acceptViewController.challenge = challenge;
				[AppDelegate transitionToViewController:acceptViewController];
			}
		}];
	}];
    
    _adUnitView = [[AdUnitUIkit alloc] initWithPLaceholder:_imageBanner AndZone:BANNER_Z_ID];
	[WebSpectatorMobile putAdUnit:_adUnitView];

}

-(void)viewDidDisappear:(BOOL)animated {
	
	[super viewDidDisappear:animated];
	[[GameData localPlayer] removeOnChallenge];
    
    [WebSpectatorMobile deleteAdUnit:_adUnitView];
}

#pragma mark - Actions

- (IBAction) restartGame:(id)sender {
	
	if(!_gameIsRestarting) {
		_gameIsRestarting = true;
		
		DragonPlayer *playerA;
		DragonPlayer *playerB;
		
		if ([[[GameData localPlayer] nickname] isEqualToString:self.challenge.playerA.nickname]) {
			playerA = self.challenge.playerA;
			playerB = self.challenge.playerB;
		}
		else {
			playerA = self.challenge.playerB;
			playerB = self.challenge.playerA;
		}
        
        DragonChallenge* challenge = [[DragonChallenge alloc] initWhitPlayers:playerA :playerB];
        [challenge create:^(NSError *error) {
            if (error != nil) {
				//NSLog(@"Error Making Challenge on GAME OVER\nA:\n%@\nB:\n%@\n%@", [challenge.playerA toString], [challenge.playerB toString], [error localizedDescription]);
			}
        }];
        
        WaitingViewController *waitingViewController = [[WaitingViewController alloc] initWithNibName:@"WaitingViewController" bundle:nil];
        waitingViewController.challenge = challenge;
        
        [AppDelegate transitionToViewController:waitingViewController];
	}
}

- (IBAction)close:(id)sender {
	
	[AppDelegate backToRootViewController];
}

@end


