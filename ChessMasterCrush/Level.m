//
//  Level.m
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/16/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import "Level.h"
#import "Tile.h"

#import "Level+ChessMoves.h"

@interface Level ()

@property (strong, nonatomic) NSSet *possibleSwaps;
@property (assign, nonatomic) NSUInteger comboMultiplier;

@end

@implementation Level {
    ChessPiece *_pieces[NumColumns][NumRows];
    Tile *_tiles[NumColumns][NumRows];
}

- (instancetype)initWithFile:(NSString *)filename {
    self = [super init];
    if (self != nil) {
        NSDictionary *dictionary = [self loadJSON:filename];
        
        // Loop through the rows
        [dictionary[@"tiles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
            
            // Loop through the columns in the current row
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
                
                // Note: In Sprite Kit (0,0) is at the bottom of the screen,
                // so we need to read this file upside down.
                NSInteger tileRow = NumRows - row - 1;
                
                // If the value is 1, create a tile object.
                if ([value integerValue] == 1) {
                    _tiles[column][tileRow] = [[Tile alloc] init];
                }
            }];
        }];
        
        self.targetScore = [dictionary[@"targetScore"] unsignedIntegerValue];
        self.maximumMoves = [dictionary[@"moves"] unsignedIntegerValue];
        
        self.possibleSwapsDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (ChessPiece *)pieceAtColumn:(NSInteger)column row:(NSInteger)row {
//    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
//    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    if ((column >= 0 && column < NumColumns) && (row >= 0 && row < NumRows)) {
        return _pieces[column][row];
    } else {
        return nil;
    }
    
//    return _pieces[column][row];
}

- (void)setPiece:(ChessPiece *)piece atColumn:(NSInteger)column andRow:(NSInteger)row {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    _pieces[column][row] = piece;
}

- (Tile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    return _tiles[column][row];
}

- (NSSet *)shuffle {
    NSSet *set;
    do {
        set = [self createInitialPieces];
        
        [self detectPossibleSwaps];
        
//        NSLog(@"possible swaps: %@", self.possibleSwaps);
    }
    while ([self.possibleSwaps count] == 0);
    
    return set;
}

- (void)detectPossibleSwaps {
    [self detectPossibleSwaps_castle];
    NSLog(@"possible castle swaps = %@", self.possibleSwapsDict[@"castle"]);
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            
            ChessPiece *piece = _pieces[column][row];
            if (piece != nil) {
                
                // Is it possible to swap this cookie with the one on the right?
                if (column < NumColumns - 1) {
                    // Have a cookie in this spot? If there is no tile, there is no cookie.
                    ChessPiece *other = _pieces[column + 1][row];
                    if (other != nil) {
                        // Swap them
                        _pieces[column][row] = other;
                        _pieces[column + 1][row] = piece;
                        
                        // Is either cookie now part of a chain?
                        if ([self hasChainAtColumn:column + 1 row:row] ||
                            [self hasChainAtColumn:column row:row]) {
                            
                            Swap *swap = [[Swap alloc] init];
                            swap.pieceA = piece;
                            swap.pieceB = other;
                            [set addObject:swap];
                        }
                        
                        // Swap them back
                        _pieces[column][row] = piece;
                        _pieces[column + 1][row] = other;
                    }
                }
                
                if (row < NumRows - 1) {
                    
                    ChessPiece *other = _pieces[column][row + 1];
                    if (other != nil) {
                        // Swap them
                        _pieces[column][row] = other;
                        _pieces[column][row + 1] = piece;
                        
                        if ([self hasChainAtColumn:column row:row + 1] ||
                            [self hasChainAtColumn:column row:row]) {
                            
                            Swap *swap = [[Swap alloc] init];
                            swap.pieceA = piece;
                            swap.pieceB = other;
                            [set addObject:swap];
                        }
                        
                        _pieces[column][row] = piece;
                        _pieces[column][row + 1] = other;
                    }
                }
            }
        }
    }
    
    self.possibleSwaps = set;
}

