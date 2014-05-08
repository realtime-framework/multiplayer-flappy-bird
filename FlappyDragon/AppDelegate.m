//
//  AppDelegate.m
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "IntroViewController.h"
#import "GameData.h"
#import "WebSpectatorMobile.h"

@implementation AppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

	DragonPlayer* localPlayer = [GameData localPlayer];
    if(localPlayer.nickname == nil || [localPlayer.nickname length] < 1) {
		IntroViewController *introViewController = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
		self.window.rootViewController = introViewController;
	}
	else {
		self.window.rootViewController = [AppDelegate rootViewController];
	}
	
	self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
	
    [WebSpectatorMobile startWebSpectatorClientWhitClientName:@"WS-DEMOS" AndId:@"19"];
    
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[[AppDelegate rootViewController].activityIndicator startAnimating];
	if([GameData localPlayer] != nil){
		[[AppDelegate rootViewController].activityIndicator stopAnimating];
        [[GameData localPlayer] sync:^(NSError *error) {
            if(error != nil){
                //NSLog(@"Error syncing local player: %@",error.localizedDescription);
            }else{
                [[AppDelegate rootViewController].pendingLabel setText:[NSString stringWithFormat:@"%d", [[GameData localPlayer] challenges]]];
            }
        }];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	if([GameData currentGame] != nil && ![GameData currentGame].isGameOver){
        [[[GameData currentGame] challenge] remove:^(NSError *error) {
            
        }];
    }
}


+ (void) backToRootViewController {
	
	[AppDelegate transitionToViewController:[AppDelegate rootViewController]];
}

+ (void)transitionToViewController:(UIViewController *)viewController {
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	 appDelegate.window.rootViewController = viewController;
}

+ (GameViewController* ) gameViewController{
    static GameViewController* gameViewController = nil;
    
    if (gameViewController == nil)
    {
        gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    }
    
    return gameViewController;
}

+ (RootViewController* ) rootViewController{
    static RootViewController* rootViewController = nil;
    
    if (rootViewController == nil)
    {
        rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    }
    
    return rootViewController;
}

@end
