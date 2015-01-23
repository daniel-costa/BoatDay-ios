//
//  HostRegistration.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class AdminMessage;

@interface HostRegistration : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) User *user;

@property (retain) NSNumber *status;

@property (copy) NSString *merchantMessage;

@property (copy) NSString *merchantId;

@property (copy) NSString *merchantStatus;

@property (retain) AdminMessage *rejectionMessage;

@property (retain) PFFile *driversLicenseImage;

@property (retain) NSNumber *deleted;

@end
