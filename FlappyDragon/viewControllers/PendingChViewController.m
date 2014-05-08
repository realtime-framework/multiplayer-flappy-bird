//
//  PendingChViewController.m
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "PendingChViewController.h"
#import "GameData.h"
#import "DragonChallenge.h"
#import "AcceptViewController.h"
#import "StorageManager.h"
#import "GameViewController.h"

#define kMARGIN_RIGHT 10
#define kSPACE_BT_BTT 10

@interface PendingChViewController ()

@property (nonatomic)  AdUnitUIkit *adUnitView;

@end

@implementation PendingChViewController

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

	_pendingChallenges = [[NSMutableArray alloc] init];
	
	[_titleLabel setFont:[UIFont fontWithName:@"Floraless" size:18]];
	_titleLabel.minimumScaleFactor = 0.5;
	_titleLabel.adjustsFontSizeToFitWidth = YES;
	_titleLabel.textColor = TEXT_COLOR;
	_titleLabel.shadowColor = TEXT_SHADOW_COLOR;
	_titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	[_backBtt.titleLabel setFont:[UIFont fontWithName:@"Floraless" size:16]];
	_backBtt.titleLabel.minimumScaleFactor = 0.5;
	_backBtt.titleLabel.textColor = TEXT_COLOR;
	_backBtt.titleLabel.shadowColor = TEXT_SHADOW_COLOR;
	_backBtt.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	_activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y * 0.85);
	_activityIndicator.color = [UIColor colorWithRed:(255/255.0) green:(135/255.0) blue:0 alpha:1.0];
	_activityIndicator.hidesWhenStopped = YES;
	[self.view addSubview:_activityIndicator];
	
}

- (void) viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	
	[self getChallengingPlayers];
	
	[[GameData localPlayer] onChallenge:^(NSString *nickName, NSString *gameId) {
		DragonPlayer *challengePlayer = [[DragonPlayer alloc] init];
		challengePlayer.nickname = nickName;
		challengePlayer.gameId = gameId;
		
		DragonChallenge *challenge = [[DragonChallenge alloc] initWhitPlayers:[GameData localPlayer] :challengePlayer];
		[self onDeleteChallenge:challenge];
		[_pendingChallenges addObject:challenge];
		[_tableView reloadData];
	}];
    
    _adUnitView = [[AdUnitUIkit alloc] initWithPLaceholder:_imageBanner AndZone:BANNER_Z_ID];
	[WebSpectatorMobile putAdUnit:_adUnitView];
}


- (void) viewDidDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
    
    [WebSpectatorMobile deleteAdUnit:_adUnitView];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_pendingChallenges count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
	// Configure the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	DragonChallenge *challenge = [_pendingChallenges objectAtIndex:indexPath.row];
	
	cell.textLabel.text = challenge.playerB.nickname;
	[cell.textLabel setFont:[UIFont fontWithName:@"Floraless" size:16]];
	cell.textLabel.textColor = TEXT_COLOR;
	cell.textLabel.shadowColor = TEXT_SHADOW_COLOR;
	cell.textLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Score = %lld", challenge.playerB.score];
	[cell.detailTextLabel setFont:[UIFont fontWithName:@"Floraless" size:12]];
	cell.detailTextLabel.textColor = TEXT_COLOR;
	cell.detailTextLabel.shadowColor = TEXT_SHADOW_COLOR;
	cell.detailTextLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	cell.backgroundColor = [UIColor clearColor];
	
	for (UIView *subView in [cell.contentView subviews]) {
		[subView removeFromSuperview];
	}
	
	CGSize cellSize = cell.frame.size;
	CGSize bttSize = CGSizeMake(41, 41);
	
	UIButton *acceptBtt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[acceptBtt setFrame:CGRectMake(cellSize.width - (bttSize.width*2) - kSPACE_BT_BTT - kMARGIN_RIGHT, cellSize.height/2 - bttSize.height/2, bttSize.width, bttSize.height)];
	[acceptBtt setBackgroundImage:[UIImage imageNamed:@"accept"] forState:UIControlStateNormal];
	[acceptBtt setBackgroundImage:[UIImage imageNamed:@"accept_hover"] forState:UIControlStateSelected];
	[acceptBtt addTarget:self action:@selector(acceptChallenge:) forControlEvents:UIControlEventTouchUpInside];
	acceptBtt.tag = indexPath.row;
	
	[cell.contentView addSubview:acceptBtt];
	
	UIButton *denyBtt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[denyBtt setFrame:CGRectMake(cellSize.width - bttSize.width - kMARGIN_RIGHT, cellSize.height/2 - bttSize.height/2, bttSize.width, bttSize.height)];
	[denyBtt setBackgroundImage:[UIImage imageNamed:@"deny"] forState:UIControlStateNormal];
	[denyBtt setBackgroundImage:[UIImage imageNamed:@"deny_hover"] forState:UIControlStateSelected];
	[denyBtt addTarget:self action:@selector(denyChallenge:) forControlEvents:UIControlEventTouchUpInside];
	denyBtt.tag = indexPath.row;

	[cell.contentView addSubview:denyBtt];
	
	return cell;
}

