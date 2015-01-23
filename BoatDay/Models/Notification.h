//
//  Notification.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@class Boat;
@class SeatRequest;
@class Certification;
@class Review;
@class AdminMessage;

@interface Notification : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) Boat *boat;

@property (retain) Event *event;

@property (retain) User *user;

@property (retain) SeatRequest *seatRequest;

@property (retain) Certification *certification;

@property (retain) AdminMessage *message;

@property (retain) Review *review;

@property (copy) NSString *text;

@property (retain) NSNumber *read;

@property (retain) NSNumber *notificationType;

@property (retain) NSNumber *deleted;

@end
