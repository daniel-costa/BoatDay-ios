//
//  ChatMessage.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "JSQMessageData.h"

@interface ChatMessage : PFObject <PFSubclassing, JSQMessageData>

+ (NSString *)parseClassName;

@property (retain) User *user;

@property (retain) Event *event;

@property (copy) NSString *text;

@property (copy) NSString *sender;

@property (retain) NSDate *date;

@property (retain) NSNumber *deleted;

@end
