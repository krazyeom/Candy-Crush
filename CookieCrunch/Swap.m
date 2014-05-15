//
//  Swap.m
//  CookieCrunch
//
//  Created by Steve Yeom on 5/15/14.
//  Copyright (c) 2014 2nd Jobs. All rights reserved.
//

#import "Swap.h"
#import "Cookie.h"


@implementation Swap


- (NSString *)description {
  return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.cookieA, self.cookieB];
}

- (BOOL)isEqual:(id)object {

  if (![object isKindOfClass:[Swap class]]) return NO;
  
  Swap *other = (Swap *)object;
  return (other.cookieA == self.cookieA && other.cookieB == self.cookieB) ||
  (other.cookieB == self.cookieA && other.cookieA == self.cookieB);
}

- (NSUInteger)hash {
  return [self.cookieA hash] ^ [self.cookieB hash];
}


@end
