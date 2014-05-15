//
//  Communication.h
//  FlappyDragon
//
//  Created by admin on 3/12/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrtcClient.h"

@protocol CommunicationDelegate <NSObject>

//@optional
//@required
- (void) start:(NSDictionary *) game;
- (void) tap:(NSDictionary *) tap;
- (void) accepted:(NSDictionary *) gameId;
- (void) lost:(NSDictionary *) lost;
- (void) startEcho;

@end

@interface Communication : NSObject <OrtcClientDelegate> 

#define COMMUNICATION_SERVER @"http://ortc-developers.realtime.co/server/ssl/2.1"
#define COMMUNICATION_AUTH_TOKEN @"FlyingBrands"
#define COMMUNICATION_APP_KEY @"[YOUR_APPLICATION_KEY_HERE]"

@property OrtcClient* client;
@property id <CommunicationDelegate> onAction;

- (void) send:(NSString*) channel :(NSString*) message;
- (void) subscribe:(NSString*) channel;
- (void) startGame:(NSString*) gameId;
- (void) accept;

@end
