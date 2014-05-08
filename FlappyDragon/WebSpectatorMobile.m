//
//  WebSpectatorMobile.m
//  WebSpectatorMobile
//
//  Created by iOSdev on 15/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "WebSpectatorMobile.h"
#import "WebSpectatorClient.h"

@implementation WebSpectatorMobile

+ (void) startWebSpectatorClientWhitClientName:(NSString *) clientName AndId:(NSString *) clientId {
	
	[WebSpectatorClient startWebSpectatorClientWhitClientName:clientName AndId:clientId];
}

+ (void) putAdUnit:(AdUnit *) adUnit {
	[WebSpectatorClient putAdUnit:adUnit];
}


+ (void) deleteAdUnit:(AdUnit *) adUnit {
    [adUnit destroy];
	[WebSpectatorClient deleteAdUnit:adUnit];
}

@end