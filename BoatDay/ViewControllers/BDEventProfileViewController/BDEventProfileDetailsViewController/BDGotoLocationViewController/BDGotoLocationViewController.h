//
//  BDGotoLocationViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 25/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface BDGotoLocationViewController : BaseViewController

- (instancetype)initWithPFGeoPoint:(PFGeoPoint *)location NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithEvent:(Event*)event NS_DESIGNATED_INITIALIZER;

@end
