//
//  User.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class HostRegistration;

@interface User : PFUser <PFSubclassing>

// Return the current user
+ (User *)currentUser;

@property (copy) NSString *facebookID;

@property (copy) NSString *aboutMe;

@property (retain) NSDate *birthday;

@property (copy) NSString *firstName;

@property (copy) NSString *lastName;

@property (copy) NSString *fullName;

@property (retain) NSMutableArray *pictures;

@property (copy) NSString *city;

@property (copy) NSString *state;

@property (copy) NSString *country;

@property (retain) NSMutableArray *activities;

@property (retain) NSMutableArray *reviews;

@property (retain) NSMutableArray *friendsFacebookID;

@property (retain) NSNumber *selectedPictureIndex;

@property (copy) NSString *firstLineAddress;

@property (copy) NSString *zipCode;

@property (copy) NSString *phoneNumber;

@property (retain) HostRegistration *hostRegistration;

@property (copy) NSString *braintreePaymentToken;

@property (copy) NSString *braintreeCustomerId;

@property (retain) NSNumber *deleted;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *fullLocation;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *shortName;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) PFObject *copyShallow;

- (void)resetValuesToObject:(PFObject*)oldValue;

- (BOOL)hasEventsGoingOn;

@end
