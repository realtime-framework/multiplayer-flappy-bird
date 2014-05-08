//
//  GameScene.m
//  FlappyDragon
//
//  Created by Nathan Borror on 2/5/14.
//  Copyright (c) 2014 Nathan Borror. All rights reserved.
//

#import "GameScene.h"
#import "Player.h"
#import "Obstacle.h"
#import "GameData.h"
#import "GameOverViewController.h"

static const uint32_t kPlayerCategory = 0x1 << 0;
static const uint32_t kGroundCategory = 0x1 << 1;

static const CGFloat kGravity = -10;
static const CGFloat kDensity = 1.15;
static const CGFloat kMaxVelocity = 400;

static const CGFloat kPipeSpeed = 4;
static const CGFloat kPipeWidth = 56.0;
static const CGFloat kPipeGap = 145;
static const CGFloat kPipeFrequency = 2;

static const CGFloat kGroundHeight = 56.0;

static const NSInteger kNumLevels = 20;

NSString * const kTopPipeName = @"topPipe";
NSString * const kBottomPipeName = @"bottomPipe";


@implementation GameScene {
    NSMutableArray* players;
    NSMutableArray* player2Taps;
    
	SKSpriteNode *_ground;
	SKLabelNode *_scoreLabel;
	NSInteger _score;
	NSTimer *_pipeTimer;
	NSTimer *_scoreTimer;
	SKAction *_pipeSound;
	SKAction *_punchSound;
    
    long playersDistance;
    int currentPipe;
    Obstacle* currentTopPipe;
    Obstacle* nextTopPipe;
	
    Obstacle* currentBottomPipe;
    Obstacle* nextBottomPipe;
    
    BOOL isGameOver;
    BOOL receivedStartAcknowledge;
    NSTimer *receivedStartTimer;
}

- (id)initWithSize:(CGSize)size
{
    isGameOver = NO;
	if (self = [super initWithSize:size]) {
    }
	return self;
}

- (Player*)setupPlayer:(BOOL) withCollision :(long) distance
{
    Player* player = [Player spriteNodeWithImageNamed:@"flappy_move1"];
    //[player setSize:CGSizeMake(38, 32)];
    [player setPosition:CGPointMake(self.size.width/2 + distance, self.size.height/2)];
    [self addChild:player];
	
    
    player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:player.size];
    [player.physicsBody setDensity:kDensity];
    [player.physicsBody setAllowsRotation:NO];
    [player.physicsBody setUsesPreciseCollisionDetection:YES];
    
    if(withCollision){
        [player.physicsBody setCategoryBitMask:kPlayerCategory];
        [player.physicsBody setContactTestBitMask:kGroundCategory];
        [player.physicsBody setCollisionBitMask:kGroundCategory];
        player.adUnitView = [[AdUnitSpriteKit alloc] initWithPLaceholder:player AndZone:SPONSOR_Z_ID];
    }else{
        player.adUnitView = [[AdUnitSpriteKit alloc] initWithPLaceholder:player AndZone:SPONSOR2_Z_ID];
    }
    
	[WebSpectatorMobile putAdUnit:player.adUnitView];
    
    return player;
}

- (void) abortGame{
    if(!receivedStartAcknowledge){
        isGameOver = YES;
        if(_pipeTimer != nil){
            [_pipeTimer invalidate];
        }
        
        if(_scoreTimer != nil){
            [_scoreTimer invalidate];
        }
        
        if(players != nil && players.count > 0){
            for(Player* player in players){
                [player setAlpha:0.1];
                
                [WebSpectatorMobile deleteAdUnit:player.adUnitView];
            }
        }
        
        [self removeAllChildren];
        [self removeAllActions];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Opponent abandoned game"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        
        DragonChallenge* challengeToRemove = [[DragonChallenge alloc] initWhitPlayers:[GameData currentGame].challenge.playerB :[GameData currentGame].challenge.playerA ];
        
        
        [challengeToRemove remove:^(NSError *error) {
            [AppDelegate transitionToViewController:[AppDelegate rootViewController]];
        }];
    }
}

- (void) ready:(long long) startDate{
    [GameData currentGame].localStartTime = startDate;
    if([GameData isChallenging:[GameData currentGame].challenge]){
        [[GameData communication] startGame:[GameData currentGame].challenge.playerA.gameId];
    }else{
        [[GameData communication] startGame:[GameData currentGame].challenge.playerB.gameId];
    }
}

