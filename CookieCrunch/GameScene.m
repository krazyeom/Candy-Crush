//
//  GameScene.m
//  CookieCrunch
//
//  Created by Steve Yeom on 5/14/14.
//  Copyright 2014 2nd Jobs. All rights reserved.
//

#import "GameScene.h"
#import "Level.h"
#import "MyScene.h"

@interface GameScene ()

@property (strong, nonatomic) Level *level;
@property (strong, nonatomic) MyScene *myscene;


@end

@implementation GameScene

+(id)scene{
  return [[self alloc] init];
}

- (instancetype)init
{
  self = [super init];
  if (!self) return nil;
  
  self.userInteractionEnabled = YES;
  
  self.myscene = [MyScene node];
  
  self.level = [[Level alloc] initWithFile:@"Level_1"];
  self.myscene.level = self.level;
  
  [self.myscene addTiles];
  
  id block = ^(Swap *swap){
    self.userInteractionEnabled = NO;
    
    if ([self.level isPossibleSwap:swap]) {
      [self.level performSwap:swap];
      [self.myscene animateSwap:swap completion:^{
        self.userInteractionEnabled = YES;
      }];
    } else {
      [self.myscene animateInvalidSwap:swap completion:^{
        self.userInteractionEnabled = YES;
      }];
    }
  };
  
  self.myscene.swapHandler = block;
  
  [self beginGame];
  
  [self addChild:self.myscene];
  
  
  return self;
}

- (void)beginGame {
  [self shuffle];
}

- (void)shuffle {
  NSSet *newCookies = [self.level shuffle];
  [self.myscene addSpriteForCookies:newCookies];
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

- (void)onEnter {
  [super onEnter];
}

@end
