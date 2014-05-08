//
//  WebSpectatorClient.m
//  WebSpectatorMobile
//
//  Created by iOSdev on 14/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebSpectatorClient.h"
#import "OrtcClient.h"


#define COMMUNICATION_SERVER @"http://ortc-developers.realtime.co/server/ssl/2.1"
#define COMMUNICATION_AUTH_TOKEN @"AS.Anonymous"

#define COMMUNICATION_APP_KEY @"Q1siLe"
#define CONNECTION_METADATA @"__CONNECTION_METADATA__"

#define WS_VERSION @"2.2"

#define WS_SESSION_ID_KEY @"WS_SESSION_ID_KEY"
#define WS_CONTEXT_ID_KEY @"WS_CONTEXT_ID_KEY"



@interface WebSpectatorClient ()

+ (NSString *) clientName;
+ (void) setClientName:(NSString *) name;

+ (NSString *) clientId;
+ (void) setClientId:(NSString *) cId;

+ (OrtcClient *) messagingClient;
+ (void) setMessagingClient:(NSString *) cId;
+ (NSMutableArray *) messagesBuffer;
+ (NSMutableDictionary *)adUnits;
+ (NSMutableArray *)channels;

+ (NSString *) ws_session_id;
+ (NSString *) ws_context_id;
+ (NSString *) wsChannel_send;
+ (NSString *) wsChannel_receive;

+ (NSTimer *) timer;
+ (int) timerCounter;

@end


@implementation WebSpectatorClient


static NSString *clientName;
static NSString *clientId;

static OrtcClient *messagingClient;
static NSMutableArray *messagesBuffer;
static NSMutableDictionary *adUnits;
static NSMutableArray *channels;

static NSString *ws_session_id;
static NSString *ws_context_id;
static NSString *wsChannel_send;
static NSString *wsChannel_receive;

static NSTimer *timer;
static int timerCounter;


#pragma mark - Start

- (id)init
{
	@throw [NSException exceptionWithName:@"not allowed" reason:@"WebSpectatorClient initialization is not allowed" userInfo:nil];
}

+ (void) startWebSpectatorClientWhitClientName:(NSString *) clientName AndId:(NSString *) clientId {
	
	[WebSpectatorClient setClientName:clientName];
	[WebSpectatorClient setClientId:clientId];
	[WebSpectatorClient startMessaging];
}