- (BOOL)isPossibleSwap:(Swap *)swap {
    NSLog(@"self.possibleSwaps = %@", self.possibleSwaps);
    return [self.possibleSwaps containsObject:swap];
}

- (NSSet *)createInitialPieces {
    NSMutableSet *set = [NSMutableSet set];
    
    // 1
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            
            if (_tiles[column][row] != nil) {
                
                // 2
                NSUInteger pieceType;
                do {
                    pieceType = arc4random_uniform(NumPieceTypes) + 1;
                }
                while ((column >= 2 &&
                        _pieces[column - 1][row].pieceType == pieceType &&
                        _pieces[column - 2][row].pieceType == pieceType)
                       ||
                       (row >= 2 &&
                        _pieces[column][row - 1].pieceType == pieceType &&
                        _pieces[column][row - 2].pieceType == pieceType));
                
                // 3
                ChessPiece *piece = [self createPieceAtColumn:column row:row withType:pieceType];
                
                // 4
                [set addObject:piece];
            }
            
        }
    }
    return set;
}

- (NSSet *)detectHorizontalMatches {
    // 1
    NSMutableSet *set = [NSMutableSet set];
    
    // 2
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns - 2; ) {
            
            // 3
            if (_pieces[column][row] != nil) {
                NSUInteger matchType = _pieces[column][row].pieceType;
                
                // 4
                if (_pieces[column + 1][row].pieceType == matchType
                    && _pieces[column + 2][row].pieceType == matchType) {
                    // 5
                    Chain *chain = [[Chain alloc] init];
                    chain.chainType = ChainTypeHorizontal;
                    do {
                        [chain addPiece:_pieces[column][row]];
                        column += 1;
                    }
                    while (column < NumColumns && _pieces[column][row].pieceType == matchType);
                    
                    [set addObject:chain];
                    continue;
                }
            }
            
            // 6
            column += 1;
        }
    }
    return set;
}

- (NSSet *)detectVerticalMatches {
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger column = 0; column < NumColumns; column++) {
        for (NSInteger row = 0; row < NumRows - 2; ) {
            if (_pieces[column][row] != nil) {
                NSUInteger matchType = _pieces[column][row].pieceType;
                
                if (_pieces[column][row + 1].pieceType == matchType
                    && _pieces[column][row + 2].pieceType == matchType) {
                    
                    Chain *chain = [[Chain alloc] init];
                    chain.chainType = ChainTypeVertical;
                    do {
                        [chain addPiece:_pieces[column][row]];
                        row += 1;
                    }
                    while (row < NumRows && _pieces[column][row].pieceType == matchType);
                    
                    [set addObject:chain];
                    continue;
                }
            }
            row += 1;
        }
    }
    return set;
}

- (NSSet *)removeMatches {
    NSSet *horizontalChains = [self detectHorizontalMatches];
    NSSet *verticalChains = [self detectVerticalMatches];
    
    NSLog(@"Horizontal matches: %@", horizontalChains);
    NSLog(@"Vertical matches: %@", verticalChains);
    
    [self removePieces:horizontalChains];
    [self removePieces:verticalChains];
    
    [self calculateScores:horizontalChains];
    [self calculateScores:verticalChains];
    
    return [horizontalChains setByAddingObjectsFromSet:verticalChains];
}

- (void)removePieces:(NSSet *)chains {
    for (Chain *chain in chains) {
        for (ChessPiece *piece in chain.pieces) {
            _pieces[piece.column][piece.row] = nil;
        }
    }
}

