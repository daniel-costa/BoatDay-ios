//
//  Review.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "Report.h"

@implementation Report

@dynamic message;
@dynamic from;
@dynamic to;
@dynamic event;
@dynamic deleted;

+ (NSString *)parseClassName {

    return @"Report";
}

@end
