//
//  MyScene.m
//  CookieCrunch
//
//  Created by Steve Yeom on 5/13/14.
//  Copyright 2014 2nd Jobs. All rights reserved.
//

#import "MyScene.h"
#import "Cookie.h"
#import "Level.h"
#import "Swap.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface MyScene()

@property (strong, nonatomic) CCNode *gameLayer;
@property (strong, nonatomic) CCNode *cookiesLayer;
@property (strong, nonatomic) CCNode *tilesLayer;

@property (assign, nonatomic) NSInteger swipeFromColumn;
@property (assign, nonatomic) NSInteger swipeFromRow;

@property (strong, nonatomic) CCSprite *selectionSprite;

@property (strong, nonatomic) ALBuffer *swapSound;
@property (strong, nonatomic) ALBuffer *invalidSwapSound;
@property (strong, nonatomic) ALBuffer *matchSound;
@property (strong, nonatomic) ALBuffer *fallingCookieSound;
@property (strong, nonatomic) ALBuffer *addCookieSound;

@end

@implementation MyScene

+(id)scene{
  return [[self alloc] init];
}

- (instancetype)init
{
  self = [super init];
  if (!self) return nil;
  
  self.userInteractionEnabled = YES;
  
  CGSize winsize = [[CCDirector sharedDirector] viewSize];
  
  CCSprite *background = [CCSprite spriteWithImageNamed:@"Background.png"];
  [background setScaleX:winsize.width/background.boundingBox.size.width];
  [background setScaleY:winsize.height/background.boundingBox.size.height];
  background.anchorPoint = CGPointZero;
  [self addChild:background];
  
  self.gameLayer = [CCNode node];
  self.gameLayer.position = ccp(winsize.width/2, winsize.height/2);
  [self addChild:self.gameLayer];

  CGPoint layerPosition = ccp(-TileWidth*NumColumns/2, -TileHeight*NumRows/2);
  
  self.tilesLayer = [CCNode node];
  self.tilesLayer.position = layerPosition;
  [self.gameLayer addChild:self.tilesLayer];

  self.cookiesLayer = [CCNode node];
  self.cookiesLayer.position = layerPosition;
  [self.gameLayer addChild:self.cookiesLayer];
  
  self.swipeFromColumn = self.swipeFromRow = NSNotFound;
  
  self.selectionSprite = [CCSprite node];
  
  [self preloadResources];


  return self;
}

- (void)preloadResources {
  self.swapSound = [[OALSimpleAudio sharedInstance] preloadEffect:@"Chomp.wav"];
  self.invalidSwapSound = [[OALSimpleAudio sharedInstance] preloadEffect:@"Error.wav"];
  self.matchSound = [[OALSimpleAudio sharedInstance] preloadEffect:@"Ka-Ching.wav"];
  self.fallingCookieSound = [[OALSimpleAudio sharedInstance] preloadEffect:@"Scrape.wav"];
  self.addCookieSound = [[OALSimpleAudio sharedInstance] preloadEffect:@"Drip.wav"];
}

- (void)addTiles {
  for (NSInteger row = 0; row < NumRows; row++){
    for (NSInteger column = 0; column < NumColumns; column++) {
      if ([self.level tileAtColumn:column row:row] != nil){
        CCSprite *tile = [CCSprite spriteWithImageNamed:@"Tile.png"];
        tile.position = [self pointForColumn:column row:row];
        [self.tilesLayer addChild:tile];
      }
    }
  }
}

