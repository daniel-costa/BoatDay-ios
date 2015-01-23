//
//  SafetyFeature.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "SafetyFeature.h"

@implementation SafetyFeature

@dynamic name;
@dynamic details;
@dynamic required;

+ (NSString *)parseClassName {

    return @"SafetyFeature";
}

// For comparation in BDSafetyFeaturesViewController (need to compare with boat safetyFeatures to check or not the cell)
- (BOOL)isEqual:(id)other { 
    
    SafetyFeature *otherSafetyFeature = (SafetyFeature *)other;
    
    return [self.objectId isEqualToString:otherSafetyFeature.objectId];
    
}

@end
