//
//  GameScene.h
//  FlappyDragon
//
//  Created by Nathan Borror on 2/5/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Player.h"
#import "Game.h"
#import "Communication.h"

#import "AdUnit.h"
#import "AdUnitSpriteKit.h"
#import "WebSpectatorMobile.h"
/*
#define BANNER_Z_ID 6036
#define SPONSOR_Z_ID 6038
#define SPONSOR2_Z_ID 6527
#define BLOCK_Z_ID 6039
*/
@interface GameScene : SKScene <SKPhysicsContactDelegate, CommunicationDelegate>


@end
