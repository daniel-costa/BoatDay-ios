//
//  BDEventActivitiesCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEventActivitiesCell.h"

@implementation BDEventActivitiesCell

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
    
    self.activityTitleLabel.font = [UIFont abelFontWithSize:14.0];
    self.activityTitleLabel.backgroundColor = [UIColor clearColor];
    
    self.activityDescriptionLabel.font = [UIFont abelFontWithSize:14.0];
    self.activityDescriptionLabel.backgroundColor = [UIColor clearColor];
    
}

- (void)updateCellWithActivity:(Activity *)activity {
    
    [self setCellColor:[UIColor lightGrayBoatDay]];
    
    self.activityTitleLabel.textColor = [UIColor grayBoatDay];
    
    self.activityDescriptionLabel.textColor = [UIColor grayBoatDay];
    
    setFrameHeight(self.activityDescriptionLabel, 300.0);
    
    self.activityTitleLabel.text = activity.name;
    
    self.activityDescriptionLabel.text = activity.text;
    
    [self.activityDescriptionLabel sizeToFit];
    
    PFFile *theImage = activity.pictureGreen;
    
    self.activityImageView.alpha = 0.0;
    
    // Get image from cache or from server if isnt available (background task)
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        UIImage *image = [UIImage imageWithData:data];
        
        self.activityImageView.image = image;
        
        setFrameHeight(self.activityImageView, image.size.height / 2.0);
        setFrameWidth(self.activityImageView, image.size.width / 2.0);
        
        CGFloat totalTextHeight = CGRectGetMaxY(self.activityDescriptionLabel.frame) - CGRectGetMinY(self.activityTitleLabel.frame);
        
        self.activityImageView.center = CGPointMake(27.5, 0.0);
        
        setFrameY(self.activityImageView, CGRectGetMinY(self.activityTitleLabel.frame) + (totalTextHeight - CGRectGetHeight(self.activityImageView.frame)) / 2.0);
        
        [UIView showViewAnimated:self.activityImageView withAlpha:YES andDuration:0.2];
        
    }];
    
}

- (void)updateCellWithTitle:(NSString *)title descriptionTitle:(NSString*)description image:(UIImage*)image hasPermission:(BOOL)hasPermission {
    
    if (hasPermission) {
        [self setCellColor:[UIColor eventsGreenBoatDay]];
        
    } else {
        [self setCellColor:RGB(203, 21, 50)];
    }
    
    self.activityTitleLabel.textColor = [UIColor whiteColor];
    
    self.activityDescriptionLabel.textColor = [UIColor whiteColor];
    
    setFrameHeight(self.activityDescriptionLabel, 300.0);
    
    self.activityTitleLabel.text = title;
    
    self.activityDescriptionLabel.text = description;
    
    [self.activityDescriptionLabel sizeToFit];
    
    // Image Stuff
    self.activityImageView.alpha = 0.0;
    self.activityImageView.image = image;
    
    setFrameHeight(self.activityImageView, image.size.height);
    setFrameWidth(self.activityImageView, image.size.width);
    
    CGFloat totalTextHeight = CGRectGetMaxY(self.activityDescriptionLabel.frame) - CGRectGetMinY(self.activityTitleLabel.frame);
    
    self.activityImageView.center = CGPointMake(27.5, 0.0);
    
    setFrameY(self.activityImageView, CGRectGetMinY(self.activityTitleLabel.frame) + (totalTextHeight - CGRectGetHeight(self.activityImageView.frame)) / 2.0);
    
    [UIView showViewAnimated:self.activityImageView withAlpha:YES andDuration:0.2];
    
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
