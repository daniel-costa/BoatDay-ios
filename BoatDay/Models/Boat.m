//
//  Boat.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "Boat.h"

@implementation Boat

@dynamic name;
@dynamic owner;
@dynamic location;
@dynamic locationString;
@dynamic buildYear;
@dynamic length;
@dynamic passengerCapacity;
@dynamic type;
@dynamic safetyFeatures;
@dynamic status;
@dynamic rejectionMessage;
@dynamic pictures;
@dynamic selectedPictureIndex;
@dynamic deleted;

@dynamic insuranceMinimumCoverage;
@dynamic insuranceExpirationDate;
@dynamic insurance;

+ (NSString *)parseClassName {

    return @"Boat";
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
