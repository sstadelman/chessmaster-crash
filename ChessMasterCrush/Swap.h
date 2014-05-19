//
//  Swap.h
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/17/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChessPiece.h"

@interface Swap : NSObject

@property (strong, nonatomic) ChessPiece *pieceA;
@property (strong, nonatomic) ChessPiece *pieceB;

@end
