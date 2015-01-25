//
//  BDEventListViewController.h
//  BoatDay
//
//  Created by Mieraidihaimu Mieraisan on 24/01/15.
//  Copyright (c) 2015 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^EventTappedBlock)(Event *event);

@interface BDEventListViewController : BaseViewController

@property (nonatomic, copy) EventTappedBlock eventTappedBlock;

- (instancetype)initWithEvents:(NSArray *)events NS_DESIGNATED_INITIALIZER;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (instancetype)initWithEventsHostingAndHistory:(NSArray *)events;
@end
