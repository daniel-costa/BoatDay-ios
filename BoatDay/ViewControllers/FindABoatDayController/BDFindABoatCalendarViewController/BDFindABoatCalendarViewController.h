//
//  BDFindABoatCalendarViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^EventTappedBlock)(Event *event);

@interface BDFindABoatCalendarViewController : BaseViewController

@property (nonatomic, copy) EventTappedBlock eventTappedBlock;

- (instancetype)initWithEvents:(NSArray *)events NS_DESIGNATED_INITIALIZER;

@end
