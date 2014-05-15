//
//  AdUnit.h
//  WebSpectatorMobile
//
//  Created by iOSdev on 14/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdUnit : NSObject

@property BOOL visible;
@property int zoneId;
@property NSString *unitID;
@property NSString *bannerID;
@property NSString *campaingID;


- (id) initWithPLaceholder:(NSObject *) adUnit AndZone:(int) zone;
- (void) changeBanner:(NSString *) bannerURL;
- (void) loadScript:(NSString *) script;
- (void) loadHTML:(NSString *)htmlString;
- (void) destroy;






@end