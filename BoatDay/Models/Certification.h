//
//  Certification.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "CertificationType.h"
#import "User.h"

@interface Certification : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (copy) NSString *message;

@property (retain) PFFile *picture;

@property (retain) CertificationType *type;

@property (retain) NSNumber *status;

@property (retain) User *user;

@property (retain) NSNumber *deleted;

@end
