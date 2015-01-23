//
//  DevProfile.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "DevProfile.h"

@implementation DevProfile

- (instancetype)initWithName:(NSString*)name position:(NSString*)position imageName:(NSString*)imageName{
    
    self = [super init];
    
    if (self) {

        _name = name;
        _position = position;
        _imageName = imageName;

    }
    
    return self;
    
}

@end
