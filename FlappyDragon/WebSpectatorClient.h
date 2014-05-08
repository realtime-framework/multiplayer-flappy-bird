//
//  WebSpectatorClient.h
//  WebSpectatorMobile
//
//  Created by iOSdev on 14/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrtcClient.h"
#import "AdUnit.h"

@interface WebSpectatorClient : NSObject


+ (void) startWebSpectatorClientWhitClientName:(NSString *) clientName AndId:(NSString *) clientId;

+ (void) putAdUnit:(AdUnit *) adUnit;
+ (void) deleteAdUnit:(AdUnit *) adUnit;
+ (void) stopAllAdUnits;
+ (void) visibility:(AdUnit *) adUnit;

+ (NSString *) generateRandomString:(int)num;

@end

@interface MessagingDelegate : NSObject <OrtcClientDelegate>

@end
