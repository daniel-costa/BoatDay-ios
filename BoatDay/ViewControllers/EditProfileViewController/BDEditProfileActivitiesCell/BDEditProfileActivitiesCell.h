//
//  BDEditProfileActivitiesCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDActivitiesScrollView.h"

@interface BDEditProfileActivitiesCell : UITableViewCell

+ (NSString *)reuseIdentifier;
@property (weak, nonatomic) IBOutlet UILabel *emptyStateActivityLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet BDActivitiesScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

- (void)changeCellStateSelected:(BOOL)selected;
- (void)updateCellWithActivities:(NSArray*)activities;

@end