#pragma mark - Action

- (IBAction) backAction:(id)sender {
	[self clearHandlers];
	
	[AppDelegate backToRootViewController];
	//[self.navigationController popViewControllerAnimated:YES];
}

- (void) clearHandlers {
    if(_pendingChallenges.count > 0){
        for (DragonChallenge* challenge in _pendingChallenges) {
            [challenge removeOnDelete];
        }
    }
	
	[[GameData localPlayer] removeOnChallenge];
}

- (void) acceptChallenge:(id)sender {
	
	DragonChallenge *challenge = [_pendingChallenges objectAtIndex:[sender tag]];
	
    [self clearHandlers];
    
    Game* game = [[Game alloc] init];
    game.challenge = challenge;
    [GameData setCurrentGame:game];
    [challenge removeOnDelete];
    [AppDelegate transitionToViewController:[AppDelegate gameViewController]];
}

- (void) removeChallenge:(DragonChallenge*) challenge {
	int indexToRemove = -1;
	for (int i = 0; i < [_pendingChallenges count]; i++) {
		
		DragonChallenge *ch = [_pendingChallenges objectAtIndex:i];
		DragonPlayer *player = ch.playerB;
		if ([player.nickname isEqualToString:challenge.playerB.nickname]) {
			
			indexToRemove = i;
			break;
		}
	}
	if (indexToRemove >= 0) {
		
		[_pendingChallenges removeObjectAtIndex:indexToRemove];
		[_tableView reloadData];
	}
}

- (void) denyChallenge:(id)sender {
	DragonChallenge *challenge = [_pendingChallenges objectAtIndex:[sender tag]];
	DragonChallenge *challengeToRemove = [[DragonChallenge alloc] initWhitPlayers:challenge.playerB :challenge.playerA];
	
	[challenge removeOnDelete];
	[challengeToRemove remove:^(NSError *error) {
		if (error != nil) {
			//NSLog(@"Some Error deleting Challenge: %@", [error localizedDescription]);
		}
		[self removeChallenge:challenge];
	}];
}

- (void) onDeleteChallenge:(DragonChallenge *) challenge {
	[challenge onDelete:^{
		[challenge removeOnDelete];
		[self removeChallenge:challenge];
	}];
}


- (void) getChallengingPlayers {
	
	[_activityIndicator startAnimating];
    [GameData getPendingChallenges:^(NSMutableArray *challenges, NSError *error) {
		[_activityIndicator stopAnimating];
		if(error == nil && challenges != nil){
            // Check if theres a need to order the players array
			_pendingChallenges = challenges;
			if ([_pendingChallenges count] > 0) {
				for (int i = 0; i < _pendingChallenges.count; i++) {
					DragonChallenge *challenge = [_pendingChallenges objectAtIndex:i];
					[self onDeleteChallenge:challenge];
				}
			}
			[_tableView reloadData];
			
		}
		else if (error != nil) {
			//NSLog(@"### Error: GET PENDING Challenges%@", [error localizedDescription]);
        }
		
		[[GameData localPlayer] setChallengesOnTable:[_pendingChallenges count]];
	}];
}

@end

