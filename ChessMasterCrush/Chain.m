//
//  Chain.m
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/18/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import "Chain.h"

@implementation Chain {
    NSMutableArray *_pieces;
}

- (void)addPiece:(ChessPiece *)piece {
    if (_pieces == nil) {
        _pieces = [NSMutableArray array];
    }
    [_pieces addObject:piece];
}

- (NSArray *)pieces {
    return _pieces;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld pieces:%@", (long)self.chainType, self.pieces];
}



@end