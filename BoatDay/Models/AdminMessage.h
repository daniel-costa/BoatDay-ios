//
//  AdminMessage.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class Boat;

@interface AdminMessage : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) Boat *boat;

@property (retain) User *user;

@property (retain) Event *event;

@property (copy) NSString *text;

@property (retain) NSNumber *deleted;

@end
