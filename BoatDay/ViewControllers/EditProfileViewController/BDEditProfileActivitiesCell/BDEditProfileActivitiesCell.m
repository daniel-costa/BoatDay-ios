//
//  BDEditProfileActivitiesCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEditProfileActivitiesCell.h"
#import "UIImage+Resize.h"

@implementation BDEditProfileActivitiesCell

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
    self.titleLabel.textColor = [UIColor whiteColor];
    
}

- (void)updateCellWithActivities:(NSArray*)activities {
    
    [self setupActivitiesScrollViewWithActivities:activities];
    
}

- (void) setupActivitiesScrollViewWithActivities:(NSArray*)activities {
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat spaceBetween = 10.0;
    CGFloat xPosition = 0.0;
    CGFloat yPosition = 0.0;
    CGFloat buttonWidth = 45.0;
    self.emptyStateActivityLabel.hidden = YES;
    if (activities.count < 1) {
        self.emptyStateActivityLabel.hidden = NO;
        _emptyStateActivityLabel.text = NSLocalizedString(@"editProfile.myActivityEmptyState", nil);
        _emptyStateActivityLabel.textColor = [UIColor whiteColor];
        _emptyStateActivityLabel.font = [UIFont quattroCentoRegularFontWithSize:12.0];
        _emptyStateActivityLabel.textAlignment = NSTextAlignmentCenter;
    }
    for (int i = 0; i < activities.count; i++) {
        
        Activity *activity = activities[i];
        
        UIButton *userButton = [[UIButton alloc] init];
        userButton.frame = CGRectMake(xPosition, yPosition, buttonWidth, buttonWidth);
        
        PFFile *theImage = activity.picture;
        
        // Get image from cache or from server if isnt available (background task)
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            [userButton setImage:image forState:UIControlStateNormal];
            userButton.userInteractionEnabled = NO;
            
        }];
        
        [self.scrollView addSubview:userButton];
        
        xPosition += (buttonWidth + spaceBetween);
        
    }
    
    CGFloat scrollContentWidth = xPosition;
    
    [self.scrollView setContentSize:CGSizeMake(scrollContentWidth, CGRectGetHeight(self.scrollView.frame))];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
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
