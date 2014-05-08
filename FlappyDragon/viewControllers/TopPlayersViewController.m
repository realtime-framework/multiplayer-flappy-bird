//
//  TopPlayersViewController.m
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import "DragonPlayer.h"
#import "TopPlayersViewController.h"
#import "DragonChallenge.h"
#import "GameData.h"
#import "WaitingViewController.h"


#define kMARGIN_RIGHT 10
#define kSPACE_BT_BTT 10

@interface TopPlayersViewController ()

@property (nonatomic)  AdUnitUIkit *adUnitView;
@property BOOL performingChallenge;

@end

@implementation TopPlayersViewController

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

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.performingChallenge = false;
    
	[self getAvailableTopPlayers];
    
    _adUnitView = [[AdUnitUIkit alloc] initWithPLaceholder:_imageBanner AndZone:BANNER_Z_ID];
	[WebSpectatorMobile putAdUnit:_adUnitView];
}


- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if(_topPlayers.count > 0){
        for( DragonPlayer* player in _topPlayers){
            [player removeOnChange];
        }
    }
    
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
    return [_topPlayers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = [indexPath row];
    if(_topPlayers.count > row){
        DragonPlayer* player = [_topPlayers objectAtIndex:row];
        
        // Configure the cell...
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
        
        if (player.challenges < 10
            && ![player.state isEqualToString:PLAYER_STATE_PLAYING]
            && ![player.nickname isEqualToString:[[GameData localPlayer] nickname]]) {
            
            CGSize cellSize = cell.frame.size;
            CGSize bttSize = CGSizeMake(115, 41);
            
            UIButton *challengeBtt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [challengeBtt setFrame:CGRectMake(cellSize.width - bttSize.width - kMARGIN_RIGHT, cellSize.height/2 - bttSize.height/2, bttSize.width, bttSize.height)];
			[challengeBtt setBackgroundImage:[UIImage imageNamed:@"challenge.png"] forState:UIControlStateNormal];
			
            [challengeBtt addTarget:self action:@selector(makeChallenge:) forControlEvents:UIControlEventTouchUpInside];
            challengeBtt.tag = indexPath.row;
			
            [cell.contentView addSubview:challengeBtt];
        }
    }
    return cell;
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
	
	[AppDelegate backToRootViewController];
}


- (void) makeChallenge:(id)sender {
    if(!self.performingChallenge){
        self.performingChallenge = true;
        DragonPlayer *player = [_topPlayers objectAtIndex:[sender tag]];
        [GameData makeChallenge:[GameData localPlayer] :player :^(DragonChallenge* challenge, NSError *error) {
            
            if (error != nil) {
                
                //NSLog(@"Error Making Challenge on Top Player\nA:\n%@\nB:\n%@\n%@", [[GameData localPlayer] toString], [player toString], [error localizedDescription]);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error making challenge!\nPlease try later" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
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

- (void) getAvailableTopPlayers {
	
	[_activityIndicator startAnimating];
    _topPlayers = [[NSMutableArray alloc] init];
    [_tableView reloadData];
    [GameData getTop10Players:^(NSMutableArray *players, NSError *error) {
        if(error == nil && players != nil){
            // Check if theres a need to order the players array
            _topPlayers = players;
            if(_topPlayers.count > 0){
                for( DragonPlayer* player in _topPlayers){
                    [player onChange:^{
                        [_tableView reloadData];
                    }];
                }
            }
            [_tableView reloadData];
        }else if ( error != nil){
            //NSLog(@"### Error: GET TOP PLAYERS%@", [error localizedDescription]);
        }
		[_activityIndicator stopAnimating];
    }];
}


@end
