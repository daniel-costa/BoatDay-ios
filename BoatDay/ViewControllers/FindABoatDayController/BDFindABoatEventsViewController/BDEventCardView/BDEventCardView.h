//
//  BDEventCardView.h
//  BoatDay
//
//  Created by Diogo Nunes on 30/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface BDEventCardView : UIView

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

// Boat Picture View
@property (weak, nonatomic) IBOutlet UIImageView *boatImageView;
@property (weak, nonatomic) IBOutlet UIImageView *boatPlaceholderImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSeatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UILabel *open2Label;

// First Row View
@property (weak, nonatomic) IBOutlet UIImageView *userPictureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userPicturePlaceholderImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;

// Second Row View
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *suggestedLabel;

// Methods
- (void) updateCardWithEvent:(Event *)event;

@end
