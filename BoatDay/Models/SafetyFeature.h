//
//  SafetyFeature.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface SafetyFeature : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (copy) NSString *name;

@property (copy) NSString *details;

@property (retain) NSNumber *required;

@end
