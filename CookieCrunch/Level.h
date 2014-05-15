//
//  Level.h
//  CookieCrunch
//
//  Created by Steve Yeom on 5/13/14.
//  Copyright (c) 2014 2nd Jobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cookie.h"
#import "Tile.h"
#import "Swap.h"

static const NSInteger NumColumns = 9;
static const NSInteger NumRows = 9;

@interface Level : NSObject

- (NSSet *)shuffle;
- (Cookie *)cookieAtColumn:(NSInteger )column row:(NSInteger)row;

- (instancetype)initWithFile:(NSString *)filename;
- (Tile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;

- (void)performSwap:(Swap *)swap;
- (BOOL)isPossibleSwap:(Swap *)swap;
@end
