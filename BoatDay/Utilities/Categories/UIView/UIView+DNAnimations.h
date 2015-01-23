//
//  UIView+DNAnimations.h
//  NReceitas
//
//  Created by Diogo Nunes on 31/10/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DNAnimations)

+ (void) removeViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha duration:(CGFloat)duration delay:(CGFloat)delay remove:(BOOL)remove scale:(BOOL)scale;

+ (void) hideViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha duration:(CGFloat)duration andScale:(BOOL)scale;

+ (void) removeViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha andDuration:(CGFloat)duration;

+ (void) hideViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha duration:(CGFloat)duration andDelay:(CGFloat)delay;

+ (void) hideViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha andDuration:(CGFloat)duration;

+ (void) showViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha andDuration:(CGFloat)duration;

+ (void) showViewAnimated:(UIView *)view withAlpha:(BOOL)withAlpha duration:(CGFloat)duration andDelay:(CGFloat)delay andScale:(BOOL)scale;

@end
