//
//  WatingViewController.m
//  FlappyDragon
//
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "WaitingViewController.h"
#import "GameData.h"
#import "GameViewController.h"
#import "Game.h"

@interface WaitingViewController ()

@property DragonChallenge* handlerChallenge;

@property (nonatomic)  AdUnitUIkit *adUnitView;

@end

@implementation WaitingViewController

NSString* const LABEL_WAITING_TEXT = @"Waiting for player %@ to accept";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString* labelWaitingText = [NSString stringWithFormat:LABEL_WAITING_TEXT, self.challenge.playerB.nickname];
    [self.labelWaiting setText:labelWaitingText];
	[_labelWaiting setFont:[UIFont fontWithName:@"Floraless" size:18]];
	_labelWaiting.minimumScaleFactor = 0.5;
	_labelWaiting.adjustsFontSizeToFitWidth = YES;
	_labelWaiting.textColor = TEXT_COLOR;
	_labelWaiting.shadowColor = TEXT_SHADOW_COLOR;
	_labelWaiting.shadowOffset = CGSizeMake(1.0, 1.0);
    
    [[GameData communication] setOnAction:self];
    
    self.handlerChallenge = [[DragonChallenge alloc] initWhitPlayers:_challenge.playerB :_challenge.playerA];
    [self.handlerChallenge onDelete:^{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Player %@ quit challenge.",self.challenge.playerB.nickname] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
		
		[AppDelegate backToRootViewController];
	}];
    
}

- (void) start:(NSDictionary *)game{
    [GameData currentGame].opponentStartTime = [[game objectForKey:@"startTime"] longLongValue];
}

- (void) startGame {
	
    DragonChallenge* challengeToDelete = [[DragonChallenge alloc] initWhitPlayers:[GameData currentGame].challenge.playerB :[GameData currentGame].challenge.playerA];
    
    
	[challengeToDelete remove:^(NSError *error) {
        if(error != nil){
            //NSLog(@"Error Quit waiting challenge\nA:\n%@\nB:\n%@\n%@", [self.challenge.playerA toString], [self.challenge.playerB toString], [error localizedDescription]);
        }
	}];
    
    
    [AppDelegate transitionToViewController:[AppDelegate gameViewController]];
}

- (void) accepted:(NSDictionary *)game {
    NSString* acceptedGameId = [game objectForKey:@"id"];
    DragonChallenge* acceptChallenge = [[DragonChallenge alloc] initWhitPlayers:self.challenge.playerB :self.challenge.playerA];
    if([acceptedGameId isEqualToString:acceptChallenge.playerA.gameId] && [GameData isChallenging:acceptChallenge]){
        Game* game = [[Game alloc] init];
        game.challenge = acceptChallenge;
        [GameData setCurrentGame:game];
        [self.handlerChallenge removeOnDelete];
        [self startGame];
    }
}

- (void) tap:(NSDictionary *)tap {
    
}

- (void) lost:(NSDictionary *)lost {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _adUnitView = [[AdUnitUIkit alloc] initWithPLaceholder:_imageBanner AndZone:BANNER_Z_ID];
	[WebSpectatorMobile putAdUnit:_adUnitView];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    [self.handlerChallenge removeOnDelete];
    
    [WebSpectatorMobile deleteAdUnit:_adUnitView];
}

- (IBAction)buttonQuitChallenge:(id)sender {
	[self.handlerChallenge removeOnDelete];
    [self.challenge remove:^(NSError *error) {
        if(error != nil){
            //NSLog(@"Error Quit waiting challenge\nA:\n%@\nB:\n%@\n%@", [self.challenge.playerA toString], [self.challenge.playerB toString], [error localizedDescription]);
        }
		[AppDelegate backToRootViewController];
	}];
}

- (void) startEcho{
    
}

@end
