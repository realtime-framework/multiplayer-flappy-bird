//
//  Game.m
//  FlappyDragon
//
//  Created by admin on 3/12/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "Game.h"
#import "DragonChallenge.h"

@implementation Game

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isGameOver = NO;
    }
    return self;
}

@end
