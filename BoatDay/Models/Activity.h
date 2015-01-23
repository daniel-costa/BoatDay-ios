//
//  Activity.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "ActivityType.h"

@interface Activity : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (copy) NSString *name;

@property (copy) NSString *text;

@property (retain) PFFile *picture;

@property (retain) PFFile *pictureGreen;

@property (retain) ActivityType *type;

@end
