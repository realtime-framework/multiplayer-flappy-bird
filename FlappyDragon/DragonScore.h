//
//  PlayerScore.h
//  FlappyDragon
//
//  Created by admin on 3/8/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DragonScore : NSObject

- (id) initWithDictionary:(NSDictionary*) json;

@property NSString* nickname;
@property NSString* gameId;
@property long long score;


@end
