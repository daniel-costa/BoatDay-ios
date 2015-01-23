//
//  BDTextFieldCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEditProfileFirstRowCell.h"

@implementation BDEditProfileFirstRowCell

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
    
    self.firstNameLabel.font = [UIFont abelFontWithSize:12.0];
    self.firstNameLabel.textColor = [UIColor grayBoatDay];
    
    self.lastNameLabel.font = [UIFont abelFontWithSize:12.0];
    self.lastNameLabel.textColor = [UIColor grayBoatDay];
    
    self.locationNameLabel.font = [UIFont abelFontWithSize:12.0];
    self.locationNameLabel.textColor = [UIColor grayBoatDay];
    
    self.birthdayNameLabel.font = [UIFont abelFontWithSize:12.0];
    self.birthdayNameLabel.textColor = [UIColor grayBoatDay];
    
    self.firstNameTextField.font = [UIFont quattroCentoRegularFontWithSize:17.0];
    self.firstNameTextField.textColor = [UIColor greenBoatDay];
    
    self.lastNameTextField.font = [UIFont abelFontWithSize:17.0];
    self.lastNameTextField.textColor = [UIColor greenBoatDay];
    
    self.locationButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.locationButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.locationButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    self.locationButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.locationButton.titleLabel.minimumScaleFactor = 0.7;
    
    self.birthdayButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.birthdayButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.birthdayButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    [self.firstNameTextField setTintColor:[UIColor greenBoatDay]];
    [self.lastNameTextField setTintColor:[UIColor greenBoatDay]];
    
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
