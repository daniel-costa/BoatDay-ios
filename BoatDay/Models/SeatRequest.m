//
//  SeatRequest.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "SeatRequest.h"

@implementation SeatRequest

@dynamic user;
@dynamic event;
@dynamic numberOfSeats;
@dynamic status;
@dynamic pendingInvite;
@dynamic message;
@dynamic transactionId;
@dynamic userDidPayFromTheApp;
@dynamic deleted;

+ (NSString *)parseClassName {

    return @"SeatRequest";
}


@end
