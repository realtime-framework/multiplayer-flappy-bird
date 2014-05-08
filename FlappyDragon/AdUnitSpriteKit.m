//
//  AdUnitSpriteKit.m
//  testWS
//
//  Created by iOSdev on 18/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "AdUnitSpriteKit.h"
#import <objc/runtime.h>
#import "WebSpectatorClient.h"

@interface AdUnitSpriteKit ()

@property SKSpriteNode *placeHolder;
@property (nonatomic)  NSTimer *timer;
@property (nonatomic)  int timerCount;

@end

@implementation AdUnitSpriteKit

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id) initWithPLaceholder:(SKSpriteNode *) node AndZone:(int) zone {
	
	if (![node isKindOfClass:[SKNode class]]) {
		[self doesNotRecognizeSelector:_cmd];
		return nil;
	} else {
		self = [super init];
		if (self) {
			self.placeHolder = node;
			self.zoneId = zone;
			[self start];
		}
		return self;
	}
}


- (void) start {
	
	self.unitID = [WebSpectatorClient generateRandomString:8];
	_timerCount = 0;
	_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkVisibility) userInfo:nil repeats:YES];
}


- (void) stopTimer {
	
	[_timer invalidate];
	_timer = nil;
}

- (void) checkVisibility {
	
	_timerCount ++;
	
	CGPoint nodePos = self.placeHolder.position;
	
	BOOL visible = self.visible;
	if (!self.placeHolder.hidden) {
		
		SKNode *pNode = self.placeHolder.parent;
		CGPoint positionInScene = [self.placeHolder convertPoint:self.placeHolder.position toNode:self.placeHolder.parent];
		
		if ([pNode isMemberOfClass:[SKNode class]]) {
			
			positionInScene = [self.placeHolder convertPoint:self.placeHolder.position toNode:self.placeHolder.parent];
			
			while (pNode != nil && [pNode isMemberOfClass:[SKNode class]]) {
				positionInScene = [pNode convertPoint:pNode.frame.origin toNode:pNode.parent];
				pNode = pNode.parent;
			}
		}
		CGRect placeHolderGlobalFrame = CGRectMake(positionInScene.x, positionInScene.y, self.placeHolder.frame.size.width, self.placeHolder.frame.size.height);
		
		placeHolderGlobalFrame.origin.x /= [[UIScreen mainScreen] scale];
		placeHolderGlobalFrame.origin.y /= [[UIScreen mainScreen] scale];
		
		visible = CGRectIntersectsRect (placeHolderGlobalFrame, [[UIScreen mainScreen] bounds]);
		
	}
	else {
		visible = NO;
	}
	if ([self.placeHolder.children count] > 1) {
		visible = NO;
	}
	
	self.visible = visible;
}


- (void) changeBanner:(NSString *) bannerURL {
	
	[AdUnitSpriteKit imageWithURLString:bannerURL andBlock:^(UIImage *image) {
		if (image) {
			self.placeHolder.texture = [SKTexture textureWithImage:image];
		}
	}];
}



+ (void) imageWithURLString:(NSString *)urlString andBlock:(void (^)(UIImage *imageData)) processImage
{
	dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
	dispatch_async(backgroundQueue, ^{
		NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
		UIImage *image = [UIImage imageWithData:imageData];
		if (image) {
			dispatch_sync(dispatch_get_main_queue(), ^{
				if (processImage) {
					processImage (image);
				}
			});
		}
		else {
			if (processImage) {
				processImage (nil);
			}
		}
	});
}

- (void) destroy {
    [self stopTimer];
}


@end
