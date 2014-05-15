//
//  Level.m
//  CookieCrunch
//
//  Created by Steve Yeom on 5/13/14.
//  Copyright (c) 2014 2nd Jobs. All rights reserved.
//

#import "Level.h"

@interface Level(){
  
}

@property (strong, nonatomic) NSSet *possibleSwaps;

@end

@implementation Level {
  Cookie *_cookies[NumColumns][NumRows];
  Tile *_tiles[NumColumns][NumRows];
}

- (NSSet *)shuffle{
  NSSet *set;
  do {
    set = [self createInitialCookies];
    [self detectPossibleSwaps];
    NSLog(@"possible swaps: %@", self.possibleSwaps);

  }
  while ([self.possibleSwaps count] == 0);
  
  return set;
}

- (void)detectPossibleSwaps {
  NSMutableSet *set = [NSMutableSet set];
  
  for (NSInteger row = 0; row < NumRows; row++) {
    for (NSInteger column = 0; column < NumColumns; column++) {
      
      Cookie *cookie = _cookies[column][row];
      if (cookie != nil) {
        
        
        if (column < NumColumns - 1) {
          
          Cookie *other = _cookies[column + 1][row];
          if (other != nil) {
        
            _cookies[column][row] = other;
            _cookies[column + 1][row] = cookie;
            
        
            if ([self hasChainAtColumn:column + 1 row:row] ||
                [self hasChainAtColumn:column row:row]) {
              
              Swap *swap = [[Swap alloc] init];
              swap.cookieA = cookie;
              swap.cookieB = other;
              [set addObject:swap];
            }
            
            
            _cookies[column][row] = cookie;
            _cookies[column + 1][row] = other;
          }
        }
        
        if (row < NumRows - 1) {
          
          Cookie *other = _cookies[column][row + 1];
          if (other != nil) {
            // Swap them
            _cookies[column][row] = other;
            _cookies[column][row + 1] = cookie;
            
            if ([self hasChainAtColumn:column row:row + 1] ||
                [self hasChainAtColumn:column row:row]) {
              
              Swap *swap = [[Swap alloc] init];
              swap.cookieA = cookie;
              swap.cookieB = other;
              [set addObject:swap];
            }
            
            _cookies[column][row] = cookie;
            _cookies[column][row + 1] = other;
          }
        }
      }
    }
  }
  
  self.possibleSwaps = set;
}

- (BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row {
  NSUInteger cookieType = _cookies[column][row].cookieType;
  
  NSUInteger horzLength = 1;
  for (NSInteger i = column - 1; i >= 0 && _cookies[i][row].cookieType == cookieType; i--, horzLength++) ;
  for (NSInteger i = column + 1; i < NumColumns && _cookies[i][row].cookieType == cookieType; i++, horzLength++) ;
  if (horzLength >= 3) return YES;
  
  NSUInteger vertLength = 1;
  for (NSInteger i = row - 1; i >= 0 && _cookies[column][i].cookieType == cookieType; i--, vertLength++) ;
  for (NSInteger i = row + 1; i < NumRows && _cookies[column][i].cookieType == cookieType; i++, vertLength++) ;
  return (vertLength >= 3);
}

- (NSSet *)createInitialCookies {
  NSMutableSet *set = [NSMutableSet set];
  
  for (NSInteger row = 0; row < NumRows ; row++){
    for (NSInteger column = 0; column < NumColumns ; column++) {
      if (_tiles[column][row] != nil) {
//        NSInteger cookieType = arc4random_uniform(NumCookieTypes) + 1;
        NSUInteger cookieType;
        do {
          cookieType = arc4random_uniform(NumCookieTypes) + 1;
        }
        while ((column >= 2 &&
                _cookies[column - 1][row].cookieType == cookieType &&
                _cookies[column - 2][row].cookieType == cookieType)
               ||
               (row >= 2 &&
                _cookies[column][row - 1].cookieType == cookieType &&
                _cookies[column][row - 2].cookieType == cookieType));
        
        Cookie *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
        [set addObject:cookie];
      }
    }
  }
  
  return set;
}

- (Cookie *)createCookieAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)cookieType {
  Cookie *cookie = [[Cookie alloc] init];
  cookie.cookieType = cookieType;
  cookie.column = column;
  cookie.row = row;
  _cookies[column][row] = cookie;
  return cookie;
}

- (Cookie *)cookieAtColumn:(NSInteger )column row:(NSInteger)row{
  NSAssert1(column >= 0 && column < NumColumns, @"invalid column %ld", (long)column);
  NSAssert1(row >= 0 && row < NumRows, @"invalid row %ld", (long)row);
  
  return _cookies[column][row];
}

- (NSDictionary *)loadJSON:(NSString *)filename{
  NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
  if (path == nil) {
    NSLog(@"Could not find level file: %@", filename);
    return nil;
  }
  
  NSError *error;
  NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
  if (data == nil) {
    NSLog(@"Could not find level file: %@, error %@", filename, error);
    return nil;
  }
  
  NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
  if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
    NSLog(@"Level file '%@' is not vaild JSON: %@", filename, error);
    return nil;
  }
  
  return dictionary;
}

- (instancetype)initWithFile:(NSString *)filename{
  self = [super init];
  
  if (self != nil) {
    NSDictionary *dictionary = [self loadJSON:filename];
    
    [dictionary[@"tiles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
      [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
        NSInteger tileRow = NumRows - row - 1;
        
        if ([value intValue] == 1){
          _tiles[column][tileRow] = [[Tile alloc] init];
        }
      }];
    }];
  }
  
  return self;
}

- (Tile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
  NSAssert1(column >= 0 && column < NumColumns, @"Invaild column: %ld", (long)column);
  NSAssert1(row >= 0 && row < NumRows, @"Invaild row: %ld", (long)row);
  
  return _tiles[column][row];
}

- (void)performSwap:(Swap *)swap {
  NSInteger columnA = swap.cookieA.column;
  NSInteger rowA = swap.cookieA.row;
  
  NSInteger columnB = swap.cookieB.column;
  NSInteger rowB = swap.cookieB.row;
  
  _cookies[columnA][rowA] = swap.cookieB;
  swap.cookieB.column = columnA;
  swap.cookieB.row = rowA;
  
  _cookies[columnB][rowB] = swap.cookieA;
  swap.cookieA.column = columnB;
  swap.cookieA.row = rowB;
}

- (BOOL)isPossibleSwap:(Swap *)swap {
  return [self.possibleSwaps containsObject:swap];
}

@end
