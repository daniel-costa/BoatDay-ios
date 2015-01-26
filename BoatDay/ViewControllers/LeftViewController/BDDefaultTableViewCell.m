//
//  BDDefaultTableViewCell.m
//  BoatDay
//
//  Created by Mieraidihaimu Mieraisan on 25/01/15.
//  Copyright (c) 2015 Rocksauce Studios LLC. All rights reserved.
//

#import "BDDefaultTableViewCell.h"

@implementation BDDefaultTableViewCell

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
    
    [self setCellColor:[UIColor greenBoatDay]];
    
    self.cellNames.textColor = [UIColor whiteColor];
    self.cellNames.backgroundColor = [UIColor clearColor];
    self.cellNames.font = [UIFont quattroCentoBoldFontWithSize:16.0];
    
    [_cellImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_cellImageView setImage:[UIImage imageNamed:@"profile_photo_none"]];
    [_lineBreakers setBackgroundColor:[UIColor colorWithRed:3.0/255 green:144.0/255 blue:150.0/255 alpha:1.0]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (NSString *)reuseIdentifier {
    
    return NSStringFromClass([self class]);
}
- (void)setCellColor:(UIColor *)color{
    self.contentView.backgroundColor = color;
    self.backgroundColor = color;
}
- (void) updateCellWith:(NSString *)name imageName:(NSString *)imageName{
    [self.cellImageView setImage:[UIImage imageNamed:imageName]];
    [self.cellNames setText:name];

}
@end
