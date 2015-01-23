//
//  UIImageView+RoundedView.m
//
//  Created by Diogo Nunes on 18/09/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import "UIView+RoundedView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (RoundedView)

+(void)setRoundedView:(UIView *)roundedView toDiameter:(CGFloat)newSize
{
   
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
    roundedView.clipsToBounds = YES;
}

@end
