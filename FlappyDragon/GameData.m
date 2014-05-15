//
//  GameData.m
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "DragonScore.h"
#import "GameData.h"
#import "DragonChallenge.h"
#import "StorageManager.h"

@implementation GameData{
    
}

// Static constructor
+ (void) initialize {
    if (self == [GameData class]) {
        // Once-only initializion
    }
    // Initialization for this class and any subclasses
}

+ (DragonPlayer* ) localPlayer{
    static DragonPlayer* localPlayer = nil;
    
    if (localPlayer == nil)
    {
        localPlayer = [[DragonPlayer alloc] initWithLocal];
    }
    
    return localPlayer;
}

+ (Communication* ) communication{
    static Communication* communication = nil;
    
    if (communication == nil)
    {
        communication = [[Communication alloc] init];
    }
    
    return communication;
}

static Game* currentGame = nil;

+ (Game*) currentGame { return currentGame; }
+ (void) setCurrentGame:(Game*)value { currentGame = value; }

+ (void) jsonParse:(NSString*) text :(void (^)(NSDictionary* json, NSError* error)) callback{
    NSError *error = nil;
    NSData *jsonData = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if(error){
        callback(nil,error);
    }else{
        callback(json,nil);
    }
}

+ (void) getPlayer:(NSString*) nickname :(NSString*)gameId :(void (^)(DragonPlayer *player, NSError* error)) callback{
    TableRef* tableRef = [[[StorageManager sharedManager] storageRef] table:TAB_PLAYERS];
    ItemRef* itemRef = [tableRef item:nickname secondaryKey:gameId];
    
    [itemRef get:^(ItemSnapshot *item) {
        if([[item val] objectForKey:PK_PLAYERS] != nil){
            DragonPlayer* player = [[DragonPlayer alloc] initWithDictionary:item.val];
            callback(player,nil);
        }else{
            callback(nil,nil);
        }
    } error:^(NSError *error) {
        callback(nil,error);
    }];
}

+ (void) getPlayer:(NSString*) nickname :(void (^)(DragonPlayer *player, NSError* error)) callback{
    TableRef* tableRef = [[[StorageManager sharedManager] storageRef] table:TAB_PLAYERS];
    [tableRef equalsString:PK_PLAYERS value:nickname];
    
    __block DragonPlayer* player = nil;
    [tableRef getItems:^(ItemSnapshot *item) {
        if([[item val] objectForKey:PK_PLAYERS] != nil){
            if(player == nil){
                player = [[DragonPlayer alloc] initWithDictionary:item.val];
                callback(player,nil);
            }
        }else{
            if(player == nil){
                callback(nil,nil);
            }
        }
    } error:^(NSError *error) {
        callback(nil,error);
    }];
}

+ (void) getTop10Players:(void (^)(NSMutableArray *players, NSError* error)) callback{
    NSMutableArray *top10Players = [[NSMutableArray alloc] init];
    
    TableRef *tableRef = [[[StorageManager sharedManager] storageRef] table:TAB_SCORES];
	[tableRef equalsString:PK_SCORES value:@"dragonScores"];
	[tableRef limit:10];
    [tableRef desc];
    
    __block int totalScores;
    totalScores = 0;
    [tableRef getItems:^(ItemSnapshot *item) {
        if(item != nil){
            totalScores++;
            DragonScore* score = [[DragonScore alloc] initWithDictionary:item.val];
            [GameData getPlayer:score.nickname :score.gameId :^(DragonPlayer *player, NSError *error) {
                if(error != nil){
                    //NSLog(@"### Error: GET TOP 10 PLAYERS %@", [error localizedDescription]);
                }else if(player != nil){
                    player.score = score.score;
                    [top10Players addObject:player];
                }
                totalScores--;
                if(totalScores == 0){
                    if(top10Players.count > 1){
                        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO];
                        NSArray *sortedArray = [top10Players sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
                        
                        [top10Players removeAllObjects];
                        for (NSDictionary *dic in sortedArray) {
                            [top10Players addObject:dic];
                        }
					}
					callback(top10Players,nil);
				}
            }];
        }
		else {
			if (totalScores == 0) {
				callback (nil, nil);
			}
		}
	} error:^(NSError *error) {
        callback(nil,error);
    }];
}



+ (void) getChallenge:(NSString*) gameIdA :gameIdB :(void (^)(DragonChallenge *challenge, NSError* error)) callback {
	
	TableRef *tableRef = [[[StorageManager sharedManager] storageRef] table:TAB_CHALLENGES];
	ItemRef *challengeRef = [tableRef item:gameIdA secondaryKey:gameIdB];
	
	[challengeRef get:^(ItemSnapshot *success) {
		if ([success val] != nil) {
			
			DragonChallenge *challenge = [[DragonChallenge alloc] initWhitDictionary:[success val]];
			callback (challenge, nil);
		}
	} error:^(NSError *error) {
		callback(nil, error);
	}];
}



