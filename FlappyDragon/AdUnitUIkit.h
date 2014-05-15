//
//  AdUnitUIkit.h
//  WebSpectatorMobile
//
//  Created by iOSdev on 14/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdUnit.h"

@interface AdUnitUIkit : AdUnit

- (id) initWithPLaceholder:(UIView *) adUnit AndZone:(int) zone;
- (void) changeBanner:(NSString *) bannerURL;
- (void) loadScript:(NSString *) script;
- (void) loadHTML:(NSString *)htmlString;

@end
