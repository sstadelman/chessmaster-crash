//
//  ChessPiece.h
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/16/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

@import SpriteKit;

static const NSUInteger NumPieceTypes = 6;

@interface ChessPiece : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger pieceType;
@property (strong, nonatomic) SKSpriteNode *sprite;

- (NSString *)spriteName;
- (NSString *)highlightedSpriteName;

@end