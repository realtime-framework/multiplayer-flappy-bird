//
//  RootViewController.m
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <Social/Social.h>

#import "AdUnit.h"
#import "AdUnitUIkit.h"
#import "WebSpectatorMobile.h"

#import "RootViewController.h"
#import "IntroViewController.h"
#import "PendingChViewController.h"
#import "AvailablePlayersViewController.h"
#import "TopPlayersViewController.h"
#import "WaitingViewController.h"

#import "GameData.h"
#import "AppDelegate.h"
#import "StorageManager.h"

#define kKEYBOARD_OFFSET 130

@interface RootViewController ()

@property DragonPlayer *lastChallengePlayer;
@property BOOL performingDirectChallenge;

@property (nonatomic)  AdUnitUIkit *adUnitView;

@end

@implementation RootViewController

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
	
	_overlayView.backgroundColor = [UIColor clearColor];
	// layer to draw the gradient on
	CAGradientLayer *gradient = [CAGradientLayer layer];
	
	gradient.frame = _overlayView.bounds;
	gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor colorWithWhite:1.0 alpha:0.65] CGColor], (id)[[UIColor colorWithWhite:1.0 alpha:0.0] CGColor], nil];
	
	[_overlayView.layer insertSublayer:gradient atIndex:0];
	
	// add badge whit pending challenges
	CGSize pendigBttSize = _pendingBtt.frame.size;
	UIView *badgeView = [[UIView alloc] initWithFrame:CGRectMake(pendigBttSize.width - 20 * 2, (pendigBttSize.height/2) - 12, 24, 24)];
	// border
	[badgeView setBackgroundColor:[UIColor colorWithRed:(250/255.0) green:(80/255.0) blue:(80/255.0) alpha:0.80]];
	[badgeView.layer setBorderColor:[[UIColor colorWithRed:(250/255.0) green:(20/255.0) blue:(20/255.0) alpha:1.0] CGColor]];
	[badgeView.layer setBorderWidth:1.0];
	// border radius
	[badgeView.layer setCornerRadius:10];
	
	// drop shadow
	[badgeView.layer setShadowColor:[UIColor blackColor].CGColor];
	[badgeView.layer setShadowOpacity:0.8];
	[badgeView.layer setShadowRadius:3.0];
	[badgeView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pendingChallenges:)];
	tapGesture.numberOfTapsRequired = 1;
	[badgeView addGestureRecognizer:tapGesture];
	
	
	_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	_activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y * 0.85);
	_activityIndicator.color = [UIColor colorWithRed:(255/255.0) green:(135/255.0) blue:0 alpha:1.0];
	_activityIndicator.hidesWhenStopped = YES;
	[self.view addSubview:_activityIndicator];
	
	
	_pendingLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 20, 20)];
	_pendingLabel.textAlignment = NSTextAlignmentCenter;
	[_pendingLabel setTextColor:TEXT_COLOR];
	
	//[_pendingLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
	[_pendingLabel setFont:[UIFont fontWithName:@"Floraless" size:12]];
	
    
	[badgeView addSubview:_pendingLabel];
	[_pendingBtt addSubview:badgeView];
	
	[_nickLabel setFont:[UIFont fontWithName:@"Floraless" size:18]];
	[_nickLabel setTextColor:TEXT_COLOR];
	_nickLabel.shadowColor = TEXT_SHADOW_COLOR;
	_nickLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	[_scoreLabel setFont:[UIFont fontWithName:@"Floraless" size:14]];
	[_scoreLabel setTextColor:TEXT_COLOR];
	_scoreLabel.shadowColor = TEXT_SHADOW_COLOR;
	_scoreLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	[_tweetBtt.titleLabel setFont:[UIFont fontWithName:@"Floraless" size:14]];
	[_tweetBtt.layer setCornerRadius:4.0];
	[_pendingBtt.titleLabel setFont:[UIFont fontWithName:@"Floraless" size:14]];
	[_pendingBtt.layer setCornerRadius:4.0];
	[_avPlayersBtt.titleLabel setFont:[UIFont fontWithName:@"Floraless" size:14]];
	[_avPlayersBtt.layer setCornerRadius:4.0];
	[_topPlayersBtt.titleLabel setFont:[UIFont fontWithName:@"Floraless" size:14]];
	[_topPlayersBtt.layer setCornerRadius:4.0];
	
	[_challengeLabel setFont:[UIFont fontWithName:@"Floraless" size:14]];
	[_challengeLabel setTextColor:TEXT_COLOR];
	_challengeLabel.shadowColor = TEXT_SHADOW_COLOR;
	_challengeLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	[_directChallengeTextField setFont:[UIFont fontWithName:@"Floraless" size:16]];
	[_challengeBtt.titleLabel setFont:[UIFont fontWithName:@"Floraless" size:14]];
	[_challengeBtt.layer setCornerRadius:4.0];
	
	[_toastLabel setFont:[UIFont fontWithName:@"Floraless" size:16]];
	_toastLabel.minimumScaleFactor = 0.5;
	_toastLabel.adjustsFontSizeToFitWidth = YES;
	[_toastLabel setText:@""];
	[_toastLabel setTextColor:TEXT_COLOR];
	_toastLabel.shadowColor = TEXT_SHADOW_COLOR;
	_toastLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	_pendingChallengesIDs = [[NSMutableArray alloc] init];
	
	_nickLabel.text = [NSString stringWithFormat:@"Welcome, %@", [[GameData localPlayer] nickname]];
	[_pendingLabel setText:[NSString stringWithFormat:@"%d", [[GameData localPlayer] challenges]]];
	[_toastLabel setText:@""];
	
	
	[_bannerWebView setBackgroundColor:[UIColor clearColor]];
	[_bannerWebView setOpaque:NO];
	_bannerWebView.delegate = self;
}



