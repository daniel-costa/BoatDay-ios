//
//  Certification.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "Certification.h"

@implementation Certification

@dynamic message;
@dynamic picture;
@dynamic type;
@dynamic status;
@dynamic user;
@dynamic deleted;

+ (NSString *)parseClassName {

    return @"Certification";
}

- (BOOL)isEqual:(id)other {
    
    Certification *otherActivity = (Certification *)other;
    
    return [self.objectId isEqualToString:otherActivity.objectId];
    
}

@end
