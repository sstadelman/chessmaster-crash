//
//  MyScene.m
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/16/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import "MyScene.h"
#import "MyScene+ChessMoves.h"
#import "ChessPiece.h"
#import "Level.h"
#import "Swap.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface MyScene ()

@property (strong, nonatomic) SKNode *gameLayer;
@property (strong, nonatomic) SKNode *piecesLayer;
@property (strong, nonatomic) SKNode *tilesLayer;

@property (strong, nonatomic) SKSpriteNode *selectionSprite;

@property (strong, nonatomic) SKAction *swapSound;
@property (strong, nonatomic) SKAction *invalidSwapSound;
@property (strong, nonatomic) SKAction *matchSound;
@property (strong, nonatomic) SKAction *fallingCookieSound;
@property (strong, nonatomic) SKAction *addCookieSound;

@property (strong, nonatomic) SKCropNode *cropLayer;
@property (strong, nonatomic) SKNode *maskLayer;

@end

@implementation MyScene

- (id)initWithSize:(CGSize)size {
    if ((self = [super initWithSize:size])) {
        
        self.anchorPoint = CGPointMake(0.5, 0.5);
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        [self addChild:background];
        
        self.gameLayer = [SKNode node];
        self.gameLayer.hidden = YES;
        [self addChild:self.gameLayer];
        
        CGPoint layerPosition = CGPointMake(-TileWidth*NumColumns/2, -TileHeight*NumRows/2);
        
        self.tilesLayer = [SKNode node];
        self.tilesLayer.position = layerPosition;
        [self.gameLayer addChild:self.tilesLayer];
        
        self.cropLayer = [SKCropNode node];
        [self.gameLayer addChild:self.cropLayer];
        
        self.maskLayer = [SKNode node];
        self.maskLayer.position = layerPosition;
        self.cropLayer.maskNode = self.maskLayer;

        self.piecesLayer = [SKNode node];
        self.piecesLayer.position = layerPosition;
        
        [self.cropLayer addChild:self.piecesLayer];
        
        self.swipeFromColumn = self.swipeFromRow = NSNotFound;
        
        self.selectionSprite = [SKSpriteNode node];
        
        [self preloadResources];
    }
    return self;
}

- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            if ([self.level tileAtColumn:column row:row] != nil) {
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"MaskTile"];
                tileNode.position = [self pointForColumn:column row:row];
                [self.maskLayer addChild:tileNode];
            }
        }
    }
    
    for (NSInteger row = 0; row <= NumRows; row++) {
        for (NSInteger column = 0; column <= NumColumns; column++) {
            
            BOOL topLeft     = (column > 0) && (row < NumRows)
            && [self.level tileAtColumn:column - 1 row:row];
            
            BOOL bottomLeft  = (column > 0) && (row > 0)
            && [self.level tileAtColumn:column - 1 row:row - 1];
            
            BOOL topRight    = (column < NumColumns) && (row < NumRows)
            && [self.level tileAtColumn:column row:row];
            
            BOOL bottomRight = (column < NumColumns) && (row > 0)
            && [self.level tileAtColumn:column row:row - 1];
            
            // The tiles are named from 0 to 15, according to the bitmask that is
            // made by combining these four values.
            NSUInteger value = topLeft | topRight << 1 | bottomLeft << 2 | bottomRight << 3;
            
            // Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
            if (value != 0 && value != 6 && value != 9) {
                NSString *name = [NSString stringWithFormat:@"Tile_%lu", (long)value];
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:name];
                CGPoint point = [self pointForColumn:column row:row];
                point.x -= TileWidth/2;
                point.y -= TileHeight/2;
                tileNode.position = point;
                [self.tilesLayer addChild:tileNode];
            }
        }
    }
}

- (void)addSpritesForPieces:(NSSet *)pieces {
    for (ChessPiece *piece in pieces) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[piece spriteName]];
        sprite.position = [self pointForColumn:piece.column row:piece.row];
        [self.piecesLayer addChild:sprite];
        piece.sprite = sprite;
    }
}

