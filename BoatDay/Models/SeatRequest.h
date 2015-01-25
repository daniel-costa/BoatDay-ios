//
//  SeatRequest.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface SeatRequest : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) User *user;

@property (retain) Event *event;

@property (retain) NSNumber *numberOfSeats;

@property (retain) NSNumber *status;

@property (retain) NSNumber *pendingInvite;

@property (copy) NSString *message;

@property (copy) NSString *transactionId;

@property (retain) NSNumber *userDidPayFromTheApp;

@property (retain) NSNumber *deleted;


@end
