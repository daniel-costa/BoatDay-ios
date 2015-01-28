//
//  BDAddEditEventProfileViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 24/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

typedef void (^EventDeletedBlock)();

@interface BDAddEditEventProfileViewController : BaseViewController

@property (copy, nonatomic) NSString *locationString;
@property (nonatomic) BOOL readOnly;

@property (nonatomic, copy) EventDeletedBlock eventDeletedBlock;

- (instancetype)initWithEvent:(Event *)event NS_DESIGNATED_INITIALIZER;

@end
