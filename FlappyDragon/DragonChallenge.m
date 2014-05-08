//
//  DragonChallenge.m
//  FlappyDragon
//
//  Created by iOSdev on 10/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "DragonChallenge.h"
#import "StorageManager.h"

@implementation DragonChallenge
{
	ItemRef* challengeItemRef;
}

- (id)initWhitPlayers:(DragonPlayer *) playerA :(DragonPlayer *) playerB
{
    self = [super init];
    if (self) {
		
		self.playerA = playerA;
		self.playerB = playerB;
	}
    return self;
}

- (id)initWhitDictionary:(NSDictionary *) json {
    self = [super init];
	
	self.playerA = [[DragonPlayer alloc] init];
	self.playerB = [[DragonPlayer alloc] init];
    
	
    if(json != nil){
        self.playerA.gameId = [json objectForKey:@"gameId"];
        self.playerB.gameId = [json objectForKey:@"gameIdB"];
		self.playerA.nickname = [json objectForKey:@"nickNameA"];
		self.playerB.nickname = [json objectForKey:@"nickNameB"];
	}
    
    return self;
}


- (void) create:(void (^)(NSError* error)) callback {
	
	TableRef *challengeRef = [[[StorageManager sharedManager] storageRef] table:TAB_CHALLENGES];
	
	NSDictionary *challenge = [NSDictionary dictionaryWithObjectsAndKeys:
							   self.playerB.gameId, PK_CHALLENGES,
							   self.playerA.gameId, SK_CHALLENGES,
							   self.playerB.nickname, @"nickNameA",
							   self.playerA.nickname, @"nickNameB", nil];
	
	[challengeRef push:challenge success:^(ItemSnapshot *item) {
		
		[self.playerA incrementChallenges:^(NSError *error) {
			
			if (error != nil) {
				callback (error);
			}
			else {
				[self.playerB incrementChallenges:^(NSError *error) {
					callback (error);
				}];
			}
		}];
		
	} error:^(NSError *error) {
		callback(error);
	}];
}

- (void) remove:(void (^)(NSError* error)) callback{
    TableRef *challengeRef = [[[StorageManager sharedManager] storageRef] table:TAB_CHALLENGES];
    
    ItemRef* itemRef = [challengeRef item:self.playerB.gameId secondaryKey:self.playerA.gameId];
    [itemRef get:^(ItemSnapshot *item) {
        if([item val] != nil){
            [itemRef del:^(ItemSnapshot *success) {
                [self.playerA decrementChallenges:^(NSError *error) {
                    if(error != nil){
						callback(error);
                    }else{
                        [self.playerB decrementChallenges:callback];
					}
                }];
            } error:callback];
        }else{
            callback(nil);
        }
    } error:callback];
}

- (void) onDelete:(void (^)()) callback {
	
	TableRef* playerChallenges = [[[StorageManager sharedManager] storageRef] table:TAB_CHALLENGES];
	
    self->challengeItemRef = [playerChallenges item:self.playerA.gameId secondaryKey:self.playerB.gameId];
    [self->challengeItemRef on:StorageEvent_DELETE callback:^(ItemSnapshot *item) {
		callback();
    }];
}


- (void) removeOnDelete {
	
    if(self->challengeItemRef != nil){
        [self->challengeItemRef off:StorageEvent_DELETE];
    }
}


@end
