//
//  BBDFindABoatFilterDefaultCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindABoatFilterDefaultCell.h"

@implementation BDFindABoatFilterDefaultCell

+ (NSString *)reuseIdentifier {
    
    return NSStringFromClass([self class]);
}

#pragma mark - Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        for (UIView *currentView in self.subviews)
        {
            if([currentView isKindOfClass:[UIScrollView class]])
            {
                ((UIScrollView *)currentView).delaysContentTouches = NO;
                break;
            }
        }
        
    }
    
    return self;
    
}

#pragma mark - Private

- (void)changeCellStateHighlighted:(BOOL)highlighted {
    
    if (highlighted) {
        
        [self setCellColor:[UIColor grayBoatDay]];
        self.textLabel.textColor = [UIColor lightGrayBoatDay];
        
    }
    else {
        
        [self setCellColor:[UIColor lightGrayBoatDay]];
        self.textLabel.textColor = [UIColor grayBoatDay];
        
    }
    
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