- (void) startGame{
    
    playersDistance = (self.size.width + kPipeWidth)/4;
    
    if([GameData isChallenging:[GameData currentGame].challenge]){
        [self ready:[GameData getCurrentDate] + MAX_LATENCY];
        [NSTimer scheduledTimerWithTimeInterval:MAX_LATENCY/1000 target:self selector:@selector(startTimers:) userInfo:nil repeats:NO];
    }else{
        [self ready:[GameData getCurrentDate]];
        [self startTimers:nil];
    }
}

- (void) startTimers:(NSTimer*) timer{
    [players addObject:[self setupPlayer:YES :0]];
    [players addObject:[self setupPlayer:NO :-playersDistance]];
    
    _pipeTimer = [NSTimer scheduledTimerWithTimeInterval:kPipeFrequency target:self selector:@selector(addObstacle) userInfo:nil repeats:YES];
	
    [NSTimer scheduledTimerWithTimeInterval:kPipeFrequency target:self selector:@selector(startScoreTimer) userInfo:nil repeats:NO];
}

- (void) setupScene {
    [self removeAllChildren];
    
    _score = 0;
    
    srand((time(nil) % kNumLevels)*10000);
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
    [background setSize:self.size];
    [background setPosition:(CGPoint) {CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)}];
    [self addChild:background];
    
    [self.physicsWorld setGravity:CGVectorMake(0, kGravity)];
    [self.physicsWorld setContactDelegate:self];
    
    _ground = [SKSpriteNode spriteNodeWithImageNamed:@"Ground"];
    [_ground setCenterRect:CGRectMake(26.0/kGroundHeight, 26.0/kGroundHeight, 4.0/kGroundHeight, 4.0/kGroundHeight)];
    [_ground setXScale:self.size.width/kGroundHeight];
    [_ground setPosition:CGPointMake(self.size.width/2, _ground.size.height/2)];
    [self addChild:_ground];
    
    _ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_ground.size];
    [_ground.physicsBody setCategoryBitMask:kGroundCategory];
    [_ground.physicsBody setCollisionBitMask:kPlayerCategory];
    [_ground.physicsBody setAffectedByGravity:NO];
    [_ground.physicsBody setDynamic:NO];
    
    _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
    [_scoreLabel setPosition:CGPointMake(self.size.width/2, self.size.height-50)];
    [_scoreLabel setText:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:_score]]];
    [_scoreLabel setZPosition:100];
    [self addChild:_scoreLabel];
    
    players = [[NSMutableArray alloc] init];
    player2Taps = [[NSMutableArray alloc] init];
    currentPipe = 0;
    
    _pipeSound = [SKAction playSoundFileNamed:@"pipe.mp3" waitForCompletion:NO];
    _punchSound = [SKAction playSoundFileNamed:@"punch3.mp3" waitForCompletion:NO];
}

- (void) delayedDidMoveToView{
    receivedStartAcknowledge = NO;
    receivedStartTimer = [NSTimer scheduledTimerWithTimeInterval:(MAX_LATENCY*5/1000) target:self selector:@selector(abortGame) userInfo:nil repeats:NO];
    [[GameData communication] setOnAction:self];
    if([GameData isChallenging:[GameData currentGame].challenge]){
        [GameData currentGame].map = [GameData generateMap:self.size.height :50];
        [self startGame];
    }else{
        [[GameData communication] accept];
    }
}

- (void) didMoveToView:(SKView *)view{
    [self setupScene];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(delayedDidMoveToView) userInfo:nil repeats:NO];
}

