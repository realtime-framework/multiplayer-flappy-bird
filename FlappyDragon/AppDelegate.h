//
//  AppDelegate.h
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RealTimeCloudStorage/RealtimePushAppDelegate.h>
#import "GameViewController.h"
#import "RootViewController.h"


#define BANNER_Z_ID_2 6760
#define BANNER_Z_ID 6036
#define SPONSOR_Z_ID 6038
#define BLOCK_Z_ID 6039
#define SPONSOR2_Z_ID 6527

@interface AppDelegate : RealtimePushAppDelegate


@property (strong, nonatomic) UIWindow *window;

+ (GameViewController *) gameViewController;
+ (RootViewController *) rootViewController;
+ (void) backToRootViewController;
+ (void) transitionToViewController:(UIViewController *)viewController;


@end

