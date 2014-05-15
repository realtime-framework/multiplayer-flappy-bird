//
//  AdUnit.m
//  WebSpectatorMobile
//
//  Created by iOSdev on 14/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "AdUnit.h"

@implementation AdUnit

- (id)init
{
	if (![self isKindOfClass:[AdUnit class]]) {
		[self doesNotRecognizeSelector:_cmd];
		return nil;
	} else {
		self = [super init];
		if (self) {
		}
		return self;
	}
}

- (id) initWithPLaceholder:(NSObject *) adUnit AndZone:(int) zone {
	
	if (![self isMemberOfClass:[AdUnit class]]) {
		[self doesNotRecognizeSelector:_cmd];
		return nil;
	} else {
		self = [super init];
		if (self) {
		}
		return self;
	}
}


- (void) changeBanner:(NSString *) bannerURL {
	[self doesNotRecognizeSelector:_cmd];
}

- (void) loadScript:(NSString *) script {
	[self doesNotRecognizeSelector:_cmd];
}

- (void) loadHTML:(NSString *)htmlString {
	[self doesNotRecognizeSelector:_cmd];
}

- (void) destroy{
    [self doesNotRecognizeSelector:_cmd];
}

@end