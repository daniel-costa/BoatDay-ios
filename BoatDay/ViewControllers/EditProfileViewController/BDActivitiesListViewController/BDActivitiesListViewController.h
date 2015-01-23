//
//  BDActivitiesListViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 25/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

// Define activities change block
typedef void (^ActivitiesChangeBlock)(NSMutableArray *activities);


@interface BDActivitiesListViewController : BaseViewController

// Activities block
@property (nonatomic, copy) ActivitiesChangeBlock activitiesChangeBlock;

// Methods
- (instancetype)initWithActivities:(NSMutableArray *)activities NS_DESIGNATED_INITIALIZER;

@end