- (void) viewDidAppear:(BOOL)animated
{
	[_activityIndicator startAnimating];
	
	[super viewDidAppear:animated];
	[self registerForKeyboardNotifications];
    [_toastLabel setText:@""];
    self.performingDirectChallenge = false;
	
	[[[StorageManager sharedManager] storageRef] onReconnected:^(StorageRef *storage) {
        if([GameData localPlayer] != nil){
            [[GameData localPlayer] sync:^(NSError *error) {
                if(error != nil){
                    //NSLog(@"Error syncing local player: %@",error.localizedDescription);
                }else{
                    [[AppDelegate rootViewController].pendingLabel setText:[NSString stringWithFormat:@"%d", [[GameData localPlayer] challenges]]];
                }
            }];
        }
    }];
    
    [GameData communication];
	
	[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkCommunication) userInfo:nil repeats:NO];
	
	
	[[GameData localPlayer] changeStatus:PLAYER_STATE_WAITING :^(NSError *error) {
		if (error != nil) {
			//NSLog(@"SOMe Error chaging Status: %@ - %@", [error localizedDescription], [[GameData localPlayer] toString]);
		}
	}];
	
	[[GameData localPlayer] onChallenge:^(NSString *nickName, NSString *gameId) {
		
		DragonPlayer *challengePlayer = [[DragonPlayer alloc] init];
		challengePlayer.nickname = nickName;
		challengePlayer.gameId = gameId;
		_lastChallengePlayer = challengePlayer;
		
		[_toastLabel setText:[NSString stringWithFormat:@"Player %@ has challenged you!", nickName]];
		
		DragonChallenge *handlerChallenge = [[DragonChallenge alloc] initWhitPlayers:[GameData localPlayer] :challengePlayer];
		[handlerChallenge onDelete:^{
			[_toastLabel setText:@""];
			_lastChallengePlayer = nil;
		}];
	}];
	    
	[[GameData localPlayer] onChange:^{
		[_pendingLabel setText:[NSString stringWithFormat:@"%d", [[GameData localPlayer] challenges]]];
	}];
    
	
	
    [[GameData localPlayer] sync:^(NSError *error) {
		[_activityIndicator stopAnimating];
        if(error != nil){
            //NSLog(@"Error syncing local player: %@",error.localizedDescription);
        }else{
            [[AppDelegate rootViewController].pendingLabel setText:[NSString stringWithFormat:@"%d", [[GameData localPlayer] challenges]]];
			[[AppDelegate rootViewController].scoreLabel setText:[NSString stringWithFormat:@"Your score is: %lld", [[GameData localPlayer] score]]];
		}
    }];
    
	/*
    _adUnitView = [[AdUnitUIkit alloc] initWithPLaceholder:_imageBanner AndZone:BANNER_Z_ID];
	[WebSpectatorMobile putAdUnit:_adUnitView];
	*/

	_adUnitView = [[AdUnitUIkit alloc] initWithPLaceholder:_bannerWebView AndZone:BANNER_Z_ID_2];
	[WebSpectatorMobile putAdUnit:_adUnitView];
	
}


- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self unregisterForKeyboardNotifications];
	
	[[GameData localPlayer] removeOnChallenge];
	[[GameData localPlayer] removeOnChange];
    
    [WebSpectatorMobile deleteAdUnit:_adUnitView];
}



- (void) viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	[_directChallengeTextField resignFirstResponder];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_directChallengeTextField resignFirstResponder];
}

