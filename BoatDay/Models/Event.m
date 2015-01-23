//
//  Event.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "Event.h"

@implementation Event

@dynamic name;
@dynamic boat;
@dynamic host;
@dynamic startsAt;
@dynamic price;
@dynamic pickupLocation;
@dynamic activities;
@dynamic preReservedSeats;
@dynamic eventDescription;
@dynamic childrenPermitted;
@dynamic alcoholPermitted;
@dynamic smokingPermitted;
@dynamic status;
@dynamic locationName;
@dynamic availableSeats;
@dynamic seatRequests;
@dynamic endDate;
@dynamic deleted;
@dynamic rejectionMessage;

+ (NSString *)parseClassName {

    return @"Event";
}

- (PFObject *)copyShallow {
    PFObject *clone = [PFObject objectWithoutDataWithClassName:self.parseClassName
                                                      objectId:self.objectId];
    NSArray *keys = [self allKeys];
    for (NSString *key in keys) {
        clone[key] = self[key];
    }
    return clone;
}

- (void)resetValuesToObject:(PFObject*)oldValue {
    
    NSArray *keys = [self allKeys];
    for (NSString *key in keys) {
        
        if ([[oldValue allKeys] containsObject:key]) {
            self[key] = oldValue[key];
        }
        else {
            self[key] = [NSNull null];
        }
        
    }
    
}


@end
