//
//  BDLeftMenuProfileTableViewCell.m
//  BoatDay
//
//  Created by Mieraidihaimu Mieraisan on 24/01/15.
//  Copyright (c) 2015 Rocksauce Studios LLC. All rights reserved.
//

#import "BDLeftMenuProfileTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
@implementation BDLeftMenuProfileTableViewCell
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
    
//    [self setCellColor:[UIColor colorWithRed:4.0/255 green:165.0/255 blue:172.0/255 alpha:1.0]];
    [self setCellColor:[UIColor greenBoatDay]];
    
    self.profileNameLabel.textColor = [UIColor whiteColor];
    self.profileNameLabel.backgroundColor = [UIColor clearColor];
    self.profileNameLabel.font = [UIFont quattroCentoBoldFontWithSize:16.0];

    [_profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_profileImageView setImage:[UIImage imageNamed:@"user_av_blank"]];
    _profileImageView.layer.cornerRadius = CGRectGetHeight(_profileImageView.frame)/2;
    _profileImageView.layer.masksToBounds = YES;


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCellColor:(UIColor *)color{
    self.contentView.backgroundColor = color;
    self.backgroundColor = color;
}

- (void)updateProfileCellWith:(UIImage *)profileImage profileName:(NSString *)profileName{
    [_profileNameLabel setText:profileName];
    if(profileImage != nil) {
        [_profileImageView setImage:profileImage];
    }
}

@end
