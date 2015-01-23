//
//  BDCertificationListCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDCertificationListCell.h"

@implementation BDCertificationListCell

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
    
    self.titleLabel.font = [UIFont abelFontWithSize:14.0];
    self.titleLabel.textColor = [UIColor grayBoatDay];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    self.contentView.backgroundColor = [UIColor lightGrayBoatDay];
    self.backgroundColor = [UIColor lightGrayBoatDay];
    
}

- (void)setStatus:(CertificationStatus)status {
    
    self.checkImageView.hidden = NO;
    
    switch (status) {
        case CertificationStatusApproved:
            [self.checkImageView setImage:[UIImage imageNamed:@"cert_approved"]];
            
            break;
        case CertificationStatusDenied:
            [self.checkImageView setImage:[UIImage imageNamed:@"cert_denied"]];
            
            break;
        case CertificationStatusPending:
            [self.checkImageView setImage:[UIImage imageNamed:@"cert_pending"]];
            break;
            
        case CertificationStatusInactive:
            [self.checkImageView setImage:[UIImage imageNamed:@"cert_inactive"]];
            break;
        default:
            self.checkImageView.hidden = YES;
            break;
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
@end