- (void)preloadResources {
    self.swapSound = [SKAction playSoundFileNamed:@"Chomp.wav" waitForCompletion:NO];
    self.invalidSwapSound = [SKAction playSoundFileNamed:@"Error.wav" waitForCompletion:NO];
    self.matchSound = [SKAction playSoundFileNamed:@"Ka-Ching.wav" waitForCompletion:NO];
    self.fallingCookieSound = [SKAction playSoundFileNamed:@"Scrape.wav" waitForCompletion:NO];
    self.addCookieSound = [SKAction playSoundFileNamed:@"Drip.wav" waitForCompletion:NO];
    
    [SKLabelNode labelNodeWithFontNamed:@"GillSans-Bold"];
    [SKLabelNode labelNodeWithFontNamed:@"GillSans-BoldItalic"];
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight/2);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // 1
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.piecesLayer];
    
    // 2
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        
        // 3
        ChessPiece *piece = [self.level pieceAtColumn:column row:row];
        if (piece != nil) {
            
            [self showSelectionIndicatorForPiece:piece];
            
            // 4
            self.swipeFromColumn = column;
            self.swipeFromRow = row;
            self.swipeFromPiece = piece;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // 1
    if (self.swipeFromColumn == NSNotFound) return;
    
    // 2
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.piecesLayer];
    
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
    
        NSInteger dHorz = 0, dVert = 0;
        [self deltasForPieceAtColumn:column row:row deltaColumn:&dHorz deltaRow:&dVert];
        
        
        // 3
        NSInteger horzDelta = 0, vertDelta = 0;
        if (column < self.swipeFromColumn) {          // swipe left
            horzDelta = -1;
        } else if (column > self.swipeFromColumn) {   // swipe right
            horzDelta = 1;
        } else if (row < self.swipeFromRow) {         // swipe down
            vertDelta = -1;
        } else if (row > self.swipeFromRow) {         // swipe up
            vertDelta = 1;
        }
        
        // 4
        if (horzDelta != 0 || vertDelta != 0) {
            [self trySwapHorizontal:horzDelta vertical:vertDelta];
            
            [self hideSelectionIndicator];
            
            // 5
            self.swipeFromColumn = NSNotFound;
        }
    }
}

- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {
    // 1
    NSInteger toColumn = self.swipeFromColumn + horzDelta;
    NSInteger toRow = self.swipeFromRow + vertDelta;
    
    // 2
    if (toColumn < 0 || toColumn >= NumColumns) return;
    if (toRow < 0 || toRow >= NumRows) return;
    
    // 3
    ChessPiece *toPiece = [self.level pieceAtColumn:toColumn row:toRow];
    if (toPiece == nil) return;
    
    // 4
    ChessPiece *fromPiece = [self.level pieceAtColumn:self.swipeFromColumn row:self.swipeFromRow];
    
    NSLog(@"*** swapping %@ with %@", fromPiece, toPiece);
    
    if (self.swipeHandler != nil) {
        Swap *swap = [[Swap alloc] init];
        swap.pieceA = fromPiece;
        swap.pieceB = toPiece;
        
        self.swipeHandler(swap);
    }
}

- (void)animateSwap:(Swap *)swap completion:(dispatch_block_t)completion {
    // Put the piece you started with on top.
    swap.pieceA.sprite.zPosition = 100;
    swap.pieceB.sprite.zPosition = 90;
    
    const NSTimeInterval Duration = 0.3;
    
    SKAction *moveA = [SKAction moveTo:swap.pieceB.sprite.position duration:Duration];
    moveA.timingMode = SKActionTimingEaseOut;
    [swap.pieceA.sprite runAction:[SKAction sequence:@[moveA, [SKAction runBlock:completion]]]];
    
    SKAction *moveB = [SKAction moveTo:swap.pieceA.sprite.position duration:Duration];
    moveB.timingMode = SKActionTimingEaseOut;
    [swap.pieceB.sprite runAction:moveB];
    
    [self runAction:self.swapSound];
}

