//
//  Review.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "Review.h"

@implementation Review

@dynamic text;
@dynamic stars;
@dynamic from;
@dynamic to;
@dynamic deleted;

+ (NSString *)parseClassName {

    return @"Review";
}

@end
