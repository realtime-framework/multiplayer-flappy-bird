//
//  TopPlayersViewController.h
//  FlappyDragon
//
//  Created by iOSdev on 2/18/14.
//  Copyright (c) 2014 Realtime.co. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AdUnit.h"
#import "AdUnitUIkit.h"
#import "WebSpectatorMobile.h"


@interface TopPlayersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, retain) NSMutableArray *topPlayers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backBtt;

@property (weak, nonatomic) IBOutlet UIImageView *imageBanner;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (IBAction) backAction:(id)sender;


@end
