//
//  UIImage+ImageEffects.h
//  Inkling
//
//  Created by Aaron Pang on 3/26/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageEffects)

@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *applySubtleEffect;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *applyLightEffect;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *applyExtraLightEffect;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
