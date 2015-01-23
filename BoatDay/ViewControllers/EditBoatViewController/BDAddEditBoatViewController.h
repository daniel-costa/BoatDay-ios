//
//  BDEditBoatViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^boatDeletedBlock)();

@interface BDAddEditBoatViewController : BaseViewController

@property (copy, nonatomic) NSString *locationString;

@property (nonatomic, copy) boatDeletedBlock boatDeletedBlock;

- (instancetype)initWithBoat:(Boat *)boat NS_DESIGNATED_INITIALIZER;

@end
