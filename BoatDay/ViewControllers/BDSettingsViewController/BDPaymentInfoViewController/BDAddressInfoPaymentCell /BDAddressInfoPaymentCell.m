//
//  BDAddressInfoPaymentCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDAddressInfoPaymentCell.h"

@implementation BDAddressInfoPaymentCell

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
    
    self.addressLabel.font = [UIFont abelFontWithSize:12.0];
    self.addressLabel.textColor = [UIColor grayBoatDay];
    
    self.stateLabel.font = [UIFont abelFontWithSize:12.0];
    self.stateLabel.textColor = [UIColor grayBoatDay];
    
    self.zipCodeLabel.font = [UIFont abelFontWithSize:12.0];
    self.zipCodeLabel.textColor = [UIColor grayBoatDay];
    
    self.addressTextField.font = [UIFont abelFontWithSize:17.0];
    self.addressTextField.textColor = [UIColor greenBoatDay];

    self.stateButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.stateButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.stateButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.zipCodeTextField.font = [UIFont abelFontWithSize:17.0];
    self.zipCodeTextField.textColor = [UIColor greenBoatDay];
    
    [self.addressTextField setTintColor:[UIColor greenBoatDay]];
    [self.zipCodeTextField setTintColor:[UIColor greenBoatDay]];

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
