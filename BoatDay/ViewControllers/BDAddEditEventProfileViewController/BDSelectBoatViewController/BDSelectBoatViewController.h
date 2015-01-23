//
//  BDSelectBoatViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 22/7/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^BoatSelectedBlock)(Boat *boat);

@interface BDSelectBoatViewController : BaseViewController

@property (nonatomic, copy) BoatSelectedBlock boatSelectedBlock;

@end
