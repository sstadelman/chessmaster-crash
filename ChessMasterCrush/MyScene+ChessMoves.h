//
//  MyScene+ChessMoves.h
//  ChessMasterCrush
//
//  Created by Stadelman, Stan on 5/18/14.
//  Copyright (c) 2014 Stan Stadelman. All rights reserved.
//

#import "MyScene.h"

@interface MyScene (ChessMoves)

-(BOOL)deltasForPieceAtColumn:(NSInteger)column row:(NSInteger)row deltaColumn:(NSInteger *)dColumn deltaRow:(NSInteger *)dRow;

@end
