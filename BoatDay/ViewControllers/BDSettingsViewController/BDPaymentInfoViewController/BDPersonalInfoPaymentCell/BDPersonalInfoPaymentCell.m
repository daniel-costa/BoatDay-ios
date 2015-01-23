//
//  BDPersonalInfoPaymentCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDPersonalInfoPaymentCell.h"

@implementation BDPersonalInfoPaymentCell

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

    self.ssnLabel.font = [UIFont abelFontWithSize:12.0];
    self.ssnLabel.textColor = [UIColor grayBoatDay];
    
    self.ssnTextField.font = [UIFont abelFontWithSize:17.0];
    self.ssnTextField.textColor = [UIColor greenBoatDay];
    
    [self.ssnTextField setTintColor:[UIColor greenBoatDay]];
    
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
