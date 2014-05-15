//
//  AvailablePlayersViewController.m
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "AvailablePlayersViewController.h"
#import "DragonPlayer.h"
#import "GameData.h"
#import "WaitingViewController.h"


#define kMARGIN_RIGHT 10
#define kSPACE_BT_BTT 10

@interface AvailablePlayersViewController ()

@property (nonatomic)  AdUnitUIkit *adUnitView;
@property BOOL performingChallenge;

@end

@implementation AvailablePlayersViewController

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

- (void) viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    self.performingChallenge = false;
    
    _availablePlayers = [[NSMutableArray alloc] init];
    [self getAvailablePlayers];
    
    _adUnitView = [[AdUnitUIkit alloc] initWithPLaceholder:_imageBanner AndZone:BANNER_Z_ID];
	[WebSpectatorMobile putAdUnit:_adUnitView];
}


- (void) viewDidDisappear:(BOOL)animated{	
	[super viewDidDisappear:animated];
    
    [WebSpectatorMobile deleteAdUnit:_adUnitView];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
    // Return the number of rows in the section.
    return [_availablePlayers count];
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
	
	
	DragonPlayer *player = [_availablePlayers objectAtIndex:indexPath.row];
	
	cell.textLabel.text = player.nickname;
	[cell.textLabel setFont:[UIFont fontWithName:@"Floraless" size:16]];
	cell.textLabel.textColor = TEXT_COLOR;
	cell.textLabel.shadowColor = TEXT_SHADOW_COLOR;
	cell.textLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Score = %lld", player.score];
	[cell.detailTextLabel setFont:[UIFont fontWithName:@"Floraless" size:12]];
	cell.detailTextLabel.textColor = TEXT_COLOR;
	cell.detailTextLabel.shadowColor = TEXT_SHADOW_COLOR;
	cell.detailTextLabel.shadowOffset = CGSizeMake(1.0, 1.0);
	
	cell.backgroundColor = [UIColor clearColor];
	
	for (UIView *subView in [cell.contentView subviews]) {
		[subView removeFromSuperview];
	}
	
	if (player.challenges < 10) {
		
		CGSize cellSize = cell.frame.size;
		CGSize bttSize = CGSizeMake(115, 41);
		
		UIButton *acceptBtt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[acceptBtt setFrame:CGRectMake(cellSize.width - bttSize.width - kMARGIN_RIGHT, cellSize.height/2 - bttSize.height/2, bttSize.width, bttSize.height)];
		[acceptBtt setBackgroundImage:[UIImage imageNamed:@"challenge.png"] forState:UIControlStateNormal];

		[acceptBtt addTarget:self action:@selector(makeChallenge:) forControlEvents:UIControlEventTouchUpInside];
		acceptBtt.tag = indexPath.row;
		
		[cell.contentView addSubview:acceptBtt];
	}
	return cell;
}


#pragma mark - Action

- (IBAction)backAction:(id)sender {
	
	[AppDelegate backToRootViewController];
}


- (void) makeChallenge:(id)sender {
    if(!self.performingChallenge){
        DragonPlayer *player = [_availablePlayers objectAtIndex:[sender tag]];
        self.performingChallenge = true;
        [GameData makeChallenge:[GameData localPlayer] :player :^(DragonChallenge* challenge, NSError *error) {
            if (error != nil) {
                //NSLog(@"Error Making Challenge on Top Player\nA:\n%@\nB:\n%@\n%@", [[GameData localPlayer] toString], [player toString], [error localizedDescription]);
			}
            else {
                WaitingViewController* waitingViewController = [[WaitingViewController alloc] initWithNibName:@"WaitingViewController" bundle:nil];
                waitingViewController.challenge = challenge;
                
                [AppDelegate transitionToViewController:waitingViewController];
            }
        }];
    }
}


#pragma mark - Storage


- (void) getAvailablePlayers {
	
	[_activityIndicator startAnimating];
	[GameData getAvailablePlayers:^(NSMutableArray *avPlayers, NSError *error) {
		
		if (error == nil && avPlayers != nil){
            // Check if theres a need to order the players array
			if (avPlayers.count > 30) {
				_availablePlayers = [self filterPlayers:avPlayers];
			}
			else {
				_availablePlayers = avPlayers;
			}
			if (_availablePlayers.count > 0) {
				for (DragonPlayer *player in _availablePlayers){
                    [player onChange:^{
                        [_tableView reloadData];
                    }];
				}
			}
            [_tableView reloadData];
		}
		else if (error != nil){
			//NSLog(@"### Error: GETING AVAILABLE PLAYERS %@", [error localizedDescription]);
		}
		[_activityIndicator stopAnimating];
	}];
}


- (NSMutableArray *) filterPlayers:(NSMutableArray *) players {
	
	int lowestDiffIndex = 0;
	long long score = [[GameData localPlayer] score];
	long long lowestDiff = INT_MAX;
	long long diff = INT_MAX;
	
	NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:YES];
	[players sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
	
	long long currentScore = 0;
	for (int i = 0; i < [players count]; i++) {
		
		DragonPlayer *player = [players objectAtIndex:i];
		currentScore = player.score;
		diff = llabs(score - currentScore);
		
		if (diff < lowestDiff) {
			lowestDiff = diff;
			lowestDiffIndex = i;
		}
	}
	
	int lastIndex = ([players count] - 1);
	int rangeLength = MIN(30, lastIndex);
	int startLocation = MAX(lowestDiffIndex - (rangeLength/2), 0);
	if ((startLocation + rangeLength) > lastIndex) {
		startLocation = lastIndex - rangeLength;
	}
	
	players = (NSMutableArray *)[players subarrayWithRange:NSMakeRange(startLocation, rangeLength)];
	
	return players;
}


@end