- (void)animateInvalidSwap:(Swap *)swap completion:(dispatch_block_t)completion {
    swap.pieceA.sprite.zPosition = 100;
    swap.pieceB.sprite.zPosition = 90;
    
    const NSTimeInterval Duration = 0.2;
    
    SKAction *moveA = [SKAction moveTo:swap.pieceB.sprite.position duration:Duration];
    moveA.timingMode = SKActionTimingEaseOut;
    
    SKAction *moveB = [SKAction moveTo:swap.pieceA.sprite.position duration:Duration];
    moveB.timingMode = SKActionTimingEaseOut;
    
    [swap.pieceA.sprite runAction:[SKAction sequence:@[moveA, moveB, [SKAction runBlock:completion]]]];
    [swap.pieceB.sprite runAction:[SKAction sequence:@[moveB, moveA]]];
    
    [self runAction:self.invalidSwapSound];
}

- (void)animateMatchedPieces:(NSSet *)chains completion:(dispatch_block_t)completion {
    
    for (Chain *chain in chains) {
    
        [self animateScoreForChain:chain];
        
        for (ChessPiece *piece in chain.pieces) {
            
            // 1
            if (piece.sprite != nil) {
                
                // 2
                SKAction *scaleAction = [SKAction scaleTo:0.1 duration:0.3];
                scaleAction.timingMode = SKActionTimingEaseOut;
                [piece.sprite runAction:[SKAction sequence:@[scaleAction, [SKAction removeFromParent]]]];
                
                // 3
                piece.sprite = nil;
            }
        }
    }
    
    [self runAction:self.matchSound];
    
    // 4
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:0.3],
                                         [SKAction runBlock:completion]
                                         ]]];
}

- (void)animateFallingPieces:(NSArray *)columns completion:(dispatch_block_t)completion {
    // 1
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        [array enumerateObjectsUsingBlock:^(ChessPiece *piece, NSUInteger idx, BOOL *stop) {
            CGPoint newPosition = [self pointForColumn:piece.column row:piece.row];
            
            // 2
            NSTimeInterval delay = 0.05 + 0.15*idx;
            
            // 3
            NSTimeInterval duration = ((piece.sprite.position.y - newPosition.y) / TileHeight) * 0.1;
            
            // 4
            longestDuration = MAX(longestDuration, duration + delay);
            
            // 5
            SKAction *moveAction = [SKAction moveTo:newPosition duration:duration];
            moveAction.timingMode = SKActionTimingEaseOut;
            [piece.sprite runAction:[SKAction sequence:@[
                                                         [SKAction waitForDuration:delay],
                                                         [SKAction group:@[moveAction, self.fallingCookieSound]]]]];
        }];
    }
    
    // 6
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:longestDuration],
                                         [SKAction runBlock:completion]
                                         ]]];
}

- (void)animateNewPieces:(NSArray *)columns completion:(dispatch_block_t)completion {
    // 1
    __block NSTimeInterval longestDuration = 0;
    
    for (NSArray *array in columns) {
        
        // 2
        NSInteger startRow = ((ChessPiece *)[array firstObject]).row + 1;
        
        [array enumerateObjectsUsingBlock:^(ChessPiece *piece, NSUInteger idx, BOOL *stop) {
            
            // 3
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[piece spriteName]];
            sprite.position = [self pointForColumn:piece.column row:startRow];
            [self.piecesLayer addChild:sprite];
            piece.sprite = sprite;
            
            // 4
            NSTimeInterval delay = 0.1 + 0.2*([array count] - idx - 1);
            
            // 5
            NSTimeInterval duration = (startRow - piece.row) * 0.1;
            longestDuration = MAX(longestDuration, duration + delay);
            
            // 6
            CGPoint newPosition = [self pointForColumn:piece.column row:piece.row];
            SKAction *moveAction = [SKAction moveTo:newPosition duration:duration];
            moveAction.timingMode = SKActionTimingEaseOut;
            piece.sprite.alpha = 0;
            [piece.sprite runAction:[SKAction sequence:@[
                                                          [SKAction waitForDuration:delay],
                                                          [SKAction group:@[
                                                                            [SKAction fadeInWithDuration:0.05], moveAction, self.addCookieSound]]]]];
        }];
    }
    
    // 7
    [self runAction:[SKAction sequence:@[
                                         [SKAction waitForDuration:longestDuration],
                                         [SKAction runBlock:completion]
                                         ]]];
}