- (NSArray *)fillHoles {
    NSMutableArray *columns = [NSMutableArray array];
    
    // 1
    for (NSInteger column = 0; column < NumColumns; column++) {
        
        NSMutableArray *array;
        for (NSInteger row = 0; row < NumRows; row++) {
            
            // 2
            if (_tiles[column][row] != nil && _pieces[column][row] == nil) {
                
                // 3
                for (NSInteger lookup = row + 1; lookup < NumRows; lookup++) {
                    ChessPiece *piece = _pieces[column][lookup];
                    if (piece != nil) {
                        // 4
                        _pieces[column][lookup] = nil;
                        _pieces[column][row] = piece;
                        piece.row = row;
                        
                        // 5
                        if (array == nil) {
                            array = [NSMutableArray array];
                            [columns addObject:array];
                        }
                        [array addObject:piece];
                        
                        // 6
                        break;
                    }
                }
            }
        }
    }
    return columns;
}

- (NSArray *)topUpPieces {
    NSMutableArray *columns = [NSMutableArray array];
    
    NSUInteger pieceType = 0;
    
    for (NSInteger column = 0; column < NumColumns; column++) {
        
        NSMutableArray *array;
        
        // 1
        for (NSInteger row = NumRows - 1; row >= 0 && _pieces[column][row] == nil; row--) {
            
            // 2
            if (_tiles[column][row] != nil) {
                
                // 3
                NSUInteger newPieceType;
                do {
                    newPieceType = arc4random_uniform(NumPieceTypes) + 1;
                } while (newPieceType == pieceType);
                pieceType = newPieceType;
                
                // 4
                ChessPiece *piece = [self createPieceAtColumn:column row:row withType:pieceType];
                
                // 5
                if (array == nil) {
                    array = [NSMutableArray array];
                    [columns addObject:array];
                }
                [array addObject:piece];
            }
        }
    }
    return columns;
}

- (void)calculateScores:(NSSet *)chains {
    for (Chain *chain in chains) {
        chain.score = 60 * ([chain.pieces count] - 2) * self.comboMultiplier;
        self.comboMultiplier++;
    }
}
- (void)resetComboMultiplier {
    self.comboMultiplier = 1;
}

- (ChessPiece *)createPieceAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)pieceType{
    ChessPiece *piece = [[ChessPiece alloc] init];
    piece.pieceType = pieceType;
    piece.column = column;
    piece.row = row;
    _pieces[column][row] = piece;
    return piece;
}

- (void)performSwap:(Swap *)swap {
    NSInteger columnA = swap.pieceA.column;
    NSInteger rowA = swap.pieceA.row;
    NSInteger columnB = swap.pieceB.column;
    NSInteger rowB = swap.pieceB.row;
    
    _pieces[columnA][rowA] = swap.pieceB;
    swap.pieceB.column = columnA;
    swap.pieceB.row = rowA;
    
    _pieces[columnB][rowB] = swap.pieceA;
    swap.pieceA.column = columnB;
    swap.pieceA.row = rowB;
}

- (BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row {
    NSUInteger pieceType = _pieces[column][row].pieceType;
    
    NSUInteger horzLength = 1;
    for (NSInteger i = column - 1; i >= 0 && _pieces[i][row].pieceType == pieceType; i--, horzLength++) ;
    for (NSInteger i = column + 1; i < NumColumns && _pieces[i][row].pieceType == pieceType; i++, horzLength++) ;
    if (horzLength >= 3) return YES;
    
    NSUInteger vertLength = 1;
    for (NSInteger i = row - 1; i >= 0 && _pieces[column][i].pieceType == pieceType; i--, vertLength++) ;
    for (NSInteger i = row + 1; i < NumRows && _pieces[column][i].pieceType == pieceType; i++, vertLength++) ;
    return (vertLength >= 3);
}

- (NSDictionary *)loadJSON:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    if (path == nil) {
        NSLog(@"Could not find level file: %@", filename);
        return nil;
    }
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (data == nil) {
        NSLog(@"Could not load level file: %@, error: %@", filename, error);
        return nil;
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Level file '%@' is not valid JSON: %@", filename, error);
        return nil;
    }
    
    return dictionary;
}

@end
