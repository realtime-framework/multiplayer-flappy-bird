//
//  StorageManager.m
//  FlappyDragon
//
//  Created by iOSdev on 12/30/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//


#import "StorageManager.h"
#import "GameData.h"

@implementation StorageManager

+ (StorageManager *) sharedManager
{
    
	static dispatch_once_t pred;
    static StorageManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[StorageManager alloc] initWithUserData];
    });
    return sharedInstance;
}


- (id) initWithUserData {
    
    self = [super init];
    if (self) {
		[self setUserData];
    }
    return self;
}


- (void) setUserData {	
	_storageRef = [[StorageRef alloc] init:APP_KEY privateKey:nil authenticationToken:AUTH_TOKEN];
	
    [_storageRef onReconnected:^(StorageRef *storage){
        //NSLog(@" - StorageRef onReconnected");
    }];
	
}


#pragma mark - Player NickName & ID



// check if Game ID exists on table Players

- (void) checkGameId:(NSString *) gameID OnTableOnCompletion:(void (^)(BOOL finished)) completion {
	
	TableRef *tableRef = [_storageRef table:TAB_PLAYERS];
	
	__block BOOL gameIDExists = NO;
	[tableRef getItems:^(ItemSnapshot *item) {//define block for a success callback
		
		if(item!=nil) {
			NSDictionary *dic = [item val];
			if ([gameID isEqualToString:[dic objectForKey:SK_PLAYERS]]) {
				gameIDExists = YES;
			}
		}
        else {
			//we got all items
			completion(gameIDExists);
		}
	} error:^(NSError *error) { //define block for an error callback
        //NSLog(@"### Error: %@", [error localizedDescription]);
    }];
}





#pragma mark - Player Challenges

// load number of player challenges on Players Table

- (void) loadPlayerChallenges:(NSDictionary *) player OnCompletion:(void (^)(NSNumber *playerChallenges)) completion {
	ItemRef *itemRef = [[_storageRef table:TAB_PLAYERS] item:[player objectForKey:PK_PLAYERS] secondaryKey:[player objectForKey:SK_PLAYERS]];
	
	[itemRef get:^(ItemSnapshot *success) {
		//NSLog(@"\nItem:\n%@\n GET Successfully", [success val]);
		completion([[success val] objectForKey:@"challenges"]);
		
	} error:^(NSError *error) {
		//NSLog(@"Error Writing item\nERROR: %@", [error description]);
		completion(nil);
	}];
}

- (void) writeChallenge:(NSDictionary *) challenge OnCompletion:(void (^)(BOOL finished)) completion {

	TableRef *tableRef = [_storageRef table:TAB_CHALLENGES];
	ItemRef *chItem = [tableRef item:[challenge objectForKey:PK_CHALLENGES] secondaryKey:[challenge objectForKey:SK_CHALLENGES]];
	
	[chItem get:^(ItemSnapshot *item) {
		if ([[item val] objectForKey:PK_CHALLENGES] != nil) {
			completion(NO);
		}
		else {
			//NSLog(@"chItem NIL");
			[tableRef push:challenge success:^(ItemSnapshot *success) {
				//NSLog(@"\nITEM:\n%@ WRITEN", [success val]);
				completion(YES);
				
			} error:^(NSError *error) {
				//NSLog(@"Error WRITING CH on TAB_CHALLENGES writeChallenge\nERROR: %@", [error description]);
				completion(NO);
			}];
		}
	} error:^(NSError *error) {
		//NSLog(@"Error Getting Item TAB_CHALLENGES writeChallenge\nERROR: %@", [error description]);
	}];
}

#pragma mark - Player Status

// delete player status on Status Table

- (void) deletePlayerStatus:(NSDictionary *) playerStatus OnCompletion:(void (^)(BOOL finished)) completion {
	
	ItemRef *itemRef = [[_storageRef table:TAB_STATUS] item:[playerStatus objectForKey:PK_STATUS] secondaryKey:[playerStatus objectForKey:SK_STATUS]];
	
	[itemRef del:^(ItemSnapshot *success) {
		//NSLog(@"\nITEM PLAYER STATUS:\n%@ DEleted", [success val]);
		completion(YES);
	} error:^(NSError *error) {
		
		//NSLog(@"\nERROR DELETING PLAYER STATUS ITEM:\nERROR:\n%@", [error localizedDescription]);
		completion(NO);
	}];
}



// set the player status on Status Table

- (void) setPlayerStatus:(NSDictionary *) newPlayerStatus OnCompletion:(void (^)(BOOL finished)) completion {
	
    NSString* gameId = [newPlayerStatus objectForKey:@"gameId"];
    NSString* nickname = [newPlayerStatus objectForKey:@"nickName"];
    NSString* status = [newPlayerStatus objectForKey:@"state"];
    
	[[_storageRef table:TAB_STATUS] push:newPlayerStatus
								 success:^(ItemSnapshot *item) {
									 ItemRef* playerItem = [[_storageRef table:TAB_PLAYERS] item:nickname secondaryKey:gameId];
                                     NSDictionary *updateItem = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                 status, @"state", nil];
                                     [playerItem set:updateItem success:^(ItemSnapshot *success) {
                                         completion(YES);
                                     } error:^(NSError *error) {
                                         completion(NO);
                                     }];
								 }
								   error:^(NSError *error) {
									   //NSLog(@"Error Writing player Status item\nERROR: %@", [error description]);
									   completion(NO);
								   }];
    
}

#pragma mark - Player Scores

// increment player score
- (void) incrementPlayerScore:(NSDictionary *) playerScore WhitScore:(NSNumber *) score OnCompletion:(void (^)(BOOL finished)) completion {
	NSNumber *totalScore = [NSNumber numberWithInt:([[playerScore objectForKey:SK_SCORES] intValue] + [score intValue])];
	ItemRef *itemRef = [[_storageRef table:TAB_SCORES] item:[playerScore objectForKey:PK_SCORES] secondaryKey:[playerScore objectForKey:SK_SCORES]];
	
	[itemRef del:^(ItemSnapshot *success) {
		
		NSDictionary *newScore = [NSDictionary dictionaryWithObjectsAndKeys:
								  [playerScore objectForKey:PK_SCORES], PK_SCORES,
								  totalScore, SK_SCORES,
								  [playerScore objectForKey:PK_PLAYERS], @"nickName",
								  [playerScore objectForKey:SK_STATUS], @"gameId", nil];
		
		[[_storageRef table:TAB_SCORES] push:newScore
									 success:^(ItemSnapshot *item) {
										 ItemRef *itemRef = [[_storageRef table:TAB_STATUS] item:[playerScore objectForKey:PK_STATUS] secondaryKey:[playerScore objectForKey:SK_STATUS]];
										 [itemRef incr:@"score" withValue:[score intValue] success:^(ItemSnapshot *success) {
											 
											 completion(YES);
										 } error:^(NSError *error) {
											 //NSLog(@"Error INCREMENTING SCORE on TAB_STATUS\nERROR: %@", [error description]);
										 }];
									 }
									   error:^(NSError *error) {
										   //NSLog(@"Error Writing item\nERROR: %@", [error description]);
										   completion(NO);
									   }];
	} error:^(NSError *error) {
		//NSLog(@"Error DELETING SCORE\nERROR: %@", [error description]);
	}];
}





@end
