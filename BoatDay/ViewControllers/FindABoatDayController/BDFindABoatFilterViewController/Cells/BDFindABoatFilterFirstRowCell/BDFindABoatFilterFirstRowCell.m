//
//  BDFindABoatFilterFirstRowCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindABoatFilterFirstRowCell.h"

extern const CGFloat kMaxDistanceLocation;
extern const CGFloat kMinDistanceLocation;

@implementation BDFindABoatFilterFirstRowCell

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
    
    self.locationTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.locationTitleLabel.textColor = [UIColor grayBoatDay];
    
    self.timeframeTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.timeframeTitleLabel.textColor = [UIColor grayBoatDay];
    
    self.availableSeatsTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.availableSeatsTitleLabel.textColor = [UIColor grayBoatDay];
    
    self.distanceTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.distanceTitleLabel.textColor = [UIColor grayBoatDay];
    
    self.distanceLabel.font = [UIFont abelFontWithSize:12.0];
    self.distanceLabel.textColor = [UIColor grayBoatDay];
    
    [self.distanceSlider addTarget:self action:@selector(updateDistanceLabel) forControlEvents:UIControlEventValueChanged];
    [self.distanceSlider setMinimumTrackTintColor:[UIColor darkGreenBoatDay]];
    [self.distanceSlider setMaximumTrackTintColor:[UIColor greenBoatDay]];

    self.suggestedPriceTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.suggestedPriceTitleLabel.textColor = [UIColor grayBoatDay];
    
    self.keywordsTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.keywordsTitleLabel.textColor = [UIColor grayBoatDay];
    
    self.locationButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.locationButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.locationButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.timeframeButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.timeframeButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.timeframeButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.availableSeatsButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.availableSeatsButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.availableSeatsButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.suggestedPriceButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.suggestedPriceButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.suggestedPriceButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
    self.keywordsTextField.font = [UIFont abelFontWithSize:14.0];
    self.keywordsTextField.textColor = [UIColor greenBoatDay];
    [self.keywordsTextField setTintColor:[UIColor greenBoatDay]];

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

#pragma mark - Slide Methods

- (void) setSliderToMiles:(CGFloat) miles {

    CGFloat percent = [self convertDistanceToPercent:miles];
    
    self.distanceSlider.value = percent;
    
    [self updateDistanceLabel];
    
}

- (void) updateDistanceLabel {

    CGFloat percent = self.distanceSlider.value;
    
    CGFloat distance = [self convertPercentToDistance:percent];
    
    NSNumberFormatter *formatterValues = [NSNumberFormatter valuesNumberFormatter];
    
    NSString *distanceString = nil;
    
    if (distance == 100) {
        distanceString = @"100+";
    }  else {
        distanceString = [formatterValues stringFromNumber:@(distance)];
    }
    
    self.distanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"findABoat.distanceValue.stringFormat", nil), distanceString];
    
    if (self.distanceChangeBlock) {
        self.distanceChangeBlock(distance);
    }
    
}

- (CGFloat) convertPercentToDistance:(CGFloat)value {

    CGFloat originalStart = 0, originalEnd = 1; // original range (0 - 1)
    
    CGFloat newStart = kMinDistanceLocation, newEnd = kMaxDistanceLocation; // new range (0.5 - 100)

    CGFloat scale = (CGFloat)(newEnd - newStart) / (originalEnd - originalStart);

    CGFloat result = (CGFloat)(newStart + ((value - originalStart) * scale));

    return result;

}

- (CGFloat) convertDistanceToPercent:(CGFloat)value  {
    
    CGFloat originalStart = kMinDistanceLocation, originalEnd = kMaxDistanceLocation; // original range (0.5 - 100)
    
    CGFloat newStart = 0, newEnd = 1; // new range (0 - 1)
    
    CGFloat scale = (CGFloat)(newEnd - newStart) / (originalEnd - originalStart);
    
    CGFloat result = (CGFloat)(newStart + ((value - originalStart) * scale));
    
    return result;
    
}


@end
