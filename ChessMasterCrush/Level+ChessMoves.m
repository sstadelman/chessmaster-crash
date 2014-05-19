//
//  Level+ChessMoves.m
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/18/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import "Level+ChessMoves.h"
#import "ChessPiece.h"

@implementation Level (ChessMoves)

-(void)detectPossibleSwaps_castle
{
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            
            ChessPiece *piece = [self pieceAtColumn:column row:row];
            if (piece != nil) {
                if (piece.pieceType == 2) {

                    // Is it possible to swap this cookie with the one on the right?
                    if (column < NumColumns - 1) {
                        // Have a cookie in this spot? If there is no tile, there is no cookie.
                        for (NSInteger offset = 1; offset < NumColumns; offset++) {
                            ChessPiece *other = [self pieceAtColumn:(column + offset) row:row];
                            if (other != nil) {
                                // Actually swap them in memory
                                [self setPiece:other atColumn:column andRow:row];
                                [self setPiece:piece atColumn:(column + offset) andRow:row];
                                
                                // Test if a chain is created?
                                if ([self hasChainAtColumn:(column + offset) row:row] ||
                                    [self hasChainAtColumn:column row:row]) {
                                    
                                    Swap *swap = [[Swap alloc] init];
                                    swap.pieceA = piece;
                                    swap.pieceB = other;
                                    [set addObject:swap];
                                }
                                
                                // Then put them back
                                [self setPiece:piece atColumn:column andRow:row];
                                [self setPiece:other atColumn:(column + offset) andRow:row];
                            }
                        }
                    }
                    
                    if (row < NumRows - 1) {
                        for (NSInteger offset = 1; offset < NumRows; offset++) {
                            ChessPiece *other = [self pieceAtColumn:column row:(row + offset)];
                            if (other != nil) {
                                // Swap them
                                [self setPiece:other atColumn:column andRow:row];
                                [self setPiece:piece atColumn:column andRow:(row + offset)];
                                
                                if ([self hasChainAtColumn:column row:row + offset] ||
                                    [self hasChainAtColumn:column row:row]) {
                                    
                                    Swap *swap = [[Swap alloc] init];
                                    swap.pieceA = piece;
                                    swap.pieceB = other;
                                    [set addObject:swap];
                                }
                                
                                [self setPiece:piece atColumn:column andRow:row];
                                [self setPiece:other atColumn:column andRow:(row + offset)];
                            }
                        }
                    }
                }
            }
        }
    }
    
    self.possibleSwapsDict[@"castle"] = set;
}

-(void)detectPossibleSwaps_bishop
{
    
}
@end
