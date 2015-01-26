//
//  BDLeftMenuNotificationTableViewCell.m
//  BoatDay
//
//  Created by Mieraidihaimu Mieraisan on 24/01/15.
//  Copyright (c) 2015 Rocksauce Studios LLC. All rights reserved.
//

#import "BDLeftMenuNotificationTableViewCell.h"

@implementation BDLeftMenuNotificationTableViewCell
+ (NSString *)reuseIdentifier {
    
    return NSStringFromClass([self class]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
       
        [self awakeFromNib];
    }
    
    return self;
    
}


- (void)awakeFromNib {
    // Initialization code
    for (UIView *currentView in self.subviews)
    {
        if([currentView isKindOfClass:[UIScrollView class]])
        {
            ((UIScrollView *)currentView).delaysContentTouches = NO;
            break;
        }
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self setCellColor:[UIColor colorWithRed:228.0/255 green:113.0/255 blue:130.0/255 alpha:1.0]];
    
    self.notificationDescriptionLabel.textColor = [UIColor whiteColor];
    self.notificationDescriptionLabel.backgroundColor = [UIColor clearColor];
    self.notificationDescriptionLabel.font = [UIFont quattroCentoBoldFontWithSize:15.0];
    [self.notificationDescriptionLabel setText:@"notification center"];
    
    [_notificationImageVIew setContentMode:UIViewContentModeScaleAspectFill];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCellColor:(UIColor *)color{
    self.contentView.backgroundColor = color;
    self.backgroundColor = color;
}
@end
