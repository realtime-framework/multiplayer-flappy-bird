//
//  AcceptViewController.m
//  FlappyDragon
//
//  Created by iOSdev on 11/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "AcceptViewController.h"
#import "GameOverViewController.h"
#import "GameViewController.h"
#import "GameData.h"

@interface AcceptViewController ()

@end

@implementation AcceptViewController

NSString* const LABEL_CHALLENGE_TEXT = @"Player %@ challenged you";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSString* labelChallengeText = [NSString stringWithFormat:LABEL_CHALLENGE_TEXT, self.challenge.playerB.nickname];
    [self.titleLabel setText:labelChallengeText];
	[_titleLabel setFont:[UIFont fontWithName:@"Floraless" size:18]];
	_titleLabel.minimumScaleFactor = 0.5;
	_titleLabel.adjustsFontSizeToFitWidth = YES;
	_titleLabel.textColor = TEXT_COLOR;
	_titleLabel.shadowColor = TEXT_SHADOW_COLOR;
	_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
    
    [self.challenge onDelete:^{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Player %@ quit challenge.",self.challenge.playerB.nickname] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
		
		[AppDelegate backToRootViewController];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    [[GameData communication] setOnAction:self];
}

-(void)viewDidDisappear:(BOOL)animated {
	
	[self.challenge removeOnDelete];
	[super viewDidDisappear:animated];
}


#pragma - mark Actions

- (IBAction)denyBttAction:(id)sender {
    [self.challenge removeOnDelete];
    DragonChallenge* challengeToRemove = [[DragonChallenge alloc] initWhitPlayers:self.challenge.playerB :self.challenge.playerA];
    [challengeToRemove remove:^(NSError *error) {
        if(error != nil){
            //NSLog(@"Error Quit waiting challenge\nA:\n%@\nB:\n%@\n%@", [challengeToRemove.playerA toString], [challengeToRemove.playerB toString], [error localizedDescription]);
        }
        [AppDelegate backToRootViewController];
    }];
}

- (IBAction)acceptBttAction:(id)sender {
	Game* game = [[Game alloc] init];
    game.challenge = self.challenge;
    [GameData setCurrentGame:game];
    [self.challenge removeOnDelete];
    
    [AppDelegate transitionToViewController:[AppDelegate gameViewController]];
}

- (void) start:(NSDictionary *)game{
    
}

- (void) accepted:(NSDictionary *)game {
    
}

- (void) tap:(NSDictionary *)tap {
    
}

- (void) lost:(NSDictionary *)lost {
    
}

- (void) startEcho{
    
}

@end
