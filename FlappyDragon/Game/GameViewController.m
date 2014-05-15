//
//  GameViewController.m
//  FlappyDragon
//
//  Created by Nathan Borror on 2/5/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "OrtcClient.h"

@implementation GameViewController {
    GameScene* scene;
}

- (void)loadView
{
	self.view  = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
}

- (void) viewDidLoad {
	[super viewDidLoad];
}


- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
	SKView *skView = (SKView *)[self view];
	[skView setShowsFPS:NO];
	[skView setShowsNodeCount:NO];
	
    //NSLog(@"Bounds: h %f w %f",skView.bounds.size.height,skView.bounds.size.width);
    
	//GameScene *scene = [GameScene sceneWithSize:skView.bounds.size];
    scene = [GameScene sceneWithSize:CGSizeMake(320.0, 480.0)];
	[scene setScaleMode:SKSceneScaleModeAspectFill];
	scene.name = @"GameScene";

	[skView presentScene:scene];
}

@end

