//
//  Player.h
//  FlappyDragon
//
//  Created by admin on 3/8/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DragonPlayer : NSObject

extern NSString* const PLAYER_STATE_WAITING;
extern NSString* const PLAYER_STATE_PLAYING;
extern NSString* const PLAYER_STATE_OFFLINE;



@property NSString* nickname;
@property NSString* gameId;
@property int challenges;
@property NSString* state;
@property long long score;



- (id) initWithDictionary:(NSDictionary*) json;
- (id) initWithLocal;
- (NSString*) toString;
- (void) onChange:(void (^)()) callback;
- (void) removeOnChange;

- (void) onChallenge:(void (^)(NSString *nickName, NSString *gameId)) callback;
- (void) removeOnChallenge;


- (void) changeStatus:(NSString*) status :(void (^)(NSError* error)) callback;
- (void) sync:(void (^)(NSError* error)) callback;
- (void) save:(void (^)(NSError* error)) callback;


- (void) incrementChallenges:(void (^)(NSError* error)) callback;
- (void) decrementChallenges:(void (^)(NSError* error)) callback;
- (void) setChallengesOnTable:(int) challenges;

- (void) incrementScore:(int) score :(void (^)(NSError* error)) callback;


@end
