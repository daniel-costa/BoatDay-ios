//
//  BDEditBoatFirstRowCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEditBoatFirstRowCell.h"

@implementation BDEditBoatFirstRowCell

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
    
    self.indicateLabel.font = [UIFont abelFontWithSize:10.0];
    self.indicateLabel.textColor = [UIColor grayBoatDay];
    
    self.boatNameLabel.font = [UIFont abelFontWithSize:12.0];
    self.boatNameLabel.textColor = [UIColor grayBoatDay];
    
    self.boatNameTextField.font = [UIFont abelFontWithSize:17.0];
    self.boatNameTextField.textColor = [UIColor greenBoatDay];
    
    self.locationLabel.font = [UIFont abelFontWithSize:12.0];
    self.locationLabel.textColor = [UIColor grayBoatDay];
    
    self.locationButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.locationButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.locationButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    [self.locationButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateDisabled];

    self.typeLabel.font = [UIFont abelFontWithSize:12.0];
    self.typeLabel.textColor = [UIColor grayBoatDay];
    
    self.typeTextField.font = [UIFont abelFontWithSize:17.0];
    self.typeTextField.textColor = [UIColor greenBoatDay];
    
    self.lengthLabel.font = [UIFont abelFontWithSize:12.0];
    self.lengthLabel.textColor = [UIColor grayBoatDay];
    
    self.lengthTextField.font = [UIFont abelFontWithSize:17.0];
    self.lengthTextField.textColor = [UIColor greenBoatDay];
    
    self.capacityLabel.font = [UIFont abelFontWithSize:12.0];
    self.capacityLabel.textColor = [UIColor grayBoatDay];
    
    self.capacityTextField.font = [UIFont abelFontWithSize:17.0];
    self.capacityTextField.textColor = [UIColor greenBoatDay];
    
    self.buildYearNameLabel.font = [UIFont abelFontWithSize:12.0];
    self.buildYearNameLabel.textColor = [UIColor grayBoatDay];
    
    self.buildYearButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.buildYearButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.buildYearButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    [self.buildYearButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateDisabled];

    [self.boatNameTextField setTintColor:[UIColor greenBoatDay]];
    [self.typeTextField setTintColor:[UIColor greenBoatDay]];
    [self.lengthTextField setTintColor:[UIColor greenBoatDay]];
    [self.capacityTextField setTintColor:[UIColor greenBoatDay]];
    
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
