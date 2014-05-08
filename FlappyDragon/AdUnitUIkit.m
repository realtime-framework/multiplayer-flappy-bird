//
//  AdUnitUIkit.m
//  WebSpectatorMobile
//
//  Created by iOSdev on 14/03/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <objc/runtime.h>
#import "AdUnitUIkit.h"
#import "WebSpectatorClient.h"

@interface AdUnitUIkit ()

@property UIImageView *placeHolder;
@property (nonatomic)  NSTimer *timer;
@property (nonatomic)  int timerCount;

@end
	
	
@implementation AdUnitUIkit

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id) initWithPLaceholder:(UIImageView *) adUnit AndZone:(int) zone {
	
	if (![adUnit isKindOfClass:[UIImageView class]]) {
		[self doesNotRecognizeSelector:_cmd];
		return nil;
	} else {
		self = [super init];
		if (self) {
			
			self.placeHolder = adUnit;
			self.zoneId = zone;
			self.unitID = [WebSpectatorClient generateRandomString:8];
			[self start];
		}
		return self;
	}
}


- (void) start {
	
	_timerCount = 0;
	_timer = [NSTimer scheduledTimerWithTimeInterval:3.3 target:self selector:@selector(checkVisibility) userInfo:nil repeats:YES];
}


- (void) stopTimer {
	
	[_timer invalidate];
	_timer = nil;
}


/*
 - (void)didAddSubview:(UIView *)subview
 - (void)willMoveToSuperview:(UIView *)newSuperview
 - (void)willMoveToWindow:(UIWindow *)newWindow
*/

- (void) checkVisibility {
	
	/*
	check view.hidden
    check hierarchy, checking view.superview == nil
    check the bounds of a view to see if it is on screen
	*/
	
	
	// [[self.placeHolder.layer presentationLayer] frame];
	
	
	_timerCount ++;
	
	BOOL visible = self.visible;
	
	UIView *view = self.placeHolder.superview;
	CGRect placeHolderGlobalFrame = [self.placeHolder convertRect:[[self.placeHolder.layer presentationLayer] frame] toView:self.placeHolder];
	while (view != nil) {
		placeHolderGlobalFrame = [view convertRect:placeHolderGlobalFrame toView:view.superview];
		view = view.superview;
	}
	if (!self.placeHolder.hidden) {
		
		
		visible = CGRectIntersectsRect (placeHolderGlobalFrame, [[UIScreen mainScreen] bounds]);
		if (visible) {
			//visible = [self checkSuperViewVisibility];
		}
	}
	
	else {
		visible = NO;
	}
	if ([self.placeHolder.subviews count] > 1) {
		visible = NO;
	}
	
	if (visible != self.visible) {
		[WebSpectatorClient visibility:self];
	}
	
	self.visible = visible;
}

- (BOOL) checkSuperViewVisibility {
	
	BOOL visible = self.visible;
	UIView *view = self.placeHolder.superview;
	
	CGRect placeHolderGlobalFrame = [self.placeHolder convertRect:[[self.placeHolder.layer presentationLayer] frame] toView:self.placeHolder];
	while (view != nil) {
		placeHolderGlobalFrame = [view convertRect:placeHolderGlobalFrame toView:view.superview];
		view = view.superview;
	}
	
	view = self.placeHolder;
	while (view.superview != nil && ![view.superview isKindOfClass:[UIWindow class]]) {
		view = view.superview;
		
		for (UIView *superSubView in [view subviews]) {
			if (superSubView != self.placeHolder && superSubView != self.placeHolder.superview) {
				
				CGRect superSubViewGlobalFrame = [superSubView convertRect:superSubView.frame toView:superSubView];
				UIView *subSuperView = superSubView.superview;
				while (subSuperView != nil) {
					superSubViewGlobalFrame = [subSuperView convertRect:superSubViewGlobalFrame toView:subSuperView.superview];
					subSuperView = subSuperView.superview;
				}
				
				if (CGRectIntersectsRect (placeHolderGlobalFrame, superSubViewGlobalFrame)) {
					
					if (superSubView.alpha != 0) {
						visible = NO;
						break;
					}
				}
			}
		}
	}
	return visible;
}


- (void) changeBanner:(NSString *) bannerURL {

	[AdUnitUIkit imageWithURLString:bannerURL andBlock:^(UIImage *image) {
		if (image) {
			[self.placeHolder setImage:image];
		}
	}];
}

- (void) setBannerImage:(UIImage *) image {
	
	if ([_placeHolder isKindOfClass:[UIImageView class]]) {
		[_placeHolder setImage:image];
	}
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
