//
//  DevProfile.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

@interface DevProfile : NSObject

@property (copy, nonatomic) NSString *name;

@property (copy, nonatomic) NSString *position;

@property (copy, nonatomic) NSString *imageName;

- (instancetype)initWithName:(NSString*)name
          position:(NSString*)position
         imageName:(NSString*)imageName NS_DESIGNATED_INITIALIZER;

@end
