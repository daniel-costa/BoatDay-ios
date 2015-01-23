//
//  BDPaymentInfoViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 08/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface BDPaymentInfoViewController : BaseViewController

- (instancetype)initWithMerchantId:(NSString *)merchantID NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithRegistrationBoat:(Boat *)boat NS_DESIGNATED_INITIALIZER;

@end
