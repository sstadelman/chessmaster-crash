//
//  Tile.h
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/17/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tile : NSObject

- (instancetype)initWithFile:(NSString *)filename;
- (Tile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;

@end
