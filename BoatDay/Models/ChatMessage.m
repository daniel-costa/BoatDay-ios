//
//  ChatMessage.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage

@dynamic user;
@dynamic event;
@dynamic text;

@dynamic sender;
@dynamic date;
@dynamic deleted;

+ (NSString *)parseClassName {

    return @"ChatMessage";
}

- (NSDate*) date {
    return self.createdAt;
}

- (NSString*) sender {
    return self.user.objectId;
}

@end
