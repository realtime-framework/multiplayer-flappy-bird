//
//  Player.m
//  FlappyDragon
//
//  Created by admin on 3/8/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "DragonPlayer.h"
#import "DragonScore.h"
#import "StorageManager.h"

@implementation DragonPlayer
{
    ItemRef* playerItemRef;
	ItemRef* challengeItemRef;
}

NSString* const PLAYER_STATE_WAITING = @"waiting";
NSString* const PLAYER_STATE_PLAYING = @"playing";
NSString* const PLAYER_STATE_OFFLINE = @"offline";

#define LOCAL_GAME_ID_KEY @"DRAGON_GAME_ID"
#define LOCAL_NICKNAME_KEY @"DRAGON_NICKNAME"

- (id) initWithDictionary:(NSDictionary*) json {
    self = [super init];
    
    self->playerItemRef = nil;
    if(json != nil){
        self.nickname = [json objectForKey:@"nickName"];
        self.gameId = [json objectForKey:@"gameId"];
		self.challenges = [[json objectForKey:@"challenges"] intValue];
		self.state = [json objectForKey:@"state"];
        self.score = 0;
    }
    
    return self;
}

- (id) initWithLocal{
    self = [super init];
    
    self->playerItemRef = nil;
    self.nickname = nil;
    self.gameId = nil;
    self.challenges = 0;
    self.state = nil;
    self.score = 0;
    
    NSString *savedGameID = [[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_GAME_ID_KEY];
    if (savedGameID != nil) {
        self.gameId = savedGameID;
    }
    
    NSString *savedNickName = [[NSUserDefaults standardUserDefaults] objectForKey:LOCAL_NICKNAME_KEY];
    if (savedNickName != nil) {
        self.nickname = savedNickName;
    }
    
    return self;
}

- (void) sync:(void (^)(NSError* error)) callback{
    if(self.nickname != nil && self.gameId != nil){
        TableRef* tableRef = [[[StorageManager sharedManager] storageRef] table:TAB_PLAYERS];
        ItemRef* playerRef = [tableRef item:self.nickname secondaryKey:self.gameId];
		
        [playerRef get:^(ItemSnapshot *success) {
			self.state = [[success val] objectForKey:@"state"];
			self.challenges = [[[success val] objectForKey:@"challenges"] intValue];
			callback(nil);
        } error:^(NSError *error) {
            callback(error);
        }];
    }else{
        callback(nil);
    }
}

- (void) onChange:(void (^)()) callback {
    TableRef* tableRef = [[[StorageManager sharedManager] storageRef] table:TAB_PLAYERS];
    self->playerItemRef = [tableRef item:self.nickname secondaryKey:self.gameId];
    
    [self->playerItemRef on:StorageEvent_UPDATE callback:^(ItemSnapshot *item) {
        DragonPlayer* player = [[DragonPlayer alloc] initWithDictionary:item.val];
        self.nickname = player.nickname;
        self.gameId = player.gameId;
        self.challenges = player.challenges;
        self.state = player.state;
        callback();
    }];
}

- (void) removeOnChange {
    if(self->playerItemRef != nil){
        [self->playerItemRef off:StorageEvent_UPDATE];
    }
}


- (void) onChallenge:(void (^)(NSString *nickName, NSString *gameId)) callback {
	
    TableRef* playerChallenges = [[[StorageManager sharedManager] storageRef] table:TAB_CHALLENGES];
    self->challengeItemRef = [playerChallenges item:self.gameId];
    [self->challengeItemRef enablePushNotifications];
    
    [self->challengeItemRef on:StorageEvent_UPDATE callback:^(ItemSnapshot *item) {
        if(callback != nil){
            callback([[item val] objectForKey:@"nickNameB"], [[item val] objectForKey:@"gameIdB"]);
        }
    }];
}

- (void) removeOnChallenge {
    if(self->challengeItemRef != nil){
        [self->challengeItemRef off:StorageEvent_UPDATE];
    }
}


- (void) setStatus:(NSString*) status :(void (^)(NSError* error)) callback{
    TableRef* tableRef = [[[StorageManager sharedManager] storageRef] table:TAB_STATUS];
    
    NSDictionary *playerStatus = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  status, PK_STATUS,
                                  self.gameId, SK_STATUS,
                                  [NSNumber numberWithLongLong:self.score], @"score",
                                  [NSNumber numberWithInt:self.challenges], @"challenges",
                                  self.nickname, @"nickName", nil];
	
	
	__block DragonPlayer *weakRef = self;
    
    [tableRef push:playerStatus success:^(ItemSnapshot *item) {
        TableRef* playerTableRef = [[[StorageManager sharedManager] storageRef] table:TAB_PLAYERS];
        
        NSDictionary *updateItem = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    status, @"state", nil];
        
        ItemRef* playerItem = [playerTableRef item:weakRef.nickname secondaryKey:weakRef.gameId];
        
        [playerItem set:updateItem success:^(ItemSnapshot *success) {
			weakRef.state = status;
            callback(nil);
        } error:^(NSError *error) {
            callback(error);
        }];
    } error:^(NSError *error) {
        callback(error);
    }];
    
}

