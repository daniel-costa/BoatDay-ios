//
//  BDSafetyFeaturesListViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 28/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^SafetyFeaturesArrayBlock)(NSMutableArray *safetyFeatures);

@interface BDSafetyFeaturesListViewController : BaseViewController

@property (nonatomic, copy) SafetyFeaturesArrayBlock safetyFeaturesArrayBlock;

- (instancetype)initWithSelectedSafetyFeatures:(NSMutableArray *)selectedSafetyFeatures NS_DESIGNATED_INITIALIZER;

@end
