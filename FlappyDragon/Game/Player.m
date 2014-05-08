//
//  Player.m
//  FlappyDragon
//
//  Created by Nathan Borror on 2/8/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import "Player.h"

@implementation Player

- (id)init
{
    self = [super init];
    if (self) {
        _startTime = [[NSString alloc] init];
		_localStartTime = [[NSString alloc] init];
    }
    return self;
}


@end
