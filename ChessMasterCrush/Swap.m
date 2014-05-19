//
//  Swap.m
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/17/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import "Swap.h"

@implementation Swap

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.pieceA, self.pieceB];
}

- (BOOL)isEqual:(id)object {
    // You can only compare this object against other RWTSwap objects.
    if (![object isKindOfClass:[Swap class]]) return NO;
    
    // Two swaps are equal if they contain the same cookie, but it doesn't
    // matter whether they're called A in one and B in the other.
    Swap *other = (Swap *)object;
    return (other.pieceA == self.pieceA && other.pieceB == self.pieceB) ||
    (other.pieceB == self.pieceA && other.pieceA == self.pieceB);
}

- (NSUInteger)hash {
    return [self.pieceA hash] ^ [self.pieceB hash];
}

@end
