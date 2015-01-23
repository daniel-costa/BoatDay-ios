//
//  BDFindABoatEventsViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^EventTappedBlock)(Event *event);

@interface BDFindABoatEventsViewController : BaseViewController

@property (nonatomic, copy) EventTappedBlock eventTappedBlock;

@property (nonatomic) BOOL showCardsWithStatus;

- (instancetype)initWithEvents:(NSArray *)events NS_DESIGNATED_INITIALIZER;

@end
