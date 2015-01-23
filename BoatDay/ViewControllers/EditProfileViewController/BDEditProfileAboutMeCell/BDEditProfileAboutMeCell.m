//
//  BDTextViewCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEditProfileAboutMeCell.h"

static NSInteger const kAboutMeMaximumCharacters = 500;

@implementation BDEditProfileAboutMeCell

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
    
    self.titleLabel.font = [UIFont abelFontWithSize:12.0];
    self.titleLabel.textColor = [UIColor grayBoatDay];
    
    self.textView.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.textView.textColor = [UIColor greenBoatDay];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.contentInset = UIEdgeInsetsMake(-8.0, -5.0, 0.0, 0.0);
    
    [self.textView setTintColor:[UIColor greenBoatDay]];
    
    self.charRemainingLabel.font = [UIFont abelFontWithSize:12.0];
    self.charRemainingLabel.textColor = [UIColor grayBoatDay];
    
}

- (void)updateCell {
    
    [self.textView sizeToFit];
    
    setFrameWidth(self.textView, 280.0);
    setFrameY(self.bottomLine, CGRectGetMaxY(self.textView.frame) - 5.0);
    setFrameY(self.charRemainingLabel, CGRectGetMaxY(self.bottomLine.frame) + 2.0);
    
    [self charRemainingUpdate];
    
}

- (void)charRemainingUpdate {
    
    self.charRemainingLabel.text = [NSString stringWithFormat:@"%d %@",
                                    (int)(kAboutMeMaximumCharacters - self.textView.text.length),
                                    NSLocalizedString(@"editProfile.aboutMe.charsRemaining", nil)];
    
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
