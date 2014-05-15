//
//  MyScene.h
//  CookieCrunch
//
//  Created by Steve Yeom on 5/13/14.
//  Copyright 2014 2nd Jobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Level;
@class Swap;

@interface MyScene : CCScene {
    
}

@property (strong, nonatomic) Level *level;
@property (copy, nonatomic) void (^swapHandler)(Swap *swap);

+ (id)scene;
- (instancetype)init;
- (void)addSpriteForCookies:(NSSet *)cookies;
- (void)addTiles;
- (void)animateSwap:(Swap *)swap completion:(dispatch_block_t)completion;
- (void)animateInvalidSwap:(Swap *)swap completion:(dispatch_block_t)completion;

@end
