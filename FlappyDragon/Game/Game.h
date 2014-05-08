//
//  Game.h
//  FlappyDragon
//
//  Created by admin on 3/12/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DragonChallenge.h"

@interface Game : NSObject
@property DragonChallenge* challenge;
@property (strong, nonatomic) NSMutableArray* map;
@property long long localStartTime;
@property long long opponentStartTime;
@property long long localGameOverTime;
@property long long opponentGameOverTime;
@property Boolean isGameOver;
@end