+ (void) startMessaging
{
	MessagingDelegate *messagingDelegate = [[MessagingDelegate alloc] init];
	
	messagingClient = [OrtcClient ortcClientWithConfig:messagingDelegate];
	[messagingClient setConnectionTimeout:10];
	[messagingClient setClusterUrl:COMMUNICATION_SERVER];
	
	//NSLog(@"Connecting to: %@", COMMUNICATION_SERVER);
	[messagingClient connect:COMMUNICATION_APP_KEY authenticationToken:COMMUNICATION_AUTH_TOKEN];
	
	adUnits = [[NSMutableDictionary alloc] init];
	messagesBuffer = [[NSMutableArray alloc] init];
	channels = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:[WebSpectatorClient class] selector:@selector(applicationNotification:) name:@"applicationWillResignActive" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:[WebSpectatorClient class] selector:@selector(applicationNotification:) name:@"applicationDidBecomeActive" object:nil];
	
	ws_session_id = [[NSString alloc] initWithString:[WebSpectatorClient generateRandomString:16]];
	ws_context_id = [[NSString alloc] initWithString:[WebSpectatorClient generateRandomString:4]];
	
	NSString *session_id = [[NSUserDefaults standardUserDefaults] objectForKey:WS_SESSION_ID_KEY];
	NSString *context_id = [[NSUserDefaults standardUserDefaults] objectForKey:WS_CONTEXT_ID_KEY];
	
	if (session_id != nil) {
		ws_session_id = [[NSString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:WS_SESSION_ID_KEY]];
	}
	else {
		ws_session_id = [[NSString alloc] initWithString:[WebSpectatorClient generateRandomString:16]];
		[[NSUserDefaults standardUserDefaults] setObject:ws_session_id forKey:WS_SESSION_ID_KEY];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	if (context_id != nil) {
		ws_context_id = [[NSString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:WS_CONTEXT_ID_KEY]];
	}
	else {
		ws_context_id = [[NSString alloc] initWithString:[WebSpectatorClient generateRandomString:4]];
		
		[[NSUserDefaults standardUserDefaults] setObject:ws_context_id forKey:WS_CONTEXT_ID_KEY];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	
	wsChannel_send = [NSString stringWithFormat:@"fromClient:%@",clientName];

	wsChannel_receive = [NSString stringWithFormat:@"toClient:%@:%@",ws_session_id, ws_context_id];
	[WebSpectatorClient subscribeChannel:wsChannel_receive];
}



+ (NSString *) clientName {
	return clientName;
}
+ (void) setClientName:(NSString *) name {
	clientName = name;
}

+ (NSString *) clientId {
	return clientId;
}
+ (void) setClientId:(NSString *) cId {
	clientId = cId;
}

+ (OrtcClient *) messagingClient {
	return messagingClient;
}
+ (void) setMessagingClient:(OrtcClient *) orctClient {
	messagingClient = orctClient;
}

+ (NSMutableArray *) messagesBuffer {
	return messagesBuffer;
}
+ (void) setMessagesBuffer:(NSMutableArray *) buffer {
	messagesBuffer = buffer;
}

+ (NSMutableDictionary *)adUnits {
	return adUnits;
}

+ (void) setAdUnits:(NSMutableDictionary *) units {
	adUnits = units;
}

+ (NSMutableArray *)channels {
	return channels;
}

+ (void) setChannels:(NSMutableArray *) chs {
	channels = chs;
}

+ (NSString *) ws_session_id {
	return ws_session_id;
}

+ (void) setWs_session_id:(NSString *) session_id {
	ws_session_id = session_id;
}

+ (NSString *) ws_context_id {
	return ws_context_id;
}
+ (void) setWs_context_id:(NSString *) ctxId {
	ws_context_id = ctxId;
}


+ (NSString *) wsChannel_send {
	return wsChannel_send;
}

+ (void) setWsChannel_send:(NSString *) channel_send {
	wsChannel_send = channel_send;
}

+ (NSString *) wsChannel_receive {
	return wsChannel_receive;
}

+ (void) setWsChannel_receive:(NSString *) channel_receive {
	wsChannel_receive = channel_receive;
}

+ (NSTimer *) timer {
	return timer;
}
+ (void) setTimer:(NSTimer *) tm {
	timer = tm;
}

+ (int) timerCounter {
	return timerCounter;
}

+ (void) setTimerCounter:(int) count {
	timerCounter = count;
}


#pragma mark - AdUnits

+ (void) putAdUnit:(AdUnit *) adUnit {
	
	[adUnits setObject:adUnit forKey:adUnit.unitID];
	[WebSpectatorClient makeCBRequestForAdUnit:adUnit];
}


+ (void) deleteAdUnit:(AdUnit *) adUnit {
	NSString *unitID = adUnit.unitID;
	[adUnits removeObjectForKey:unitID];
}


+ (void) stopAllAdUnits {
	[adUnits removeAllObjects];
	[WebSpectatorClient stopTimer];
}


+ (void) visibility:(AdUnit *) adUnit {
	
	//chage visibility in dictionary
	[WebSpectatorClient makeStateUpdate:adUnit];
}


+ (void) startTimer {
	
	if (timer == nil) {
		timerCounter = 0;
		timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(sendStates) userInfo:nil repeats:YES];
	}
}

+ (void) stopTimer {
	[timer invalidate];
	timer = nil;
}


+ (void) sendStates {
	
	timerCounter ++;
	
	[self sendAllStateUpdate];
}



#pragma mark MESSAGING

+ (void) subscribeChannel:(NSString *) channelName {
	
	if ([channelName length] > 0) {
		if ([messagingClient isConnected]) {
			
			[messagingClient subscribe:channelName subscribeOnReconnected:YES onMessage:^(OrtcClient *ortc, NSString *channel, NSString *message) {
				//NSLog(@"RECEIVE: %@ | %@", message, channel);
				[WebSpectatorClient jsonParse:message :^(NSDictionary *jsonDict, NSError *error) {
					if(error == nil) {
						
						NSString* operation = [jsonDict objectForKey:@"a"];
						
						if ([operation isEqualToString:@"cbresp"]) {
							[WebSpectatorClient processCBResponse:[jsonDict objectForKey:@"d"]];
						}
						if ([operation isEqualToString:@"cb"]) {
							[WebSpectatorClient processCB:jsonDict];
						}
					}
				}];
			}];
		}
		else {
			[channels addObject:channelName];
		}
	}
}


