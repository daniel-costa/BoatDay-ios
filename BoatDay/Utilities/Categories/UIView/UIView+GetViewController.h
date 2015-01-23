//
//  UIView+GetViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 29/05/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GetViewController)

@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIViewController *viewController;

@end