- (void)addObstacle {
    currentPipe++;
    if(currentPipe >= [GameData currentGame].map.count){
        currentPipe = 0;
	}
	
    CGFloat centerY = [[[GameData currentGame].map objectAtIndex:currentPipe] floatValue];
	CGFloat pipeTopHeight = centerY - (kPipeGap/2);
	CGFloat pipeBottomHeight = self.size.height - (centerY + (kPipeGap/2));
	
	// Top Pipe
	Obstacle *pipeTop = [Obstacle spriteNodeWithImageNamed:@"pipe_up"];
	[pipeTop setCenterRect:CGRectMake(26.0/kPipeWidth, 26.0/kPipeWidth, 4.0/kPipeWidth, 4.0/kPipeWidth)];
	[pipeTop setYScale:pipeTopHeight/kPipeWidth];
	[pipeTop setPosition:CGPointMake(self.size.width+(pipeTop.size.width/2), self.size.height-(pipeTop.size.height/2))];
    [pipeTop setName:kTopPipeName];
    [pipeTop setZPosition:0];
	[self addChild:pipeTop];
	
	
	
	// Bottom Pipe
	Obstacle *pipeBottom = [Obstacle spriteNodeWithImageNamed:@"pipe_down"];
	[pipeBottom setCenterRect:CGRectMake(26.0/kPipeWidth, 26.0/kPipeWidth, 4.0/kPipeWidth, 4.0/kPipeWidth)];
	[pipeBottom setYScale:(pipeBottomHeight-kGroundHeight)/kPipeWidth];
	[pipeBottom setPosition:CGPointMake(self.size.width+(pipeBottom.size.width/2), (pipeBottom.size.height/2)+(kGroundHeight-2))];
    [pipeBottom setName:kBottomPipeName];
    [pipeBottom setZPosition:0];
	[self addChild:pipeBottom];
	
    if(currentBottomPipe){
        nextBottomPipe = pipeBottom;
        nextTopPipe = pipeTop;
    }else{
        currentBottomPipe = pipeBottom;
        currentTopPipe = pipeTop;
    }
	
	// Move top pipe
	SKAction *pipeTopAction = [SKAction moveToX:-(pipeTop.size.width/2) duration:kPipeSpeed];
	SKAction *pipeTopSequence = [SKAction sequence:@[pipeTopAction, [SKAction runBlock:^{
		[pipeTop removeFromParent];
	}]]];
	
	[pipeTop runAction:[SKAction repeatActionForever:pipeTopSequence]];
	
	// Move bottom pipe
	SKAction *pipeBottomAction = [SKAction moveToX:-(pipeBottom.size.width/2) duration:kPipeSpeed];
	SKAction *pipeBottomSequence = [SKAction sequence:@[pipeBottomAction, [SKAction runBlock:^{
		[pipeBottom removeFromParent];
	}]]];
	
	[pipeBottom runAction:[SKAction repeatActionForever:pipeBottomSequence]];
}

- (void)startScoreTimer
{
	_scoreTimer = [NSTimer scheduledTimerWithTimeInterval:kPipeFrequency target:self selector:@selector(incrementScore) userInfo:nil repeats:YES];
}

- (void)incrementScore
{
	_score++;
	[_scoreLabel setText:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:_score]]];
	[self runAction:_pipeSound];
}

- (BOOL) intersectTopPipe:(Obstacle*) topPipe :(Player*) player {
    BOOL result = NO;
    
    // player data
    CGFloat playerHeight = player.size.height / 2;
    CGFloat playerWidth = player.size.width / 2;
    
    CGFloat xPos = player.position.x;
    CGFloat xMin = xPos - playerWidth;
    CGFloat xMax = xPos + playerWidth;
    
    CGFloat yPos = player.position.y;
    CGFloat yMax = yPos + playerHeight;
    
    // pipe
    CGFloat pipeWidth = kPipeWidth / 2;
    CGFloat pipeHeight = topPipe.size.height / 2;
    
    CGFloat xPosPipe = topPipe.position.x;
    CGFloat xMinPipe = xPosPipe - pipeWidth;
    CGFloat xMaxPipe = xPosPipe + pipeWidth;
    
    CGFloat yPosPipe = topPipe.position.y;
    CGFloat yMinPipe =  yPosPipe - pipeHeight;
    
    if (yMax >= yMinPipe && xMax >= xMinPipe && xMin <= xMaxPipe)  {
        result = YES;
    }
    
    return result;
}

- (BOOL) intersectBottomPipe:(Obstacle*) bottomPipe :(Player*) player{
    BOOL result = NO;
    
    // player data
    CGFloat playerHeight = player.size.height / 2;
    CGFloat playerWidth = player.size.width / 2;
    
    CGFloat xPos = player.position.x;
    CGFloat xMin = xPos - playerWidth;
    CGFloat xMax = xPos + playerWidth;
    
    CGFloat yPos = player.position.y;
    CGFloat yMin = yPos - playerHeight;
    
    // pipe
    CGFloat pipeWidth = kPipeWidth / 2;
    CGFloat pipeHeight = bottomPipe.size.height / 2;
    
    CGFloat xPosPipe = bottomPipe.position.x;
    CGFloat xMinPipe = xPosPipe - pipeWidth;
    CGFloat xMaxPipe = xPosPipe + pipeWidth;
    
    CGFloat yPosPipe = bottomPipe.position.y;
    CGFloat yMaxPipe = yPosPipe + pipeHeight;
    
    if (yMin <= yMaxPipe && xMax >= xMinPipe && xMin <= xMaxPipe)  {
        result = YES;
    }
    
    return result;
}

