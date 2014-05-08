//
//  AcceptViewController.h
//  FlappyDragon
//
//  Created by iOSdev on 11/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragonChallenge.h"
#import "Communication.h"

@interface AcceptViewController : UIViewController <CommunicationDelegate>

@property DragonChallenge* challenge;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


- (IBAction) denyBttAction:(id)sender;
- (IBAction) acceptBttAction:(id)sender;


@end