- (void)animateScoreForChain:(Chain *)chain {
    // Figure out what the midpoint of the chain is.
    ChessPiece *firstPiece = [chain.pieces firstObject];
    ChessPiece *lastPiece = [chain.pieces lastObject];
    CGPoint centerPosition = CGPointMake(
                                         (firstPiece.sprite.position.x + lastPiece.sprite.position.x)/2,
                                         (firstPiece.sprite.position.y + lastPiece.sprite.position.y)/2 - 8);
    
    // Add a label for the score that slowly floats up.
    SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"GillSans-BoldItalic"];
    scoreLabel.fontSize = 16;
    scoreLabel.text = [NSString stringWithFormat:@"%lu", (long)chain.score];
    scoreLabel.position = centerPosition;
    scoreLabel.zPosition = 300;
    [self.piecesLayer addChild:scoreLabel];
    
    SKAction *moveAction = [SKAction moveBy:CGVectorMake(0, 3) duration:0.7];
    moveAction.timingMode = SKActionTimingEaseOut;
    [scoreLabel runAction:[SKAction sequence:@[
                                               moveAction,
                                               [SKAction removeFromParent]
                                               ]]];
}

- (void)animateGameOver {
    SKAction *action = [SKAction moveBy:CGVectorMake(0, -self.size.height) duration:0.3];
    action.timingMode = SKActionTimingEaseIn;
    [self.gameLayer runAction:action];
}

- (void)animateBeginGame {
    self.gameLayer.hidden = NO;
    
    self.gameLayer.position = CGPointMake(0, self.size.height);
    SKAction *action = [SKAction moveBy:CGVectorMake(0, -self.size.height) duration:0.3];
    action.timingMode = SKActionTimingEaseOut;
    [self.gameLayer runAction:action];
}

- (void)removeAllPiecesSprites {
    [self.piecesLayer removeAllChildren];
}

- (void)showSelectionIndicatorForPiece:(ChessPiece *)piece {
    // If the selection indicator is still visible, then first remove it.
    if (self.selectionSprite.parent != nil) {
        [self.selectionSprite removeFromParent];
    }
    
    SKTexture *texture = [SKTexture textureWithImageNamed:[piece highlightedSpriteName]];
    self.selectionSprite.size = texture.size;
    [self.selectionSprite runAction:[SKAction setTexture:texture]];
    
    [piece.sprite addChild:self.selectionSprite];
    self.selectionSprite.alpha = 1.0;
}

- (void)hideSelectionIndicator {
    [self.selectionSprite runAction:[SKAction sequence:@[
                                                         [SKAction fadeOutWithDuration:0.3],
                                                         [SKAction removeFromParent]]]];
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
    NSParameterAssert(column);
    NSParameterAssert(row);
    
    // Is this a valid location within the pieces layer? If yes,
    // calculate the corresponding row and column numbers.
    if (point.x >= 0 && point.x < NumColumns*TileWidth &&
        point.y >= 0 && point.y < NumRows*TileHeight) {
        
        *column = point.x / TileWidth;
        *row = point.y / TileHeight;
        return YES;
        
    } else {
        *column = NSNotFound;  // invalid location
        *row = NSNotFound;
        return NO;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if (self.selectionSprite.parent != nil && self.swipeFromColumn != NSNotFound) {
        [self hideSelectionIndicator];
    }
    
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
