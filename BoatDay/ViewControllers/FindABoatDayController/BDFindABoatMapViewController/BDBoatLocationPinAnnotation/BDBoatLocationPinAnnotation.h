//
//  BDBoatLocationPinAnnotation.h
//  BoatDay
//
//  Created by Diogo Nunes on 31/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BDBoatLocationPinAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) Event *event;

@end