- (void) deleteStatus:(void (^)(NSError* error)) callback{
    TableRef* tableRef = [[[StorageManager sharedManager] storageRef] table:TAB_STATUS];
    
    ItemRef* playerStatus = [tableRef item:self.state secondaryKey:self.gameId];
    [playerStatus del:^(ItemSnapshot *success) {
        callback(nil);
    } error:^(NSError *error) {
        callback(error);
    }];
}

- (void) changeStatus:(NSString*) status :(void (^)(NSError* error)) callback{
	
    if(self.state == nil){
        [self setStatus:status :callback];
    }else{
		__block DragonPlayer *weakRef = self;
        [self deleteStatus:^(NSError *error) {
            if(error != nil){
                callback(error);
            }else{
                [weakRef setStatus:status :callback];
            }
        }];
    }
}

- (void) saveInLocalStorage{
	
	[[NSUserDefaults standardUserDefaults] setObject:self.nickname forKey:LOCAL_NICKNAME_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.gameId forKey:LOCAL_GAME_ID_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) save:(void (^)(NSError* error)) callback{
    TableRef* tableRef = [[[StorageManager sharedManager] storageRef] table:TAB_PLAYERS];
    
    NSDictionary *newPlayer = [[NSDictionary alloc] initWithObjectsAndKeys:
                               self.nickname, PK_PLAYERS,
                               self.gameId, SK_PLAYERS,
                               [NSNumber numberWithLongLong:self.score], @"score",
                               [NSNumber numberWithInt:self.challenges], @"challenges", nil];
    
    [tableRef push:newPlayer success:^(ItemSnapshot *item) {
        [self saveInLocalStorage];
        callback(nil);
    } error:^(NSError *error) {
        callback(error);
    }];
}



- (void) incrementChallenges:(void (^)(NSError* error)) callback {
    
	
	ItemRef *playerRef = [[[[StorageManager sharedManager] storageRef] table:TAB_PLAYERS] item:self.nickname secondaryKey:self.gameId];
	
	[playerRef incr:@"challenges" success:^(ItemSnapshot *playerItem) {
		ItemRef *statusRef = [[[[StorageManager sharedManager] storageRef] table:TAB_STATUS] item:self.state secondaryKey:self.gameId];
		
		[statusRef incr:@"challenges" success:^(ItemSnapshot *statusItem) {
			self.challenges = [[[statusItem val] objectForKey:@"challenges"] intValue];
			if (callback) {
				callback(nil);
			}
			
		} error:^(NSError *error) {
			//NSLog(@"Error INCREMENTING CHALLENGES on STatus \nERROR: %@", [error description]);
			if (callback) {
				callback(error);
			}
		}];
		
	} error:^(NSError *error) {
		//NSLog(@"Error INCREMENTING CHALLENGES  on Players \nERROR: %@", [error description]);
		if (callback) {
			callback(error);
		}
	}];
}



- (void) decrementChallenges:(void (^)(NSError* error)) callback {
	ItemRef *playerRef = [[[[StorageManager sharedManager] storageRef] table:TAB_PLAYERS] item:self.nickname secondaryKey:self.gameId];
	[playerRef decr:@"challenges" success:^(ItemSnapshot *playerItem) {
		ItemRef *statusRef = [[[[StorageManager sharedManager] storageRef] table:TAB_STATUS] item:self.state secondaryKey:self.gameId];
		
		[statusRef decr:@"challenges" success:^(ItemSnapshot *statusItem) {
			self.challenges = [[[statusItem val] objectForKey:@"challenges"] intValue];
			if (callback) {
				callback(nil);
			}
			
		} error:^(NSError *error) {
			//NSLog(@"Error DECREMENTING CHALLENGES on STatus \nERROR: %@", [error description]);
			if (callback) {
				callback(error);
			}
		}];
		
	} error:^(NSError *error) {
		//NSLog(@"Error DECREMENTING CHALLENGES  on Players \nERROR: %@", [error description]);
		if (callback) {
			callback(error);
		}
	}];
}


- (void) setChallengesOnTable:(int) challenges {
	
	ItemRef *playerRef = [[[[StorageManager sharedManager] storageRef] table:TAB_PLAYERS] item:self.nickname secondaryKey:self.gameId];
	
	NSDictionary *updateItem = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithInt:challenges], @"challenges", nil];
	
	[playerRef set:updateItem success:^(ItemSnapshot *success) {
		
		//NSLog(@"playerRef TAB_PLAYERS success : %@", [success val]);
	} error:^(NSError *error) {
		//NSLog(@"playerRef TAB_PLAYERS ERROR : %@", [error localizedDescription]);
		
	}];
	
	
	ItemRef *statusRef = [[[[StorageManager sharedManager] storageRef] table:TAB_STATUS] item:self.state secondaryKey:self.gameId];
	[statusRef set:updateItem success:^(ItemSnapshot *success) {
		
		//NSLog(@"playerRef TAB_STATUS success : %@", [success val]);
		
	} error:^(NSError *error) {
		//NSLog(@"playerRef TAB_STATUS ERROR : %@", [error localizedDescription]);
	}];
	
}