+ (void) sendMessage:(NSString *)msg ToChannel:(NSString *) channel {
	
	@try {
		if(messagingClient != nil && [messagingClient isConnected]){
			
			//NSLog(@"SEND: %@ : %@", channel, msg);
            [messagingClient send:channel message:msg];
        }
		else{
            NSDictionary* messageBuffered = [[NSDictionary alloc] initWithObjectsAndKeys:channel,@"channel", msg, @"message", nil];
            [messagesBuffer addObject:messageBuffered];
        }
    }
    @catch (NSException *exception) {
        //NSLog(@"Failed to send message : %@",exception.reason);
        NSDictionary* messageBuffered = [[NSDictionary alloc] initWithObjectsAndKeys:channel,@"channel", msg, @"message", nil];
        [messagesBuffer addObject:messageBuffered];
	}
}

- (void) unSubscribeChannelWithName:(NSString *) channelName {
    
    [messagingClient unsubscribe:channelName];
}

+ (void) emptyMessagesBuffer {
	
	if (messagesBuffer.count > 0) {
		
		while(messagesBuffer.count > 0){
			
			NSDictionary* messageDic = [messagesBuffer objectAtIndex:0];
			NSString *channel = [messageDic objectForKey:@"channel"];
			NSString *message = [messageDic objectForKey:@"message"];
			[messagesBuffer removeObjectAtIndex:0];
			
			[WebSpectatorClient sendMessage:message ToChannel:channel];
		}
	}
}


#pragma mark - WebSpectator

+ (void) makeStateUpdate:(AdUnit *) adunit {

	NSString *version = WS_VERSION;
	NSString *su = @"su";
	NSString *appid = clientId;
	NSString *sessionid = ws_session_id;
	NSString *contextid = ws_context_id;
	
	NSString *timestamp = [NSString stringWithFormat:@"%lld",[WebSpectatorClient getCurrentDate]];
	
	NSString *zones = [NSString stringWithFormat:@"%d", adunit.zoneId];
	
	NSString *banners = @"";
	if ([adunit.bannerID length] > 0) {
		banners = adunit.bannerID;
	}
	
	NSString *campaigns = @"";
	if ([adunit.campaingID length] > 0) {
		campaigns = adunit.campaingID;
	}
	
	NSString *client_state = @"1";
	NSString *country_code = @"";
	NSString *ip = @"";
	NSString *user_agent = @"";
	
	NSString *msgSU = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@",
					   version,su,appid,sessionid,contextid,timestamp,zones,banners,campaigns,client_state,country_code,ip,user_agent];
	
	[WebSpectatorClient sendMessage:msgSU ToChannel:wsChannel_send];
}



+ (void) sendAllStateUpdate {
	
	//iterar por todos ad units e enviar todos visiveis
	
	NSString *version = WS_VERSION;
	NSString *su = @"su";
	NSString *appid = clientId;
	NSString *sessionid = ws_session_id;
	NSString *contextid = ws_context_id;
	
	NSString *timestamp = [NSString stringWithFormat:@"%lld",[WebSpectatorClient getCurrentDate]];
	
	NSString *zones = @"";
	NSString *banners = @"";
	NSString *campaigns = @"";
	NSString *client_state = @"1";
	
	NSString *country_code = @"";
	NSString *ip = @"";
	NSString *user_agent = @"";
	
	
	for (NSString *key in adUnits) {
		AdUnit *adUnit = [adUnits objectForKey:key];
		
		if (adUnit.visible) {
			if ([[@(adUnit.zoneId) stringValue] length] > 0) {
				
				if ([zones length] > 0) {
					zones = [NSString stringWithFormat:@"%@,%@", zones, [@(adUnit.zoneId) stringValue]];
				}
				else {
					zones = [NSString stringWithFormat:@"%@", [@(adUnit.zoneId) stringValue]];
				}
			}
			if ([adUnit.bannerID length] > 0) {
				
				if ([banners length] > 0) {
					banners = [NSString stringWithFormat:@"%@,%@", banners, adUnit.bannerID];
				}
				else {
					banners = [NSString stringWithFormat:@"%@", adUnit.bannerID];
				}
			}
			if ([adUnit.campaingID length] > 0) {
				
				if ([campaigns length] > 0) {
					campaigns = [NSString stringWithFormat:@"%@,%@", campaigns, adUnit.campaingID];
				}
				else {
					campaigns = [NSString stringWithFormat:@"%@", adUnit.campaingID];
				}
			}
		}
	}
	
	NSString *msgSU = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@",
					   version,su,appid,sessionid,contextid,timestamp,zones,banners,campaigns,client_state,country_code,ip,user_agent];
	
	[WebSpectatorClient sendMessage:msgSU ToChannel:wsChannel_send];
}


