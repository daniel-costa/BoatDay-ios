//
//  BDLeftMenuFactTableViewCell.m
//  BoatDay
//
//  Created by Mieraidihaimu Mieraisan on 24/01/15.
//  Copyright (c) 2015 Rocksauce Studios LLC. All rights reserved.
//

#import "BDLeftMenuFactTableViewCell.h"

@implementation BDLeftMenuFactTableViewCell
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
    
    [self setCellColor:[UIColor colorWithRed:3.0/255 green:144.0/255 blue:150.0/255 alpha:1.0]];
    
    self.factInfoLabel.textColor = [UIColor whiteColor];
    self.factInfoLabel.backgroundColor = [UIColor clearColor];
//    self.factInfoLabel.font = [UIFont abelFontWithSize:60.0];
    
    self.factDescriptionLabel.textColor = [UIColor whiteColor];
    self.factDescriptionLabel.backgroundColor = [UIColor clearColor];
//    self.factDescriptionLabel.font = [UIFont abelFontWithSize:16.0];
  
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
