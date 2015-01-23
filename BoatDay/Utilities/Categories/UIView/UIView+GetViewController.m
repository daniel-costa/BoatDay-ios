//
//  UIView+GetViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 29/05/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "UIView+GetViewController.h"

@implementation UIView (GetViewController)

- (UIViewController *)viewController {
    
    if ([self.nextResponder isKindOfClass:UIViewController.class])
        return (UIViewController *)self.nextResponder;
    else
        return nil;
    
}

@end
