//
//  GameOverViewController.h
//  FlappyDragon
//
//  Created by iOSdev on 11/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragonChallenge.h"

#import "AdUnit.h"
#import "AdUnitUIkit.h"
#import "WebSpectatorMobile.h"



@interface GameOverViewController : UIViewController

@property int iWon;
@property int score;
@property DragonChallenge *challenge;

@property (weak, nonatomic) IBOutlet UIImageView *imageBanner;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


- (IBAction) restartGame:(id)sender;
- (IBAction) close:(id)sender;


@end
