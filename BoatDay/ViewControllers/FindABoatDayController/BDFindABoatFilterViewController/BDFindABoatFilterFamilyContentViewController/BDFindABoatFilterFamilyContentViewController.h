//
//  BDFindABoatFilterFamilyContentViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 05/08/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface BDFindABoatFilterFamilyContentViewController : BaseViewController

- (instancetype)initWithFilterDictionary:(NSMutableDictionary*)filterDictionary NS_DESIGNATED_INITIALIZER;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
