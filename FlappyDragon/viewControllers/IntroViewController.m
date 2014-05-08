//
//  IntroViewController.m
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "IntroViewController.h"
#import "StorageManager.h"
#import "GameData.h"
#import "RootViewController.h"


#define kKEYBOARD_OFFSET 50

@interface IntroViewController ()

@end

@implementation IntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[_nickNameTextField setFont:[UIFont fontWithName:@"Floraless" size:16]];
	
	[_nickLabel setFont:[UIFont fontWithName:@"Floraless" size:16]];
	_nickLabel.minimumScaleFactor = 0.5;
	_nickLabel.adjustsFontSizeToFitWidth = YES;
	_nickLabel.textColor = TEXT_SHADOW_COLOR;
	_nickLabel.shadowColor = TEXT_COLOR;
	_nickLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	
	[_startBtt.titleLabel setFont:[UIFont fontWithName:@"Floraless" size:16]];
	_startBtt.titleLabel.minimumScaleFactor = 0.5;
	_startBtt.titleLabel.textColor = TEXT_SHADOW_COLOR;
	_startBtt.titleLabel.shadowColor = TEXT_COLOR;
	_startBtt.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	[_startBtt setBackgroundImage:[[UIImage imageNamed:@"btn_orange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)]
						 forState:UIControlStateNormal];
	
	_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	_activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y * 0.50);
	_activityIndicator.color = [UIColor colorWithRed:(255/255.0) green:(135/255.0) blue:0 alpha:1.0];
	_activityIndicator.hidesWhenStopped = YES;
	[self.view addSubview:_activityIndicator];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	//[self registerForKeyboardNotifications];
}

- (void) viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	[self unregisterForKeyboardNotifications];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	if ([touch view] == self.view) {
		[_nickNameTextField becomeFirstResponder];
		[_nickNameTextField resignFirstResponder];
	}
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	return YES;
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
    NSUInteger newLength = [textField.text length] - range.length + [string length];
	BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
	
	if (newLength <= 14) {
		return YES;
	}
	else {
		return returnKey;
	}
}


#pragma mark - Keyboard Control

- (void) registerForKeyboardNotifications
{
	
	// register for keyboard notifications
	NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    _keyboardIsShown = NO;
	
}

- (void) unregisterForKeyboardNotifications {
	
	// unregister for keyboard notifications while not visible.
	NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void) keyboardWillHide:(NSNotification *) notification
{
	[UIView animateWithDuration:0.20 animations:^{
		_contentView.transform = CGAffineTransformMakeTranslation(0, 0);
	} completion:^(BOOL finished) {
		_keyboardIsShown = NO;
	}];
}


- (void) keyboardWillShow:(NSNotification *) notification
{
	if (_keyboardIsShown) {
        return;
    }
	_keyboardIsShown = YES;
	[UIView animateWithDuration:0.25 animations:^{
		_contentView.transform = CGAffineTransformMakeTranslation(0, - kKEYBOARD_OFFSET);
	} completion:nil];
}


#pragma mark - Actions

- (IBAction) insertNickName:(id)sender {
	
	[_nickNameTextField resignFirstResponder];
    [GameData localPlayer].nickname = _nickNameTextField.text;
	if ([[GameData localPlayer].nickname length] < 3) {
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please Insert a nickName" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
	}
	else {
		[_activityIndicator startAnimating];
		[GameData localPlayer].gameId = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [GameData getPlayer:[GameData localPlayer].nickname  :^(DragonPlayer *player, NSError *error) {
            
			if (player == nil && error == nil){
				[[GameData localPlayer] save:^(NSError *error) {
                    if(error == nil){
                        [AppDelegate transitionToViewController:[AppDelegate rootViewController]];
						
                    }else{
                        //NSLog(@"### Error: insertNickName %@", [error localizedDescription]);
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Error saving nickname!\nPlease try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alertView show];
                    }
					[_activityIndicator stopAnimating];
                }];
            }else if(player != nil){
				[_activityIndicator stopAnimating];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Nickname already exists!\nPlease try another one" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alertView show];
            } else {
				[_activityIndicator stopAnimating];
                //NSLog(@"### Error: insertNickName %@", [error localizedDescription]);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Error saving nickname!\nPlease try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alertView show];
            }
			[_activityIndicator stopAnimating];
		}];
	}
}


@end

