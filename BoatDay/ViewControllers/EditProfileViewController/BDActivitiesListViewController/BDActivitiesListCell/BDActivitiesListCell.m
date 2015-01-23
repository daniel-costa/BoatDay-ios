//
//  BDActivitiesListCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDActivitiesListCell.h"

@implementation BDActivitiesListCell

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
    
    self.selectedArray = [NSMutableArray arrayWithArray: @[@(NO),@(NO),@(NO),@(NO)]];
    self.firstLabel.font = [UIFont abelFontWithSize:11.0];
    self.firstLabel.textColor = [UIColor whiteColor];
    self.firstLabel.tag = LABEL_TAG;
    self.firstImageView.tag = IMAGE_TAG;
    
    self.secondLabel.font = [UIFont abelFontWithSize:11.0];
    self.secondLabel.textColor = [UIColor whiteColor];
    self.secondLabel.tag = LABEL_TAG;
    self.secondImageView.tag = IMAGE_TAG;
    
    self.thirdLabel.font = [UIFont abelFontWithSize:11.0];
    self.thirdLabel.textColor = [UIColor whiteColor];
    self.thirdLabel.tag = LABEL_TAG;
    self.thirdImageView.tag = IMAGE_TAG;
    
    self.fourthLabel.font = [UIFont abelFontWithSize:11.0];
    self.fourthLabel.textColor = [UIColor whiteColor];
    self.fourthLabel.tag = LABEL_TAG;
    self.fourthImageView.tag = IMAGE_TAG;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.firstView addGestureRecognizer:singleTap];
    [self.firstView setUserInteractionEnabled:YES];
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.secondView addGestureRecognizer:singleTap];
    [self.secondView setUserInteractionEnabled:YES];
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.thirdView addGestureRecognizer:singleTap];
    [self.thirdView setUserInteractionEnabled:YES];
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.fourthView addGestureRecognizer:singleTap];
    [self.fourthView setUserInteractionEnabled:YES];
    
    self.firstView.tag = VIEWS_PREFIX;
    self.secondView.tag = VIEWS_PREFIX+1;
    self.thirdView.tag = VIEWS_PREFIX+2;
    self.fourthView.tag = VIEWS_PREFIX+3;
    
}

- (void) updateCell {
    
    for (int i = 0; i<4; i++) {
        
        UIView *view = [self viewWithTag:VIEWS_PREFIX+i];
        
        if ([self.selectedArray[i] boolValue]) {
            view.backgroundColor = [UIColor darkGreenBoatDay];
        }
        else {
            view.backgroundColor = [UIColor clearColor];
        }
        
    }
    
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

#pragma mark - Tap Gesture Methods

- (void)viewTapped:(UIGestureRecognizer *)gestureRecognizer {
    
    UIView *view = [gestureRecognizer view];
    NSInteger index = view.tag - VIEWS_PREFIX;
    
    self.selectedArray[index] = @(![self.selectedArray[index] boolValue]);
    
    [self updateCell];
    
    if ([self.delegate respondsToSelector:@selector(viewTappedAtSection:andRow:isSelected:)]) {
        [self.delegate viewTappedAtSection:self.section andRow:index isSelected:[self.selectedArray[index] boolValue]];
    }
    
}

@end