+ (void) makeCBRequestForAdUnit:(AdUnit *) adUnit {
	
	NSString *version = WS_VERSION;
	NSString *cbreq = @"cbreq";
	NSString *appid = clientId;
	NSString *sessionid = ws_session_id;
	NSString *contextid = ws_context_id;
	NSString *zoneid = [NSString stringWithFormat:@"%d", adUnit.zoneId];
	
	NSString *bannerid = @"";
	if ([adUnit.bannerID length] > 0) {
		bannerid = adUnit.bannerID;
	}
	
	bannerid = @"";
	
	NSString *script = @"";
	NSString *mode = @"raw";
	NSString *meta = @"";
	NSString *state = @"1";
	NSString *ip = @"";
	NSString *user_agent = @"";
	NSString *country_code = @"";
	NSString *region = @"";
	NSString *domain = @"";
	
	NSString *msgRequest = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@",version,cbreq,appid,sessionid,contextid,zoneid,bannerid,script,mode,meta,state,ip,user_agent,country_code, region,domain];
	
	//send Message
	[WebSpectatorClient sendMessage:msgRequest ToChannel:wsChannel_send];
	
}


+ (void) processCBResponse:(NSDictionary *) userInfo {
	
	NSString *zoneID = [userInfo objectForKey:@"zone"];
	NSString *bannerID = @"";
	NSString *bannerWidth = @"";
	NSString *bannerHeight = @"";
	NSString *bannerURL = @"";
	NSString *campaignID = @"";
	
	CGSize bannerSize = CGSizeZero;
	
	if ([[userInfo objectForKey:@"content"] length] > 0) {
		
		NSArray *responseContent = [[userInfo objectForKey:@"content"] componentsSeparatedByString:@"|"];
		
		if ([responseContent count] > 0) {
			
			float floatBannerWidth = 0;
			float floatBannerHeight = 0;
			
			if ([responseContent objectAtIndex:0]) {
				bannerID = [responseContent objectAtIndex:0];
			}
			if ([responseContent objectAtIndex:1]) {
				bannerWidth = [responseContent objectAtIndex:1];
				floatBannerWidth = [bannerWidth floatValue];
			}
			if ([responseContent objectAtIndex:2]) {
				bannerHeight = [responseContent objectAtIndex:2];
				floatBannerHeight = [bannerHeight floatValue];
			}
			if ([responseContent objectAtIndex:3]) {
				bannerURL = [responseContent objectAtIndex:3];
			}
			if ([responseContent objectAtIndex:4]) {
				campaignID = [responseContent objectAtIndex:4];
			}
			bannerSize = CGSizeMake(floatBannerWidth, floatBannerHeight);
		}
	}

	for (NSString *key in adUnits) {
		AdUnit *adUnit = [adUnits objectForKey:key];
		if ([[@(adUnit.zoneId) stringValue] isEqualToString:zoneID]) {
			adUnit.bannerID = bannerID;
			adUnit.campaingID = campaignID;
			
			if ([bannerURL length] > 0) {
				//[adUnit changeBanner:bannerURL ForAdUnit:adUnit WithSize:bannerSize];
				[adUnit changeBanner:bannerURL];
			}
			break;
		}
	}
}