+ (void) getPendingChallenges:(void (^)(NSMutableArray *challenges, NSError* error)) callback {
	
	NSMutableArray *pendingChallenges = [[NSMutableArray alloc] init];
	
	TableRef *chalengesRef = [[[StorageManager sharedManager] storageRef] table:TAB_CHALLENGES];
	[chalengesRef equalsString:PK_CHALLENGES value:[[GameData localPlayer] gameId]];
	
	__block int totalChallenges = 0;
	[chalengesRef getItems:^(ItemSnapshot *item) {
		if ([item val] != nil) {
			totalChallenges ++;
			
			DragonPlayer *playerB = [[DragonPlayer alloc] init];
			playerB.nickname = [[item val] objectForKey:@"nickNameB"];
			playerB.gameId = [[item val] objectForKey:@"gameIdB"];
			
			[playerB sync:^(NSError *error) {
				if (error == nil) {					
					TableRef *statusRef = [[[StorageManager sharedManager] storageRef] table:TAB_STATUS];
					ItemRef *statusItemRef = [statusRef item:playerB.state secondaryKey:playerB.gameId];
					
					[statusItemRef get:^(ItemSnapshot *statusItem) {
						if ([[statusItem val] objectForKey:PK_STATUS] != nil) {
							playerB.score = [[[statusItem val] objectForKey:@"score"] intValue];
							
							DragonChallenge *challenge = [[DragonChallenge alloc] initWhitPlayers:[GameData localPlayer] :playerB];
							[pendingChallenges addObject:challenge];
							
							totalChallenges --;
							if (totalChallenges == 0) {
								callback(pendingChallenges, nil);
							}
						}
					} error:^(NSError *error) {
						//NSLog(@"### Error ON Get STatus: %@", [error localizedDescription]);
						totalChallenges --;
						if (totalChallenges == 0) {
							callback(pendingChallenges, nil);
						}
					}];
				}
				else {
					//NSLog(@"### Error SYNC PLayer B: %@", [error localizedDescription]);
					totalChallenges --;
					if (totalChallenges == 0) {
						callback(pendingChallenges, nil);
					}
				}
			}];
		}
		else if (totalChallenges == 0) {
			callback(nil, nil);
		}
	} error:^(NSError *error) {
		//NSLog(@"### Error ON Get Challenges: %@", [error localizedDescription]);
		callback(nil, error);
	}];
}

+ (void) getPlayersWithStatus:(NSString*) status :(void (^)(NSMutableArray *avPlayers, NSError* error)) callback {
    NSMutableArray *players = [[NSMutableArray alloc] init];
        
	TableRef *tableRef = [[[StorageManager sharedManager] storageRef] table:TAB_STATUS];
	[tableRef equalsString:PK_STATUS value:status];
    [tableRef lesserThanNumber:@"challenges" value:[NSNumber numberWithInt:10]];
	[tableRef limit:50];
	
	[tableRef getItems:^(ItemSnapshot *item) {
		
		if ([item val] != nil) {
			
			DragonPlayer *player = [[DragonPlayer alloc] initWithDictionary:[item val]];
			player.score = [[[item val] objectForKey:@"score"] longLongValue];
            if(![player.nickname isEqualToString:[GameData localPlayer].nickname]){
                [players addObject:player];
            }
		}
		else {
			callback(players,nil);
		}
	} error:^(NSError *error) {
		//NSLog(@"### Error: %@", [error localizedDescription]);
		callback(nil, error);
	}];

}

+ (void) getAvailablePlayers:(void (^)(NSMutableArray *players, NSError* error)) callback {
    NSMutableArray *players = [[NSMutableArray alloc] init];
    
	[GameData getPlayersWithStatus:PLAYER_STATE_WAITING :^(NSMutableArray *waitingPlayers, NSError *error) {
        if(error != nil){
            callback(nil,error);
        }else{
            [players addObjectsFromArray:waitingPlayers];
            [GameData getPlayersWithStatus:PLAYER_STATE_OFFLINE :^(NSMutableArray *offlinePlayers, NSError *error) {
                if(error != nil){
                    callback(nil,error);
                }else{
					if(players && players.count > 0){
						[players addObjectsFromArray:offlinePlayers];
						//NSUInteger maxRange = players.count < 10 ? players.count : 10;
						//callback((NSMutableArray*)[players subarrayWithRange:NSMakeRange(0, maxRange)],nil);
						callback(players ,nil);
					}else{
						callback(players,nil);
					}
                }
            }];
        }
    }];
}



+ (void) makeChallenge:(DragonPlayer *) playerA :(DragonPlayer *) playerB :(void (^)(DragonChallenge* challenge,NSError* error)) callback {
	
	DragonChallenge *challenge = [[DragonChallenge alloc] initWhitPlayers:playerA :playerB];
	[challenge create:^(NSError *error) {
		
		callback(challenge,error);
	}];
}

+ (BOOL) isChallenging:(DragonChallenge *)challenge{
    return ![challenge.playerA.nickname isEqualToString:[GameData localPlayer].nickname];
}

static const CGFloat kPipeGap = 130;

static const CGFloat randomFloat(CGFloat Min, CGFloat Max){
	return floor(((rand() % RAND_MAX) / (RAND_MAX * 1.0)) * (Max - Min) + Min);
}

+ (NSMutableArray *)generateMap:(CGFloat)height :(int)length{
    //NSLog(@"generate map with height %f and length %d",height,length);
    NSMutableArray* map = [[NSMutableArray alloc] init];
    CGFloat centerY = 0;
    for (int i = 0; i < 50; i++) {
        centerY = randomFloat(kPipeGap, height - kPipeGap);
        [map addObject:[NSNumber numberWithFloat:centerY]];
    }
    return map;
}

+ (long long) getCurrentDate {
	return [[NSDate date] timeIntervalSince1970] * 1000;
}

+ (void) getMessage:(NSString*) messageId :(void (^)(NSString *, NSError *))callback {
    TableRef *tableRef = [[[StorageManager sharedManager] storageRef] table:@"DragonMessages"];
    ItemRef* item = [tableRef item:messageId];
    
    [item get:^(ItemSnapshot *success) {
        if([success val] != nil){
            callback([[success val] objectForKey:@"message"],nil);
        }else{
            callback(nil,nil);
        }
    } error:^(NSError *error) {
        callback(nil,error);
    }];
}

@end