- (void) setStatusScore:(void (^)(NSError* error)) callback {
    TableRef *statusRef = [[[StorageManager sharedManager] storageRef] table:TAB_STATUS];
	ItemRef *statusItemRef = [statusRef item:self.state secondaryKey:self.gameId];
    
    NSDictionary *updateItem = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithLongLong:self.score], @"score", nil];
    
    [statusItemRef set:updateItem success:^(ItemSnapshot *success) {
        callback(nil);
    } error:^(NSError *error) {
        callback(error);
    }];
}

- (void) scoreExists:(void (^)(BOOL exists, NSError* error)) callback {
    TableRef *scoresRef = [[[StorageManager sharedManager] storageRef] table:TAB_SCORES];
	ItemRef *scoreItemRef = [scoresRef item:PK_SCORES secondaryKey:[NSString stringWithFormat:@"%lld", self.score]];
    
    [scoreItemRef get:^(ItemSnapshot *success) {
        if([success val] != nil && [[self nickname] isEqualToString:[[success val] objectForKey:@"nickName"]]){
            callback(YES,nil);
        }else{
            callback(NO,nil);
        }
    } error:^(NSError *error) {
        callback(NO,error);
    }];
}

- (void) deleteScore:(void (^)(NSError* error)) callback {
    TableRef *scoresRef = [[[StorageManager sharedManager] storageRef] table:TAB_SCORES];
	ItemRef *scoreItemRef = [scoresRef item:PK_SCORES secondaryKey:[NSString stringWithFormat:@"%lld", self.score]];
    
    [scoreItemRef del:^(ItemSnapshot *success) {
        callback(nil);
    } error:^(NSError *error) {
        callback(error);
    }];
}

- (void) setNewScore:(long long) score :(void (^)(NSError* error)) callback {
    TableRef *scoresRef = [[[StorageManager sharedManager] storageRef] table:TAB_SCORES];
    
    NSDictionary *playerScore = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 PK_SCORES, PK_SCORES,
                                 [NSNumber numberWithLongLong:score], SK_SCORES,
                                 self.nickname, @"nickName",
                                 self.gameId, @"gameId", nil];
    
    [scoresRef push:playerScore success:^(ItemSnapshot *success) {
        self.score = score;
        callback(nil);
    } error:^(NSError *error) {
        callback(error);
    }];
}

- (void) updateScore:(long long) score :(void (^)(NSError* error)) callback {
    [self scoreExists:^(BOOL exists, NSError *error) {
        if(error != nil){
            callback(error);
        }else{
            if(exists){
                [self deleteScore:^(NSError *error) {
                    if(error != nil){
                        callback(error);
                    }else{
                        [self setNewScore:score :callback];
                    }
                }];
            }else{
                [self setNewScore:score :callback];
            }
        }
    }];
}

- (void) incrementScore:(int) score :(void (^)(NSError* error)) callback {
    TableRef* playersRef = [[[StorageManager sharedManager] storageRef] table:TAB_PLAYERS];
    ItemRef* playerRef = [playersRef item:self.nickname secondaryKey:self.gameId];
    
    __block DragonPlayer* weakSelf = self;
    [playerRef incr:@"score" withValue:score success:^(ItemSnapshot *item) {
        if ([item val] != nil) {
            long long score = [[[item val] objectForKey:@"score"] longLongValue];
            [self setStatusScore:^(NSError *error) {
                if(error != nil){
                    callback(error);
                }else{
                    [weakSelf updateScore:score :callback];
                }
            }];
        }
    } error:^(NSError *error) {
        callback (error);
    }];
    
}



- (NSString*) toString{
    return [NSString stringWithFormat:@"nickname = %@ | gameId = %@ | challenges = %d | state = %@ | score = %lld", self.nickname,self.gameId,self.challenges,self.state,self.score];
}



@end


