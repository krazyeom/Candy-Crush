//
//  Cookie.h
//  CookieCrunch
//
//  Created by Steve Yeom on 5/13/14.
//  Copyright (c) 2014 2nd Jobs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCSprite;

static const NSUInteger NumCookieTypes = 6;

@interface Cookie : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger cookieType;
@property (strong, nonatomic) CCSprite *sprite;

- (NSString *)spriteName;
- (NSString *)highlightedSpriteName;

@end
