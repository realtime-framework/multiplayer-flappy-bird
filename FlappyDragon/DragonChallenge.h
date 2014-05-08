//
//  DragonChallenge.h
//  FlappyDragon
//
//  Created by iOSdev on 10/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DragonPlayer.h"
#import "DragonChallenge.h"


@interface DragonChallenge : NSObject


@property DragonPlayer *playerA;
@property DragonPlayer *playerB;



- (id)initWhitPlayers:(DragonPlayer *) playerA :(DragonPlayer *) playerB;
- (id)initWhitDictionary:(NSDictionary *) json;
- (void) create:(void (^)(NSError* error)) callback;
- (void) remove:(void (^)(NSError* error)) callback;

- (void) onDelete:(void (^)()) callback;
- (void) removeOnDelete;

@end
