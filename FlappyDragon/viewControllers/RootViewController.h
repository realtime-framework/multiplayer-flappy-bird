//
//  RootViewController.h
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//


@interface RootViewController : UIViewController <UITextFieldDelegate, UIWebViewDelegate>


@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UITextField *directChallengeTextField;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;


@property (weak, nonatomic) IBOutlet UIButton *tweetBtt;
@property (weak, nonatomic) IBOutlet UIButton *pendingBtt;
@property (weak, nonatomic) IBOutlet UIButton *avPlayersBtt;
@property (weak, nonatomic) IBOutlet UIButton *topPlayersBtt;

@property (weak, nonatomic) IBOutlet UILabel *challengeLabel;
@property (weak, nonatomic) IBOutlet UIButton *challengeBtt;

@property (weak, nonatomic) IBOutlet UILabel *toastLabel;

@property (strong, nonatomic) UILabel *pendingLabel;


@property (strong, nonatomic) NSMutableArray *pendingChallengesIDs;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (readwrite, nonatomic) BOOL keyboardIsShown;
@property (readwrite, nonatomic) BOOL viewDidAppearOnce;

@property (weak, nonatomic) IBOutlet UIImageView *imageBanner;

@property (weak, nonatomic) IBOutlet UIWebView *bannerWebView;


- (IBAction) tweetAction:(id)sender;
- (IBAction) pendingChallenges:(id)sender;
- (IBAction) availablePlayers:(id)sender;
- (IBAction) topPlayers:(id)sender;
- (IBAction) directChallenge:(id)sender;


@end
