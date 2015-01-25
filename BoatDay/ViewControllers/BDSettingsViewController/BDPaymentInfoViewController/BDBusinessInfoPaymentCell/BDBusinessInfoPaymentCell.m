//
//  BDBusinessInfoPaymentCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDBusinessInfoPaymentCell.h"

@implementation BDBusinessInfoPaymentCell

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

    self.businessNameLabel.font = [UIFont abelFontWithSize:12.0];
    self.businessNameLabel.textColor = [UIColor grayBoatDay];
    
    self.taxIdLabel.font = [UIFont abelFontWithSize:12.0];
    self.taxIdLabel.textColor = [UIColor grayBoatDay];
    
    self.businessNameTextField.font = [UIFont abelFontWithSize:17.0];
    self.businessNameTextField.textColor = [UIColor greenBoatDay];
    
    self.taxIdTextField.font = [UIFont abelFontWithSize:17.0];
    self.taxIdTextField.textColor = [UIColor greenBoatDay];
    
    [self.businessNameTextField setTintColor:[UIColor greenBoatDay]];
    [self.taxIdTextField setTintColor:[UIColor greenBoatDay]];
    
    self.confirmLabel.font = [UIFont abelFontWithSize:14.0];
    self.confirmLabel.textColor = [UIColor grayBoatDay];
    
}

#pragma mark - Private

- (void)setEnabled:(BOOL)enabled {
    
    if (enabled) {
        
        self.businessNameLabel.alpha = 1.0;
        self.taxIdLabel.alpha = 1.0;

        [self.confirmButton setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
        [self.confirmButton setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateHighlighted];
        self.businessNameTextField.enabled = YES;
        self.taxIdTextField.enabled = YES;
        
        self.businessNameTextField.textColor = [UIColor greenBoatDay];
        self.taxIdTextField.textColor = [UIColor greenBoatDay];
        
    }
    else {
        
        self.businessNameLabel.alpha = 0.5;
        self.taxIdLabel.alpha = 0.5;
        
        [self.confirmButton setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        [self.confirmButton setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateHighlighted];
        self.businessNameTextField.enabled = NO;
        self.taxIdTextField.enabled = NO;
        
        self.businessNameTextField.textColor = [UIColor grayBoatDay];
        self.taxIdTextField.textColor = [UIColor grayBoatDay];
        
    }
    
}

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
