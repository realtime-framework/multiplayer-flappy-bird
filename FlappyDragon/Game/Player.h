//
//  Player.h
//  FlappyDragon
//
//  Created by Nathan Borror on 2/8/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "AdUnit.h"
#import "AdUnitSpriteKit.h"
#import "WebSpectatorMobile.h"

@interface Player : SKSpriteNode

@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *localStartTime;
@property NSString* gameId;
@property AdUnitSpriteKit *adUnitView;

@end