//
//  NSObject+BlockAfterDelay.m
//
//  Created by Diogo Nunes on 07/10/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import "NSObject+BlockAfterDelay.h"

@implementation NSObject (BlockAfterDelay)

- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay
{
    block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:)
               withObject:block
               afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}

@end
