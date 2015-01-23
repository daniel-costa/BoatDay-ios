//
//  BDViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface BDBoatMessageViewController : BaseViewController

- (instancetype)initWithNotificationForBoat:(Boat*)boat NS_DESIGNATED_INITIALIZER;

@end
