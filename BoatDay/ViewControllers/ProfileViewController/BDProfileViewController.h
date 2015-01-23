//
//  BDProfileViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 30/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface BDProfileViewController : BaseViewController

- (instancetype)initWithUser:(User *)profile andProfileType:(ProfileType)profileType NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithSeatRequest:(SeatRequest*)seatRequest NS_DESIGNATED_INITIALIZER;

@end
