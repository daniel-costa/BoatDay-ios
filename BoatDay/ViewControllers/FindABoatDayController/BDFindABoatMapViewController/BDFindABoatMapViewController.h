//
//  BDFindABoatMapViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EventTappedBlock)(Event *event);

@interface BDFindABoatMapViewController : UIViewController

@property (nonatomic, copy) EventTappedBlock eventTappedBlock;

@property (nonatomic, strong) PFGeoPoint *mapCenter;

- (instancetype)initWithEvents:(NSArray *)events NS_DESIGNATED_INITIALIZER;

@end
