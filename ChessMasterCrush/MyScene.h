//
//  MyScene.h
//  ChessMasterCrush
//

//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

@import SpriteKit;

@class Level;
@class Swap;
@class ChessPiece;

@interface MyScene : SKScene

@property (strong, nonatomic) Level *level;
@property (copy, nonatomic) void (^swipeHandler)(Swap *swap);

@property (assign, nonatomic) NSInteger swipeFromColumn;
@property (assign, nonatomic) NSInteger swipeFromRow;
@property (nonatomic, strong) ChessPiece *swipeFromPiece;

- (void)addSpritesForPieces:(NSSet *)pieces;
- (void)addTiles;

- (void)animateSwap:(Swap *)swap completion:(dispatch_block_t)completion;
- (void)animateInvalidSwap:(Swap *)swap completion:(dispatch_block_t)completion;
- (void)animateMatchedPieces:(NSSet *)chains completion:(dispatch_block_t)completion;
- (void)animateFallingPieces:(NSArray *)columns completion:(dispatch_block_t)completion;
- (void)animateNewPieces:(NSArray *)columns completion:(dispatch_block_t)completion;

- (void)animateGameOver;
- (void)animateBeginGame;

- (void)removeAllPiecesSprites;

@end