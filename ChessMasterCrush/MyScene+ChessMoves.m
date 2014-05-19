//
//  MyScene+ChessMoves.m
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/18/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import "MyScene+ChessMoves.h"
#import "ChessPiece.h"

@implementation MyScene (ChessMoves)

-(BOOL)deltasForPieceAtColumn:(NSInteger)column row:(NSInteger)row deltaColumn:(NSInteger *)dColumn deltaRow:(NSInteger *)dRow;
{
    NSParameterAssert(dColumn);
    NSParameterAssert(dRow);

    NSInteger horzDelta = 0, vertDelta = 0;
    
    switch (self.swipeFromPiece.pieceType) {
        case 2:
            if (column != self.swipeFromColumn) {          // swipe left or right
                horzDelta = column - self.swipeFromColumn;
            } else if (row != self.swipeFromRow) {         // swipe down
                vertDelta = row - self.swipeFromRow;
            }
        default:
            if (column < self.swipeFromColumn) {          // swipe left
                horzDelta = -1;
            } else if (column > self.swipeFromColumn) {   // swipe right
                horzDelta = 1;
            } else if (row < self.swipeFromRow) {         // swipe down
                vertDelta = -1;
            } else if (row > self.swipeFromRow) {         // swipe up
                vertDelta = 1;
            }
            break;
    }
    
    NSLog(@"deltas are:  horiz = %i, vert = %i", (long)horzDelta, (long)vertDelta);
    
    *dColumn = horzDelta;
    *dRow = vertDelta;
    return YES;
}


@end
