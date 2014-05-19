//
//  Chain.h
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/18/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChessPiece;

typedef NS_ENUM(NSUInteger, ChainType) {
    ChainTypeHorizontal,
    ChainTypeVertical,
};

@interface Chain : NSObject

@property (strong, nonatomic, readonly) NSArray *pieces;

@property (assign, nonatomic) ChainType chainType;

@property (assign, nonatomic) NSUInteger score;

- (void)addPiece:(ChessPiece *)piece;

@end