- (void) intersectElements:(Player*) player {
    if (!isGameOver && ![GameData currentGame].isGameOver && currentTopPipe && currentBottomPipe) {
        if([self intersectTopPipe:currentTopPipe :player] || [self intersectBottomPipe:currentBottomPipe :player]){
			[self localGameOver];
			
		}
    }
}

- (void) scheduleTap {
    if(player2Taps.count > 0){
        NSDictionary* tap = [player2Taps objectAtIndex:0];
        long long tapTime = [[tap objectForKey:@"time"] longLongValue];
        long long deltaTime = tapTime - [GameData currentGame].opponentStartTime;
        long long finalMoment = [GameData currentGame].localStartTime + deltaTime + MAX_LATENCY;
        long long currentDate = [GameData getCurrentDate];
        long long deltaTimeFinal = finalMoment - currentDate;
        float timerTime = ((float)deltaTimeFinal)/1000;
        
        [NSTimer scheduledTimerWithTimeInterval:timerTime target:self selector:@selector(executeRemoteTap:) userInfo:tap repeats:NO];
    }
}

- (void) executeRemoteTap:(NSTimer*) timer {
    [player2Taps removeObjectAtIndex:0];
    
    Player* player = [players objectAtIndex:1];
    
    NSDictionary *tap = [[NSMutableDictionary alloc] initWithDictionary:[timer userInfo]];
    
    float x =  self.size.width/2 - playersDistance;
    float y = [[tap objectForKey:@"y"] floatValue];
    CGPoint position = CGPointMake(x, y);
    [player setPosition:position];
    
    [self tapPlayer:[players objectAtIndex:1]];
    
    if(player2Taps.count > 1){
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
        NSArray *sortedArray = [player2Taps sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        
        [player2Taps removeAllObjects];
        for (NSDictionary *dic in sortedArray) {
            [player2Taps addObject:dic];
        }
    }
    
    [self scheduleTap];
}

- (void) tapPlayer:(Player*) player{
    [player.physicsBody setVelocity:CGVectorMake(player.physicsBody.velocity.dx, kMaxVelocity)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(players.count > 0){
        Player* player = [players objectAtIndex:0];
		
		NSDictionary *tapMsg = [[NSMutableDictionary alloc] init];
		[tapMsg setValue:@"tap" forKey:@"op"];
		[tapMsg setValue:[NSString stringWithFormat:@"%lld", [GameData getCurrentDate]] forKey:@"time"];
		
        [tapMsg setValue:[NSString stringWithFormat:@"%f",(player.position.y)] forKey:@"y"];
        
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tapMsg options:NSJSONWritingPrettyPrinted error:nil];
		NSMutableString *jsonString = [[NSMutableString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        if([GameData isChallenging:[[GameData currentGame] challenge]]){
            [[GameData communication] send:[GameData currentGame].challenge.playerA.gameId :jsonString];
        }else{
            [[GameData communication] send:[GameData currentGame].challenge.playerB.gameId :jsonString];
        }
		
        [self tapPlayer:player];
	}
}

- (void)update:(NSTimeInterval)currentTime
{
    if(players.count > 0){
        if(currentTopPipe != nil && players.count > 0){
            Player* player = [players objectAtIndex:0];
            
            CGFloat playerWidth = player.size.width / 2;
            
            CGFloat xPos = player.position.x;
            CGFloat xMin = xPos - playerWidth;
            
            // pipe
            CGFloat pipeWidth = kPipeWidth / 2;
            
            CGFloat xPosPipe = currentTopPipe.position.x;
            CGFloat xMaxPipe = xPosPipe + pipeWidth;
            
            
            if(xMaxPipe < xMin){
                currentTopPipe = nextTopPipe;
                currentBottomPipe = nextBottomPipe;
            }
            
            [self intersectElements:player];
            
        }
        
        for(Player* player in players){
            if (player.physicsBody.velocity.dy > kMaxVelocity) {
                [player.physicsBody setVelocity:CGVectorMake(player.physicsBody.velocity.dx, kMaxVelocity)];
            }
            
            CGFloat rotation_Other = ((player.physicsBody.velocity.dy + kMaxVelocity) / (2*kMaxVelocity)) * M_2_PI;
            [player setZRotation:rotation_Other-M_1_PI/2];
        }
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
	SKNode *node = contact.bodyA.node;
	if ([node isKindOfClass:[Player class]]) {
        [self intersectElements:(Player*) node];
    }
}

- (void)localGameOver
{
    if(![GameData currentGame].isGameOver){
        isGameOver = true;
        [GameData currentGame].isGameOver = true;
        [_pipeTimer invalidate];
        [_scoreTimer invalidate];
        
        for(Player* player in players){
            [player setAlpha:0.1];
            
            [WebSpectatorMobile deleteAdUnit:player.adUnitView];
        }
        
        [self removeAllChildren];
        [self removeAllActions];
        
        [GameData currentGame].localGameOverTime = [GameData getCurrentDate];
        
        NSDictionary *gameOver = [[NSMutableDictionary alloc] init];
        [gameOver setValue:@"lost" forKey:@"op"];
        [gameOver setValue:[[GameData localPlayer] gameId] forKey:@"id"];
        [gameOver setValue:[NSNumber numberWithLongLong:[GameData currentGame].localGameOverTime] forKey:@"time"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:gameOver options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableString *jsonString = [[NSMutableString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        if([GameData isChallenging:[[GameData currentGame] challenge]]){
            [[GameData communication] send:[GameData currentGame].challenge.playerA.gameId :jsonString];
        }else{
            [[GameData communication] send:[GameData currentGame].challenge.playerB.gameId :jsonString];
        }
        
        [NSTimer scheduledTimerWithTimeInterval:MAX_LATENCY/1000 target:self selector:@selector(processGameOver) userInfo:nil repeats:NO];
	}
}

- (void) processGameOver {
    Game* game = [GameData currentGame];
    long long opponentGameTime = game.opponentGameOverTime - game.opponentStartTime;
    long long myGameTime = game.localGameOverTime - game.localStartTime;
    
    BOOL won = NO;
    if(game.localGameOverTime > 0 && game.opponentGameOverTime <= 0){
        
    }else if(game.localGameOverTime > 0 && game.opponentGameOverTime > 0 && opponentGameTime > myGameTime){
        
    } else {
        won = YES;
    }
    
    [self showGameOver:won WhitScore:_score];
}

- (void) showGameOver:(BOOL) win WhitScore:(NSInteger) score{
	
    [[GameData currentGame].challenge.playerA changeStatus:PLAYER_STATE_WAITING :^(NSError *error) {
        if(error != nil){
            //NSLog(@"Error changing status on game over: %@",error.localizedDescription);
        }
    }];
	
    [[GameData currentGame].challenge.playerB changeStatus:PLAYER_STATE_WAITING :^(NSError *error) {
        if(error != nil){
            //NSLog(@"Error changing status on game over: %@",error.localizedDescription);
        }
    }];
    
    
    [[GameData communication] setOnAction:nil];
    
	GameOverViewController *gameOverViewController = [[GameOverViewController alloc] initWithNibName:@"GameOverViewController" bundle:nil];
	gameOverViewController.challenge = [[GameData currentGame] challenge];
	gameOverViewController.iWon = win;
	gameOverViewController.score = (int)score;
	[AppDelegate transitionToViewController:gameOverViewController];
}

- (void) start:(NSDictionary *)game {
    receivedStartAcknowledge = YES;
    [GameData currentGame].opponentStartTime = [[game objectForKey:@"startTime"] longLongValue];
    if(![GameData isChallenging:[GameData currentGame].challenge]){
        [GameData currentGame].map = [game objectForKey:@"map"];
        [self startGame];
	}
}

- (void) tap:(NSDictionary *)tap{
    if(players.count > 1){
        [player2Taps addObject:tap];
        
        if(player2Taps.count == 1){
            [self scheduleTap];
        }
	}
}

- (void) lost:(NSDictionary *)lost {
    [GameData currentGame].opponentGameOverTime = [[lost objectForKey:@"time"] longLongValue];
    if(![GameData currentGame].isGameOver){
        [_pipeTimer invalidate];
        [_scoreTimer invalidate];
        
        for(Player* player in players){
            [player setAlpha:0.1];
            
            [WebSpectatorMobile deleteAdUnit:player.adUnitView];
        }
        
        isGameOver = YES;
        [GameData currentGame].isGameOver = YES;
        [NSTimer scheduledTimerWithTimeInterval:MAX_LATENCY/1000 target:self selector:@selector(processGameOver) userInfo:nil repeats:NO];
    }
}

- (void) accepted:(NSDictionary *)gameId {
    
}

- (void) startEcho {
    
}

@end
