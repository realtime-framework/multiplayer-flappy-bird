//
//  AdUnitSpriteKit.h
//  testWS
//
//  Created by iOSdev on 18/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "AdUnit.h"
#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>


@interface AdUnitSpriteKit : AdUnit

- (id) initWithPLaceholder:(SKSpriteNode *) adUnit AndZone:(int) zone;
- (void) changeBanner:(NSString *) bannerURL;


@end
