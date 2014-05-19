//
//  ViewController.m
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/16/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

@import AVFoundation;

#import "ViewController.h"
#import "MyScene.h"
#import "Level.h"

@interface ViewController ()

@property (strong, nonatomic) Level *level;
@property (strong, nonatomic) MyScene *scene;

@property (assign, nonatomic) NSUInteger movesLeft;
@property (assign, nonatomic) NSUInteger score;

@property (weak, nonatomic) IBOutlet UILabel *targetLabel;
@property (weak, nonatomic) IBOutlet UILabel *movesLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gameOverPanel;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) AVAudioPlayer *backgroundMusic;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure the view.
    SKView *skView = (SKView *)self.view;
    skView.multipleTouchEnabled = NO;
    
    // Create and configure the scene.
    self.scene = [MyScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Load the level.
    self.level = [[Level alloc] initWithFile:@"Level_1"];
    self.scene.level = self.level;
    [self.scene addTiles];
    
    id block = ^(Swap *swap) {
        self.view.userInteractionEnabled = NO;
        
        if ([self.level isPossibleSwap:swap]) {
            [self.level performSwap:swap];
            [self.scene animateSwap:swap completion:^{
                [self handleMatches];
            }];
        } else {
            [self.scene animateInvalidSwap:swap completion:^{
                self.view.userInteractionEnabled = YES;
            }];
        }
    };
    
    self.scene.swipeHandler = block;
    
    self.gameOverPanel.hidden = YES;

    
    // Present the scene.
    [skView presentScene:self.scene];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Mining by Moonlight" withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.backgroundMusic.numberOfLoops = -1;
//    [self.backgroundMusic play];
    
    // Let's start the game!
    [self beginGame];
}

- (void)beginGame {
    self.movesLeft = self.level.maximumMoves;
    self.score = 0;
    [self updateLabels];
    [self.level resetComboMultiplier];
    [self.scene animateBeginGame];
    [self shuffle];
}

- (void)shuffle {
    [self.scene removeAllPiecesSprites];
    NSSet *newPieces = [self.level shuffle];
    [self.scene addSpritesForPieces:newPieces];
}

- (void)handleMatches {
    NSSet *chains = [self.level removeMatches];
    if ([chains count] == 0) {
        [self beginNextTurn];
        return;
    }
    [self.scene animateMatchedPieces:chains completion:^{
        
        for (Chain *chain in chains) {
            self.score += chain.score;
        }
        [self updateLabels];
        
        NSArray *columns = [self.level fillHoles];
        [self.scene animateFallingPieces:columns completion:^{
            NSArray *columns = [self.level topUpPieces];
            [self.scene animateNewPieces:columns completion:^{
                [self handleMatches];
            }];
        }];
    }];
}

- (void)updateLabels {
    self.targetLabel.text = [NSString stringWithFormat:@"%lu", (long)self.level.targetScore];
    self.movesLabel.text = [NSString stringWithFormat:@"%lu", (long)self.movesLeft];
    self.scoreLabel.text = [NSString stringWithFormat:@"%lu", (long)self.score];
}

- (void)decrementMoves{
    self.movesLeft--;
    [self updateLabels];
    
    if (self.score >= self.level.targetScore) {
        self.gameOverPanel.image = [UIImage imageNamed:@"LevelComplete"];
        [self showGameOver];
    } else if (self.movesLeft == 0) {
        self.gameOverPanel.image = [UIImage imageNamed:@"GameOver"];
        [self showGameOver];
    }
}

- (void)showGameOver {
    [self.scene animateGameOver];
    self.gameOverPanel.hidden = NO;
    self.scene.userInteractionEnabled = NO;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGameOver)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)hideGameOver {
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer = nil;
    
    self.gameOverPanel.hidden = YES;
    self.scene.userInteractionEnabled = YES;
    
    [self beginGame];
}

- (void)beginNextTurn {
    [self.level resetComboMultiplier];
    self.view.userInteractionEnabled = YES;
    [self decrementMoves];
    [self.level detectPossibleSwaps];
    
}

#pragma mark regular crap
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
