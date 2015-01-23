//
//  UIView+DNAnimations.m
//  NReceitas
//
//  Created by Diogo Nunes on 31/10/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import "UIView+DNAnimations.h"

@implementation UIView (DNAnimations)

+ (void)showViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha duration:(CGFloat)duration andDelay:(CGFloat)delay andScale:(BOOL)scale {
   
    view.hidden = NO;

    if (withAlpha) {
        view.alpha = 0.0;
    }
    else
        view.alpha = 1.0;

    CGAffineTransform initialTransform = view.transform;
    
    if (scale) view.transform = CGAffineTransformConcat(initialTransform, CGAffineTransformMakeScale(1.04, 1.04));
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if (withAlpha) view.alpha = 1.0;
                         if (scale) view.transform = initialTransform;
                         
                     }
                     completion:nil
     ];
}

+ (void)showViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha andDuration:(CGFloat)duration {

    [self showViewAnimated:view withAlpha:withAlpha duration:duration andDelay:0.0 andScale:YES];
}

+ (void) hideViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha duration:(CGFloat)duration andScale:(BOOL)scale {
    
    [self removeViewAnimated:view withAlpha:withAlpha duration:duration delay:0.0 remove:NO scale:scale];
}

+ (void) hideViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha andDuration:(CGFloat)duration {
    
    [self removeViewAnimated:view withAlpha:withAlpha duration:duration delay:0.0 remove:NO scale:YES];
}

+ (void) hideViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha duration:(CGFloat)duration andDelay:(CGFloat)delay {
    
    [self removeViewAnimated:view withAlpha:withAlpha duration:duration delay:delay remove:NO scale:YES];
}

+ (void)removeViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha andDuration:(CGFloat)duration {
    
    [self removeViewAnimated:view withAlpha:withAlpha duration:duration delay:0.0 remove:YES scale:YES];
}

+ (void)removeViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha duration:(CGFloat)duration delay:(CGFloat)delay remove:(BOOL)remove scale:(BOOL)scale {
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         if (withAlpha) view.alpha = 0.0;
                         
                         if (scale) view.transform = CGAffineTransformMakeScale(1.04, 1.04);

                         
                     }
                     completion:^(BOOL finished) {
                         
                         view.hidden = YES;
                         view.transform = CGAffineTransformIdentity;
                         if (remove) [view removeFromSuperview];
                         
                     }
     ];
}

@end