- (void) checkCommunication {
	
	if (![[[GameData communication] client] isConnected]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Connection not available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
	}
}



#pragma mark - Action

- (IBAction)tweetAction:(id)sender {
	
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
		//  Create an instance of the Tweet Sheet
		SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		
		// Sets the completion handler.  Note that we don't know which thread the
		// block will be called on, so we need to ensure that any required UI
		// updates occur on the main queue
		
		tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
			
			switch(result) {
					
					//  This means the user cancelled without sending the Tweet
				case SLComposeViewControllerResultCancelled:
					break;
					
					//  This means the user hit 'Send'
				case SLComposeViewControllerResultDone:
					break;
			}
		};
		
        [GameData getMessage:@"twitter" :^(NSString *resourceMessage, NSError *error) {
			if(error != nil || resourceMessage == nil){
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:nil message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                          delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alertView show];
			}
			else{
                //  Set the initial body of the Tweet
                NSString *message = [NSString stringWithFormat:resourceMessage, [[GameData localPlayer] nickname]];
                [tweetSheet setInitialText:message];
                
                //  Adds an image to the Tweet.  For demo purposes, assume we have an
                if (![tweetSheet addImage:[UIImage imageNamed:@"appIcon.png"]]) {
                }
				
                //  Add an URL to the Tweet.  You can add multiple URLs.
                if (![tweetSheet addURL:[NSURL URLWithString:@"http://twitter.com/"]]){
                }
				
				//  Presents the Tweet Sheet to the user
                [self presentViewController:tweetSheet animated:YES completion:^{
                }];
			}
        }];
	}
    else
    {
		UIAlertView *alertView = [[UIAlertView alloc]
								  initWithTitle:nil message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
								  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
    }
}

- (IBAction)pendingChallenges:(id)sender {
	
	PendingChViewController *pendingChallenges = [[PendingChViewController alloc] initWithNibName:@"PendingChViewController" bundle:nil];
	
	[AppDelegate transitionToViewController:pendingChallenges];
}

- (IBAction)availablePlayers:(id)sender {
	
	AvailablePlayersViewController *availablePlayers = [[AvailablePlayersViewController alloc] initWithNibName:@"AvailablePlayersViewController" bundle:nil];
	
	[AppDelegate transitionToViewController:availablePlayers];
}


- (IBAction)topPlayers:(id)sender {
	
	TopPlayersViewController *topPlayersViewController = [[TopPlayersViewController alloc] initWithNibName:@"TopPlayersViewController" bundle:nil];
	 [AppDelegate transitionToViewController:topPlayersViewController];
}


- (IBAction) directChallenge:(id)sender {
	
	
	if ([_directChallengeTextField.text length] < 3) {
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please insert a NickName" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
	}
	else {
		NSString *playerNickName = [[NSString alloc] initWithString:_directChallengeTextField.text];
		if ([playerNickName isEqualToString:[GameData localPlayer].nickname]) {
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"That's your Nickname" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alertView show];
		}
		else {
            self.performingDirectChallenge = true;
			[GameData getPlayer:playerNickName :^(DragonPlayer *player, NSError *error) {
				if (error != nil) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Error retrieving player data" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[alertView show];
                    self.performingDirectChallenge = false;
                }
				else if (player == nil) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"That Nickname doesn't exist!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[alertView show];
                    self.performingDirectChallenge = false;
				}
				else if ([player.state isEqualToString:PLAYER_STATE_PLAYING]) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@ is not available to play!" , player.nickname] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[alertView show];
                    self.performingDirectChallenge = false;
				}
				else {
					[GameData makeChallenge:[GameData localPlayer] :player :^(DragonChallenge* challenge,NSError *error) {
						if (error != nil) {
							//NSLog(@"Error Direct challenge\nA:\n%@\nB:\n%@\n%@", [[GameData localPlayer] toString], [player toString], [error localizedDescription]);
							
							UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Error challenging player!\nPLease try later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
							[alertView show];
						}
						else {
                            WaitingViewController* waitingViewController = [[WaitingViewController alloc] initWithNibName:@"WaitingViewController" bundle:nil];
                            waitingViewController.challenge = challenge;
							[AppDelegate transitionToViewController:waitingViewController];
						}
                        self.performingDirectChallenge = false;
					}];
				}
			}];
		}
	}
}


#pragma mark - UITextFieldDelegate

/*
 - (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
 return YES;
 }
 
 - (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
 return YES;
 }
 */
/*
 - (void)textFieldDidEndEditing:(UITextField *)textField {
 }
 */

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
		_contentView.transform = CGAffineTransformMakeTranslation(0, -kKEYBOARD_OFFSET);
	} completion:nil];
}


@end


