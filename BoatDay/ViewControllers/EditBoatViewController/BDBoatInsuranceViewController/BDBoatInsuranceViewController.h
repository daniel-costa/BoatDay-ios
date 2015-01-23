//
//  BDBoatInsuranceViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 27/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^InsuranceBlock)(PFFile *insurance, NSDate *insuranceExpirationDate, NSString *insuranceMinimumCoverage);

@interface BDBoatInsuranceViewController : BaseViewController

@property (nonatomic, copy) InsuranceBlock insuranceBlock;

- (instancetype)initWithBoat:(Boat*)boat NS_DESIGNATED_INITIALIZER;

@end
