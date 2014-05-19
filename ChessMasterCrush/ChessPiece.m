//
//  ChessPiece.m
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/16/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import "ChessPiece.h"

@implementation ChessPiece

- (NSString *)spriteName {
    static NSString * const spriteNames[] = {
        @"Croissant",   //pawn
        @"Cupcake",     //castle
        @"Danish",      //knight
        @"Donut",       //bishop
        @"Macaroon",    //queen
        @"SugarCookie", //king
    };
    
    return spriteNames[self.pieceType - 1];
}

- (NSString *)highlightedSpriteName {
    static NSString * const highlightedSpriteNames[] = {
        @"Croissant-Highlighted",
        @"Cupcake-Highlighted",
        @"Danish-Highlighted",
        @"Donut-Highlighted",
        @"Macaroon-Highlighted",
        @"SugarCookie-Highlighted",
    };
    
    return highlightedSpriteNames[self.pieceType - 1];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld,%ld)", (long)self.pieceType,
            (long)self.column, (long)self.row];
}

@end
