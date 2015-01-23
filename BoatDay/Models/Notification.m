//
//  Notification.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "Notification.h"

@implementation Notification

@dynamic boat;
@dynamic event;
@dynamic user;
@dynamic seatRequest;
@dynamic certification;
@dynamic review;
@dynamic text;
@dynamic read;
@dynamic notificationType;
@dynamic message;
@dynamic deleted;

+ (NSString *)parseClassName {

    return @"Notification";
}

@end