+ (void) processCB:(NSDictionary *) infoDict {
	
	NSString *zoneID = [[[infoDict objectForKey:@"d"] objectForKey:@"z"] stringValue];
	
	for (NSString *key in adUnits) {
		
		
		
		AdUnit *adUnit = [adUnits objectForKey:key];
		if ([[@([adUnit zoneId]) stringValue] isEqualToString:zoneID]) {
			
			[WebSpectatorClient makeCBRequestForAdUnit:[adUnits objectForKey:key]];
			break;
		}
	}
}


#pragma mark NSNotificationCenter

+ (void) applicationNotification:(NSNotification *)notification {
	
	if ([[notification name] isEqual:@"applicationWillResignActive"]) {
		
		[WebSpectatorClient stateUpdateBeforeBG];
	}
	if ([[notification name] isEqual:@"applicationDidBecomeActive"]) {
		//[WebSpectatorClient sendAllStateUpdate];
	}
}


+ (void) stateUpdateBeforeBG {
	
	//iterar por todos ad units e enviar todos visiveis
	
	NSString *version = WS_VERSION;
	NSString *su = @"su";
	NSString *appid = clientId;
	NSString *sessionid = ws_session_id;
	NSString *contextid = ws_context_id;
	
	NSString *timestamp = [NSString stringWithFormat:@"%lld",[self getCurrentDate]];
	
	NSString *zones = @"";
	NSString *banners = @"";
	NSString *campaigns = @"";
	NSString *client_state = @"0";
	
	NSString *country_code = @"";
	NSString *ip = @"";
	NSString *user_agent = @"";
	
	for (AdUnit *adUnit in adUnits) {
		if ([adUnit.campaingID length] > 0) {
			if ([campaigns length] > 0) {
				campaigns = [NSString stringWithFormat:@"%@,%@", campaigns, adUnit.campaingID];
			}
			else {
				campaigns = [NSString stringWithFormat:@"%@", adUnit.campaingID];
			}
		}
	}
	
	NSString *msgSU = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@|%@",
					   version,su,appid,sessionid,contextid,timestamp,zones,banners,campaigns,client_state,country_code,ip,user_agent];
	
	[self sendMessage:msgSU ToChannel:wsChannel_send];
}


#pragma mark UTILS

+ (void) jsonParse:(NSString*) text :(void (^)(NSDictionary* jsonDict, NSError* error)) callback {
	
	NSError *error = nil;
	NSData *jsonData = [text dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if(error){
        callback(nil,error);
    }else{
        callback(json,nil);
    }
}


+ (long long) getCurrentDate {
	
	return [[NSDate date] timeIntervalSince1970] * 1000;
}


+ (NSString *) generateRandomString:(int)num {
	
	NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

@end



@interface MessagingDelegate ()

@end

@implementation MessagingDelegate

#pragma mark ORTC Delegation

- (void) onConnected:(OrtcClient *) ortc
{
	//NSLog(@"Connected to: %@", ortc.url);
	//NSLog(@"Session Id: %@", ortc.sessionId);
	
	for (NSString *ch in WebSpectatorClient.channels) {
		[WebSpectatorClient subscribeChannel:ch];
	}
	[WebSpectatorClient emptyMessagesBuffer];
	[WebSpectatorClient startTimer];
}

- (void) onDisconnected:(OrtcClient *) ortc
{
	//NSLog(@"Disconnected");
}

- (void) onReconnecting:(OrtcClient *) ortc
{
	//NSLog(@"Reconnecting to: %@", ortc.url);
}

- (void) onReconnected:(OrtcClient *) ortc
{
    //NSLog(@"Reconnected to: %@", ortc.url);
}

- (void) onSubscribed:(OrtcClient *) ortc channel:(NSString*) channel
{
	//NSLog(@"Subscribed to: %@", channel);
	[WebSpectatorClient.channels removeObject:channel];
}

- (void) onUnsubscribed:(OrtcClient *) ortc channel:(NSString*) channel
{
    //NSLog(@"Unsubscribed from: %@", channel);
	[WebSpectatorClient.channels removeObject:channel];
}

- (void) onException:(OrtcClient *) ortc error:(NSError*) error
{
    //NSLog(@"Exception [Code:%ld]: %@", (long)[error code], error.localizedDescription);
}

@end


