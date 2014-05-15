//
//  StorageManager.h
//  FlappyDragon
//
//  Created by iOSdev on 12/30/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//


#define SERVER @"http://ortc-developers.realtime.co/server/ssl/2.1"
#define AUTH_TOKEN @"FlyingBrands"
#define APP_KEY @"[YOUR_APPLICATION_KEY_HERE]"
#define CONNECTION_METADATA @"__CONNECTION_METADATA__"
#define ISCLUSTER 1

//___________________________________________________________
//  DragonScores (game score by gameName):
//  - dragonScores		(NSString)	- primary key
//  - score				(Number)	- secondary key
//  - nickName			(NSString)	- nickname of the player with highScore
//  - gameId			(NSString)	- player game id

//  DragonPlayers:
//  - nickName			(NSString)	- primary key
//  - gameId		(NSString)	- secondary key
//  - challenges	(Number)	- challenges pending
//  - state			(NSString)	- (offline, waiting, playing)

//	DragonStatus:
//  - state			(NSString)	- primary key (offline, waiting, playing) 
//  - gameId		(NSString)	- secondary key
//  - challenges	(Number)	- challenges pending
//  - score			(Number)	- score
//  - nickName		(NSString)	- player nick name

//  DragonChallenges:
//  - gameId			(NSString)	- player game id
//  - gameIdB			(NSString)	- opponent player game id


#define TAB_SCORES @"DragonScores"
#define PK_SCORES @"dragonScores"
#define SK_SCORES @"score"

#define TAB_PLAYERS @"DragonPlayers"
#define PK_PLAYERS @"nickName"
#define SK_PLAYERS @"gameId"

#define TAB_STATUS @"DragonStatus"
#define PK_STATUS @"state"
#define SK_STATUS @"gameId"

#define TAB_CHALLENGES @"DragonChallenges"
#define PK_CHALLENGES @"gameId"
#define SK_CHALLENGES @"gameIdB"

#define TAB_CHAT @"DragonChat"
#define PK_CHAT @"dragonChatRoom"
#define SK_CHAT @"timeStamp"
//___________________________________________________________


#import <Foundation/Foundation.h>
#import <RealTimeCloudStorage/RealTimeCloudStorage.h>

@interface StorageManager : NSObject

@property (nonatomic, strong) StorageRef *storageRef;


+ (StorageManager *) sharedManager;

@end

