//
//  AdminMessage.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "AdminMessage.h"

@implementation AdminMessage

@dynamic boat;
@dynamic user;
@dynamic event;
@dynamic text;
@dynamic deleted;

+ (NSString *)parseClassName {

    return @"AdminMessage";
}

@end
