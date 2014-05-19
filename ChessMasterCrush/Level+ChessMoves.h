//
//  Level+ChessMoves.h
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/18/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import "Level.h"

@interface Level (ChessMoves)

-(void)detectPossibleSwaps_castle;
-(void)detectPossibleSwaps_bishop;
@end
