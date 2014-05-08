//
//  Communication.m
//  FlappyDragon
//
//  Created by admin on 3/12/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "Communication.h"
#include "GameData.h"


@implementation Communication {
    NSMutableArray* messagesBuffer;
}


- (id) init{
    self = [super init];
    
    messagesBuffer = [[NSMutableArray alloc] init];
    self.client = [OrtcClient ortcClientWithConfig:self];
    [self.client setClusterUrl:COMMUNICATION_SERVER];
    
    [self.client connect:COMMUNICATION_APP_KEY authenticationToken:COMMUNICATION_AUTH_TOKEN];
    
    return self;
}

- (void) emptyMessagesBuffer{
    if(messagesBuffer.count > 0){
        while(messagesBuffer.count > 0){
            NSDictionary* message = [messagesBuffer objectAtIndex:0];
            NSString* channel = [message objectForKey:@"channel"];
            NSString* text = [message objectForKey:@"message"];
            [messagesBuffer removeObjectAtIndex:0];
            [self.client send:channel message:text];
        }
    }
}

- (void) send:(NSString *)channel :(NSString *)message {
    @try {
        if(self.client != nil && [self.client isConnected]){
            [self.client send:channel message:message];
        }else{
            NSDictionary* messageBuffered = [[NSDictionary alloc] initWithObjectsAndKeys:channel,@"channel",message,@"message", nil];
            [messagesBuffer addObject:messageBuffered];
        }
    }
    @catch (NSException *exception) {
        //NSLog(@"Failed to send message : %@",exception.reason);
        NSDictionary* messageBuffered = [[NSDictionary alloc] initWithObjectsAndKeys:channel,@"channel",message,@"message", nil];
        [messagesBuffer addObject:messageBuffered];
        
    }
    @finally {
        
    }
}

- (void) subscribe:(NSString *)channel {
    [self.client subscribe:channel subscribeOnReconnected:YES onMessage:^(OrtcClient *ortc, NSString *channel, NSString *message) {
        [GameData jsonParse:message :^(NSDictionary *json, NSError *error) {
            if(error == nil){
                NSString* operation = [json objectForKey:@"op"];
                NSString* gameId = [json objectForKey:@"id"];
                if([operation isEqualToString:@"start"] && [gameId isEqualToString:[GameData localPlayer].gameId]){
                    if(self.onAction != nil){
                        [[self onAction] startEcho];
                        [self.client unsubscribe:channel];
                    }
                }
            }
        }];

    }];
}

- (void) subscribeChannels {
    [self.client subscribe:[GameData localPlayer].gameId subscribeOnReconnected:YES onMessage:^(OrtcClient *ortc, NSString *channel, NSString *message) {
        [GameData jsonParse:message :^(NSDictionary *json, NSError *error) {
            if(error == nil){
                NSString* operation = [json objectForKey:@"op"];
                if([operation isEqualToString:@"start"]){
                    if(self.onAction != nil){
                        [[self onAction] start:json];
                    }
                } else if([operation isEqualToString:@"tap"]){
                    if(self.onAction != nil){
                        [[self onAction] tap:json];
                    }
                } else if([operation isEqualToString:@"accepted"]){
                    if(self.onAction != nil){
                        [[self onAction] accepted:json];
                    }
                } else if([operation isEqualToString:@"lost"]){
                    if(self.onAction != nil){
                        [[self onAction] lost:json];
                    }
                }
            }
        }];
    }];
}


- (void) onException:(OrtcClient *)ortc error:(NSError *)error {
    //NSLog(@"Realtime error: %@",error.localizedDescription);
}

- (void) onConnected:(OrtcClient *)ortc {
	
    //NSLog(@"Connected to : %@",ortc.url);
	
    [self emptyMessagesBuffer];
    [self subscribeChannels];
}

- (void) onReconnected:(OrtcClient *)ortc {
    //NSLog(@"Reconnected to : %@",ortc.url);
    [self emptyMessagesBuffer];
}

- (void) onSubscribed:(OrtcClient *)ortc channel:(NSString *)channel{
    //NSLog(@"Channel subscribed: %@",channel);
}

- (void) onDisconnected:(OrtcClient *)ortc {
    
}

- (void) onReconnecting:(OrtcClient *)ortc {
    //NSLog(@"Reconnecting to : %@",ortc.url);
}

- (void) onUnsubscribed:(OrtcClient *)ortc channel:(NSString *)channel {
    
}

- (void) startGame:(NSString*) gameId {
    NSString* startText = [NSString stringWithFormat:@"{ \"op\" : \"start\",\"id\" : \"%@\", \"map\" : %@, \"startTime\" : %lld }",[GameData localPlayer].gameId,[GameData currentGame].map,[GameData currentGame].localStartTime];
    startText = [startText stringByReplacingOccurrencesOfString:@"(" withString:@"["];
    startText = [startText stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    [self send:gameId :startText];
}

- (void) accept {
    NSString* acceptText = [NSString stringWithFormat:@"{ \"op\" : \"accepted\",\"id\" : \"%@\" }",[GameData localPlayer].gameId];
    Game* currentGame = [GameData currentGame];
    [self send:currentGame.challenge.playerB.gameId :acceptText];
}

@end