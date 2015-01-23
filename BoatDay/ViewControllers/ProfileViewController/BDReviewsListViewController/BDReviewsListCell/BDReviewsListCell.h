//
//  BDReviewsListCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface BDReviewsListCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;

- (void)changeCellStateSelected:(BOOL)selected;

- (void)updateLayoutWithReview:(Review*)review;

@end
