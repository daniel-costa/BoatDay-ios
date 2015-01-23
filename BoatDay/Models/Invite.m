//
//  Invite.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "Invite.h"

@implementation Invite

@dynamic event;
@dynamic from;
@dynamic to;
@dynamic deleted;

+ (NSString *)parseClassName {

    return @"Invite";
}

@end
