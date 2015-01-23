//
//  BDCertificationListCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDCertificationListCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (nonatomic) CertificationStatus status;
@property (weak, nonatomic) IBOutlet UILabel *deepDescription;

- (void)setStatus:(CertificationStatus)status;

- (void)changeCellStateSelected:(BOOL)selected;


@end
