//
//  BDFindABoatFilterFamilyContentViewCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindABoatFilterFamilyContentViewCell.h"

@implementation BDFindABoatFilterFamilyContentViewCell

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
    
    // Set the OFF border color
    [self.MBSwitch setTintColor:[UIColor mediumGrayBoatDay]];
    
    // Set the ON tint color
    [self.MBSwitch setOnTintColor:[UIColor mediumGreenBoatDay]];
    
    // Set the OFF fill color
    [self.MBSwitch setOffTintColor:[UIColor mediumGrayBoatDay]];
    
    // Set the thumb tint color
    [self.MBSwitch setThumbTintColor:[UIColor whiteColor]];
    
    self.titleLabel.font = [UIFont abelFontWithSize:14.0];
    self.titleLabel.textColor = [UIColor grayBoatDay];
    
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

#pragma mark - MBSwitch Changed

- (IBAction) mbSwitchValueChanged {
    
    if (self.mbSwitchChangeBlock) {
        self.mbSwitchChangeBlock(self.MBSwitch.on);
    }
    
}

@end
