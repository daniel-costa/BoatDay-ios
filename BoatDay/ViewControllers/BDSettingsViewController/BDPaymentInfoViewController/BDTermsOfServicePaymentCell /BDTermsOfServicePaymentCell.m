//
//  BDTermsOfServicePaymentCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDTermsOfServicePaymentCell.h"

@implementation BDTermsOfServicePaymentCell

+ (NSString *)reuseIdentifier {
    
    return NSStringFromClass([self class]);
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    
    for (UIView *currentView in self.subviews)
    {
        if([currentView isKindOfClass:[UIScrollView class]])
        {
            ((UIScrollView *)currentView).delaysContentTouches = NO;
            break;
        }
    }

    self.confirmLabel.font = [UIFont abelFontWithSize:14.0];
    self.confirmLabel.textColor = [UIColor grayBoatDay];
    
    [self.termsOfService setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.termsOfService setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    self.termsOfService.titleLabel.font = [UIFont abelFontWithSize:14.0];
    
}

#pragma mark - Private

- (void)changeCellStateHighlighted:(BOOL)highlighted {
    
}

- (void)changeCellStateSelected:(BOOL)selected {
    
}

#pragma mark - Overriden Methods

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    [self changeCellStateHighlighted:highlighted];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    [self changeCellStateHighlighted:selected];
    
}

@end
