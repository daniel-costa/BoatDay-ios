//
//  Event.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface Event : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (copy) NSString *name;

@property (retain) Boat *boat;

@property (retain) User *host;

@property (retain) NSDate *startsAt;

@property (retain) NSDate *endDate;

@property (retain) NSNumber *price;

@property (retain) PFGeoPoint *pickupLocation;

@property (retain) NSMutableArray *activities;

@property (retain) NSNumber *preReservedSeats;

@property (copy) NSString *eventDescription;

@property (retain) NSNumber *childrenPermitted;

@property (retain) NSNumber *alcoholPermitted;

@property (retain) NSNumber *smokingPermitted;

@property (retain) NSNumber *status;

@property (copy) NSString *locationName;

@property (retain) NSNumber *availableSeats;

@property (retain) NSNumber *freeSeats;

@property (retain) NSMutableArray *seatRequests;

@property (retain) NSNumber *deleted;

@property (retain) AdminMessage *rejectionMessage;

// Methods

- (PFObject *)copyShallow;

- (void)resetValuesToObject:(PFObject*)oldValue;

@end
