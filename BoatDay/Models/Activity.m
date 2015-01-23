//
//  Activity.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "Activity.h"

@implementation Activity

@dynamic name;
@dynamic picture;
@dynamic pictureGreen;
@dynamic type;
@dynamic text;

+ (NSString *)parseClassName {

    return @"Activity";
}


- (BOOL)isEqual:(id)other {
    
    Activity *otherActivity = (Activity *)other;
    
    return [self.objectId isEqualToString:otherActivity.objectId];
    
}

@end
