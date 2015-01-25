//
//  BDEditBoatFirstRowCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEditEventLastRowCell.h"

@implementation BDEditEventLastRowCell

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
    
    self.eventNameLabel.font = [UIFont abelFontWithSize:12.0];
    self.eventNameLabel.textColor = [UIColor grayBoatDay];
    
    self.eventNameTextField.font = [UIFont abelFontWithSize:17.0];
    self.eventNameTextField.textColor = [UIColor greenBoatDay];
    
    self.locationLabel.font = [UIFont abelFontWithSize:12.0];
    self.locationLabel.textColor = [UIColor grayBoatDay];
    
    self.locationButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.locationButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.locationButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.availableSeatsLabel.font = [UIFont abelFontWithSize:12.0];
    self.availableSeatsLabel.textColor = [UIColor grayBoatDay];
    
    self.availableSeatsButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.availableSeatsButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.availableSeatsButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.pricePerSeatLabel.font = [UIFont abelFontWithSize:12.0];
    self.pricePerSeatLabel.textColor = [UIColor grayBoatDay];
    
    self.pricePerSeatTextField.font = [UIFont abelFontWithSize:17.0];
    self.pricePerSeatTextField.textColor = [UIColor greenBoatDay];
    
    self.estimatedIncomeLabel.font = [UIFont abelFontWithSize:12.0];
    self.estimatedIncomeLabel.textColor = [UIColor grayBoatDay];
    
    self.estimatedIncomeButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.estimatedIncomeButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.estimatedIncomeButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.pickUpTimeLabel.font = [UIFont abelFontWithSize:12.0];
    self.pickUpTimeLabel.textColor = [UIColor grayBoatDay];
    
    self.pickUpTimeButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.pickUpTimeButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.pickUpTimeButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.endTimeLabel.font = [UIFont abelFontWithSize:12.0];
    self.endTimeLabel.textColor = [UIColor grayBoatDay];
    
    self.endTimeButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.endTimeButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.endTimeButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    [self.eventNameTextField setTintColor:[UIColor greenBoatDay]];
    [self.pricePerSeatTextField setTintColor:[UIColor greenBoatDay]];
    
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
