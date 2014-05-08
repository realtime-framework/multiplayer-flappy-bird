//
//  WatingViewController.h
//  FlappyDragon
//
//  Created by João Franco on 10/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragonChallenge.h"
#import "Communication.h"

#import "AdUnit.h"
#import "AdUnitUIkit.h"
#import "WebSpectatorMobile.h"

#define BANNER_Z_ID 6036
#define SPONSOR_Z_ID 6038
#define BLOCK_Z_ID 6039

@interface WaitingViewController : UIViewController <CommunicationDelegate>

@property DragonChallenge* challenge;
@property (weak, nonatomic) IBOutlet UILabel *labelWaiting;

@property (weak, nonatomic) IBOutlet UIImageView *imageBanner;

- (IBAction)buttonQuitChallenge:(id)sender;



@end