- (void)addSpriteForCookies:(NSSet *)cookies{
  for (Cookie *cookie in cookies) {
    CCSprite *sprite = [CCSprite spriteWithImageNamed:cookie.spriteName];
    sprite.position = [self pointForColumn:cookie.column row:cookie.row];
    [self.cookiesLayer addChild:sprite];
    cookie.sprite = sprite;
  }
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row{
  return ccp(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight/2);
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint location = [touch locationInNode:self.cookiesLayer];
  
  NSInteger column, row;
  if ([self convertPoint:location toColumn:&column row:&row]){
    Cookie *cookie = [self.level cookieAtColumn:column row:row];
    if (cookie != nil){
      [self showSelectionIndicatorForCookie:cookie];

      self.swipeFromColumn = column;
      self.swipeFromRow = row;
    }
  }
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row{
  NSParameterAssert(column);
  NSParameterAssert(row);
  
  if (point.x >= 0 && point.x < NumColumns*TileWidth &&
      point.y >= 0 && point.y < NumRows*TileHeight) {
    *column = point.x / TileWidth;
    *row = point.y / TileHeight;
    
    return YES;
  } else {
    *column = NSNotFound;
    *row = NSNotFound;
    
    return NO;
  }
  
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  if (self.swipeFromColumn == NSNotFound) return;
  
  CGPoint location = [touch locationInNode:self.cookiesLayer];
  
  NSInteger column, row;
  if ([self convertPoint:location toColumn:&column row:&row]){
    NSInteger horzDelta = 0, vertDelta = 0;
    if (column < self.swipeFromColumn) {
      horzDelta = -1;
    } else if (column > self.swipeFromColumn){
      horzDelta = 1;
    } else if (row < self.swipeFromRow){
      vertDelta = -1;
    } else if (row > self.swipeFromRow){
      vertDelta = 1;
    }
    
    if (horzDelta != 0 || vertDelta !=0) {
      [self trySwapHorizontal:horzDelta vertical:vertDelta];
      [self hideSelectionIndicator];
      
      self.swipeFromColumn = NSNotFound;
    }
  }
  
}

- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta{
  NSInteger toColumn = self.swipeFromColumn + horzDelta;
  NSInteger toRow = self.swipeFromRow + vertDelta;
  
  if (toColumn < 0 || toColumn >= NumColumns) return;
  if (toRow < 0 || toRow >= NumRows) return;
    
  Cookie *toCookie = [self.level cookieAtColumn:toColumn row:toRow];
  if (toCookie == nil) return;
  
  Cookie *fromCookie = [self.level cookieAtColumn:self.swipeFromColumn row:self.swipeFromRow];
  
  NSLog(@"*** swapping %@ with %@", fromCookie, toCookie);
  
  if (self.swapHandler != nil) {
    Swap *swap = [Swap new];
    swap.cookieA = fromCookie;
    swap.cookieB = toCookie;
    
    self.swapHandler(swap);
  }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  if (self.selectionSprite.parent != nil && self.swipeFromColumn != NSNotFound) {
    [self hideSelectionIndicator];
  }
  
  self.swipeFromColumn = self.swipeFromRow = NSNotFound;
}


- (void)toucheCancelled:(UITouch *)touche withEvent:(UIEvent *)event {
  [self touchEnded:touche withEvent:event];
}

- (void)animateSwap:(Swap *)swap completion:(dispatch_block_t)completion {
  swap.cookieA.sprite.zOrder = 100;
  swap.cookieB.sprite.zOrder = 90;
  
  const NSTimeInterval Duration = 0.3;
  
  CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration:Duration position:swap.cookieB.sprite.position];
  CCActionEase *moveAEaseOut = [CCActionEase actionWithAction:moveA];
  CCActionSequence *seq = [CCActionSequence actions:moveAEaseOut, [CCActionCallBlock actionWithBlock:completion], nil];
  [swap.cookieA.sprite runAction:seq];

  CCActionMoveTo *moveB = [CCActionMoveTo actionWithDuration:Duration position:swap.cookieA.sprite.position];
  CCActionEase *moveBEaseOut = [CCActionEase actionWithAction:moveB];
  [swap.cookieB.sprite runAction:moveBEaseOut];
  
  [[OALSimpleAudio sharedInstance] playEffect:@"Chomp.wav"];
}

- (void)showSelectionIndicatorForCookie:(Cookie *)cookie {
  if (self.selectionSprite.parent != nil) {
    [self.selectionSprite removeFromParent];
    
  }
  
  CCSprite *texture = [CCSprite spriteWithImageNamed:[cookie highlightedSpriteName]];
  texture.anchorPoint = ccp(0, 0);
  self.selectionSprite = texture;
  
  [self.selectionSprite setOpacity:1.0];
  [cookie.sprite addChild:self.selectionSprite];
}

- (void)hideSelectionIndicator {
  CCActionFadeOut *fadeOut = [CCActionFadeOut actionWithDuration:0.3];
  CCActionCallBlock *block = [CCActionCallBlock actionWithBlock:^{
    [self.selectionSprite removeFromParent];
  }];
  
  CCActionSequence *seq = [CCActionSequence actions:fadeOut, block, nil];
  [self.selectionSprite runAction:seq];
}

- (void)animateInvalidSwap:(Swap *)swap completion:(dispatch_block_t)completion {
  swap.cookieA.sprite.zOrder = 100;
  swap.cookieB.sprite.zOrder = 90;
  
  const NSTimeInterval Duration = 0.2;
  
  CCActionMoveTo *moveA = [CCActionMoveTo actionWithDuration:Duration position:swap.cookieB.sprite.position];
  CCActionEaseBounce *moveAEaseBounce = [CCActionEaseBounce actionWithAction:moveA];

  CCActionMoveTo *moveB = [CCActionMoveTo actionWithDuration:Duration position:swap.cookieA.sprite.position];
  CCActionEaseBounce *moveBEaseBounce = [CCActionEaseBounce actionWithAction:moveB];

  CCActionMoveTo *moveA2 = [CCActionMoveTo actionWithDuration:Duration position:swap.cookieB.sprite.position];
  CCActionEaseBounce *moveAEaseBounce2 = [CCActionEaseBounce actionWithAction:moveA2];
  
  CCActionMoveTo *moveB2 = [CCActionMoveTo actionWithDuration:Duration position:swap.cookieA.sprite.position];
  CCActionEaseBounce *moveBEaseBounce2 = [CCActionEaseBounce actionWithAction:moveB2];

  CCActionSequence *seq = [CCActionSequence actions:moveAEaseBounce, moveBEaseBounce, [CCActionCallBlock actionWithBlock:completion], nil];
  CCActionSequence *seq2 = [CCActionSequence actions:moveBEaseBounce2, moveAEaseBounce2, nil];

  [swap.cookieA.sprite runAction:seq];
  
  [swap.cookieB.sprite runAction:seq2];

  [[OALSimpleAudio sharedInstance] playEffect:@"Error.wav"];
}

@end
