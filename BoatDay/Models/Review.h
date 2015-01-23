//
//  Review.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "User.h"

@interface Review : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (copy) NSString *text;

@property (retain) NSNumber *stars;

@property (retain) User *from;

@property (retain) User *to;

@property (retain) NSNumber *deleted;

@end
