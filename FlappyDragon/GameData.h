//
//  GameData.h
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DragonPlayer.h"
#import "DragonChallenge.h"
#import "Communication.h"
#import "Game.h"

//#define TEXT_COLOR [UIColor colorWithRed:55/255.0 green:40/255.0 blue:45/255.0 alpha:1.0]
#define TEXT_COLOR [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]
#define TEXT_SHADOW_COLOR [UIColor darkGrayColor]

@interface GameData : NSObject

#define MY_GAME_ID_KEY @"MY_GAME_ID"
#define MY_NICKNAME_KEY @"MY_NICKNAME"
#define MAX_LATENCY 1000
#define MAP_SIZE 10

+ (DragonPlayer *) localPlayer;
+ (Communication *) communication;
+ (Game*) currentGame;
+ (void) setCurrentGame:(Game*)value;

+ (void) jsonParse:(NSString*) text :(void (^)(NSDictionary* json, NSError* error)) callback;

+ (void) getPlayer:(NSString*) nickname :(void (^)(DragonPlayer *player, NSError* error)) callback;
+ (void) getPlayer:(NSString*) nickname :(NSString*)gameId :(void (^)(DragonPlayer *player, NSError* error)) callback;
+ (void) getTop10Players:(void (^)(NSMutableArray *players, NSError* error)) callback;
+ (void) getChallenge:(NSString*) gameIdA :gameIdB :(void (^)(DragonChallenge *challenge, NSError* error)) callback;

+ (void) getPendingChallenges:(void (^)(NSMutableArray *challenges, NSError* error)) callback;
+ (void) getAvailablePlayers:(void (^)(NSMutableArray *avPlayers, NSError* error)) callback;

+ (void) makeChallenge:(DragonPlayer *) playerA :(DragonPlayer *) playerB :(void (^)(DragonChallenge* challenge,NSError* error)) callback;
+ (BOOL) isChallenging:(DragonChallenge*) challenge;

+ (NSMutableArray*) generateMap:(CGFloat)height :(int) length;
+ (long long) getCurrentDate;

+ (void) getMessage:(NSString*) messageId :(void (^)(NSString* message,NSError* error)) callback;

@end



