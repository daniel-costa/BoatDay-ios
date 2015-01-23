//
//  BDEventActivitiesCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDEventActivitiesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *activityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityDescriptionLabel;

+ (NSString *)reuseIdentifier;

- (void)changeCellStateSelected:(BOOL)selected;

- (void)updateCellWithActivity:(Activity *)activity;

- (void)updateCellWithTitle:(NSString *)title descriptionTitle:(NSString*)description image:(UIImage*)image hasPermission:(BOOL)hasPermission;

@end
