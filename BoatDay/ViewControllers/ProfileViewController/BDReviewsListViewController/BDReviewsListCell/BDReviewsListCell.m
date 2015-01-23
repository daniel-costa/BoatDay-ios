//
//  BDReviewsListCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDReviewsListCell.h"

@implementation BDReviewsListCell

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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self setCellColor:[UIColor greenBoatDay]];
    
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.textColor = [UIColor whiteColor];
    self.messageLabel.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.messageLabel.textAlignment = NSTextAlignmentJustified;
    
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = [UIColor whiteColor];
    self.dateLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = [UIColor yellowBoatDay];
    self.nameLabel.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    
    self.starRating.backgroundColor = [UIColor clearColor];
    self.starRating.starHighlightedImage = [UIImage imageNamed:@"starProfile_lightYellow"];
    self.starRating.starImage = [UIImage imageNamed:@"starProfile_green"];
    self.starRating.maxRating = 5.0;
    self.starRating.horizontalMargin = 2;
    self.starRating.editable = NO;
    self.starRating.displayMode = EDStarRatingDisplayFull;
    self.starRating.userInteractionEnabled = NO;
    self.starRating.rating = 0;
    
}

#pragma mark - Layout

- (void)updateLayoutWithReview:(Review*)review {
    
    self.starRating.rating = review.stars.integerValue;
    
    self.nameLabel.text = review.from.shortName;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter reviewsDateFormatter];
    NSString *createDate = [dateFormatter stringFromDate:review.createdAt];
    self.dateLabel.text = createDate;
    
    self.messageLabel.text = review.text;
    [self.messageLabel sizeToFit];
    
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

- (void)setCellColor:(UIColor *)color{
    self.contentView.backgroundColor = color;
    self.backgroundColor = color;
}

@end
