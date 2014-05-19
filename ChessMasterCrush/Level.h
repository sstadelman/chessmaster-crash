//
//  Level.h
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/16/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import "ChessPiece.h"
#import "Tile.h"
#import "Swap.h"
#import "Chain.h"

static const NSInteger NumColumns = 9;
static const NSInteger NumRows = 9;

@interface Level : NSObject

@property (assign, nonatomic) NSUInteger targetScore;
@property (assign, nonatomic) NSUInteger maximumMoves;

@property (strong, nonatomic) NSMutableDictionary *possibleSwapsDict;


- (instancetype)initWithFile:(NSString *)filename;

- (NSSet *)shuffle;

- (ChessPiece *)pieceAtColumn:(NSInteger)column row:(NSInteger)row;
- (void)setPiece:(ChessPiece *)piece atColumn:(NSInteger)column andRow:(NSInteger)row;

- (Tile *)tileAtColumn:(NSInteger)columnt row:(NSInteger)row;

- (BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row;

- (void)detectPossibleSwaps;
- (void)performSwap:(Swap *)swap;
- (BOOL)isPossibleSwap:(Swap *)swap;

- (NSSet *)removeMatches;
- (NSArray *)fillHoles;
- (NSArray *)topUpPieces;

- (void)resetComboMultiplier;

@end
