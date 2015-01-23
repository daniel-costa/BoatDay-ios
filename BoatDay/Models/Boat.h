//
//  Boat.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

@class AdminMessage;

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface Boat : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (copy) NSString *name;

@property (retain) User *owner;

@property (retain) PFGeoPoint *location;

@property (copy) NSString *locationString;

@property (retain) NSNumber *buildYear;

@property (retain) NSNumber *length;

@property (retain) NSNumber *passengerCapacity;

@property (copy) NSString *type;

@property (retain) NSMutableArray *safetyFeatures;

@property (retain) NSNumber *status;

@property (retain) AdminMessage *rejectionMessage;

@property (retain) NSMutableArray *pictures;

@property (retain) NSNumber *selectedPictureIndex;

// Insurance properties

@property (copy) NSString *insuranceMinimumCoverage;

@property (retain) NSDate *insuranceExpirationDate;

@property (retain) PFFile *insurance;

@property (retain) NSNumber *deleted;

// Methods

- (PFObject *)copyShallow;

- (void)resetValuesToObject:(PFObject*)oldValue;

@end
