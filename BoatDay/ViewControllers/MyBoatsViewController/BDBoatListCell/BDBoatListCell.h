//
//  BDBoatListCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDBoatListCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UIImageView *boatImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *boatType;
@property (weak, nonatomic) IBOutlet UILabel *addedDate;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSeats;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) Boat *boat;

- (void)updateLayoutWithBoat:(Boat*)boat;

- (void)changeCellStateSelected:(BOOL)selected;

@end
