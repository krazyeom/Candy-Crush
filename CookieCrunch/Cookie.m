//
//  Cookie.m
//  CookieCrunch
//
//  Created by Steve Yeom on 5/13/14.
//  Copyright (c) 2014 2nd Jobs. All rights reserved.
//

#import "Cookie.h"

@implementation Cookie

- (NSString *)spriteName{
  static NSString * const spriteNames[] = {
    @"Croissant.png",
    @"Cupcake.png",
    @"Danish.png",
    @"Donut.png",
    @"Macaroon.png",
    @"SugarCookie.png",
  };
  
  return spriteNames[self.cookieType - 1];
}

- (NSString *)highlightedSpriteName{
  static NSString * const highlightedSpriteNames[] = {
    @"Croissant-Highlighted.png",
    @"Cupcake-Highlighted.png",
    @"Danish-Highlighted.png",
    @"Donut-Highlighted.png",
    @"Macaroon-Highlighted.png",
    @"SugarCookie-Highlighted.png",
  };
  
  return highlightedSpriteNames[self.cookieType - 1];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"type:%ld square:(%ld,%ld)", (long)self.cookieType, (long)self.column, (long)self.row];
}

@end
