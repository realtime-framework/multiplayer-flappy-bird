//
//  PlayerScore.m
//  FlappyDragon
//
//  Created by admin on 3/8/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "DragonScore.h"
#import "StorageManager.h"
#import "DragonPlayer.h"

@implementation DragonScore
- (id) initWithDictionary:(NSDictionary*) json {
    self = [super init];
    
    if(json != nil){
        self.nickname = [json objectForKey:@"nickName"];
        self.gameId = [json objectForKey:@"gameId"];
        self.score = [[json objectForKey:@"score"] longLongValue];
    }
    
    return self;
}


@end