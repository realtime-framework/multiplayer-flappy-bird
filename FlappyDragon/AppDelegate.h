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

@interface AppDelegate : RealtimePushAppDelegate


@property (strong, nonatomic) UIWindow *window;

+ (GameViewController *) gameViewController;
+ (RootViewController *) rootViewController;
+ (void) backToRootViewController;
+ (void) transitionToViewController:(UIViewController *)viewController;


@end
