//
//  NSObject+BlockAfterDelay.h
//
//  Created by Diogo Nunes on 07/10/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BlockAfterDelay)
- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay;

@end
