//
//  BDEventProfileGuestsViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef void (^UserGuestTappedBlock)(User *user, SeatRequest *seatRequest);

@interface BDEventProfileGuestsViewController : GAITrackedViewController

@property (nonatomic, copy) UserGuestTappedBlock userTapBlock;

- (instancetype)initWithEvent:(Event *)event NS_DESIGNATED_INITIALIZER;

@end
