//
//  BDHostRegistrationFirstRowCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDHostRegistrationFirstRowCell.h"

@implementation BDHostRegistrationFirstRowCell

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
    
    self.firstNameTextField.font = [UIFont abelFontWithSize:17.0];
    self.firstNameTextField.textColor = [UIColor greenBoatDay];
    
    self.lastNameLabel.font = [UIFont abelFontWithSize:12.0];
    self.lastNameLabel.textColor = [UIColor grayBoatDay];
    
    self.lastNameTextField.font = [UIFont abelFontWithSize:17.0];
    self.lastNameTextField.textColor = [UIColor greenBoatDay];
    
    self.birthdayLabel.font = [UIFont abelFontWithSize:12.0];
    self.birthdayLabel.textColor = [UIColor grayBoatDay];
    
    self.birthdayButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.birthdayButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.birthdayButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.firstAddressLineLabel.font = [UIFont abelFontWithSize:12.0];
    self.firstAddressLineLabel.textColor = [UIColor grayBoatDay];
    
    self.firstAddressLineTextField.font = [UIFont abelFontWithSize:17.0];
    self.firstAddressLineTextField.textColor = [UIColor greenBoatDay];
    
    self.cityLabel.font = [UIFont abelFontWithSize:12.0];
    self.cityLabel.textColor = [UIColor grayBoatDay];
    
    self.cityTextField.font = [UIFont abelFontWithSize:17.0];
    self.cityTextField.textColor = [UIColor greenBoatDay];
    
    self.stateLabel.font = [UIFont abelFontWithSize:12.0];
    self.stateLabel.textColor = [UIColor grayBoatDay];
    
    self.stateButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.stateButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.stateButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.zipCodeLabel.font = [UIFont abelFontWithSize:12.0];
    self.zipCodeLabel.textColor = [UIColor grayBoatDay];
    
    self.zipCodeTextField.font = [UIFont abelFontWithSize:17.0];
    self.zipCodeTextField.textColor = [UIColor greenBoatDay];
    
    self.emailLabel.font = [UIFont abelFontWithSize:12.0];
    self.emailLabel.textColor = [UIColor grayBoatDay];
    
    self.emailTextField.font = [UIFont abelFontWithSize:17.0];
    self.emailTextField.textColor = [UIColor greenBoatDay];
    
    self.phoneNumberLabel.font = [UIFont abelFontWithSize:12.0];
    self.phoneNumberLabel.textColor = [UIColor grayBoatDay];
    
    self.phoneNumberTextField.font = [UIFont abelFontWithSize:17.0];
    self.phoneNumberTextField.textColor = [UIColor greenBoatDay];
    
    [self.firstNameTextField setTintColor:[UIColor greenBoatDay]];
    [self.lastNameTextField setTintColor:[UIColor greenBoatDay]];
    [self.firstAddressLineTextField setTintColor:[UIColor greenBoatDay]];
    [self.cityTextField setTintColor:[UIColor greenBoatDay]];
    [self.zipCodeTextField setTintColor:[UIColor greenBoatDay]];
    [self.emailTextField setTintColor:[UIColor greenBoatDay]];
    [self.phoneNumberTextField setTintColor:[UIColor greenBoatDay]];
    
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
