//
//  WebSpectatorMobile.h
//  WebSpectatorMobile
//
//  Created by iOSdev on 14/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdUnit.h"

@interface WebSpectatorMobile : NSObject

+ (void) startWebSpectatorClientWhitClientName:(NSString *) clientName AndId:(NSString *) clientId;
+ (void) putAdUnit:(AdUnit *) adUnit;
+ (void) deleteAdUnit:(AdUnit *) adUnit;

@end

