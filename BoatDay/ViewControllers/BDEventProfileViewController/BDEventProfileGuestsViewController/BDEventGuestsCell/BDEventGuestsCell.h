//
//  BDEventGuestsCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DevProfile.h"

typedef void (^UserTappedBlock)(User *user);

@interface BDEventGuestsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *firstOriginImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondOriginImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdOriginImageView;

@property (strong, nonatomic) User *firstUser;
@property (strong, nonatomic) User *secondUser;
@property (strong, nonatomic) User *thirdUser;

@property (weak, nonatomic) IBOutlet UIImageView *firstPlaceholderImageView;
@property (weak, nonatomic) IBOutlet UIButton *firstImageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstCheckImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstLocationLabel;

@property (weak, nonatomic) IBOutlet UIImageView *secondPlaceholderImageView;
@property (weak, nonatomic) IBOutlet UIButton *secondImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondCheckImageView;
@property (weak, nonatomic) IBOutlet UILabel *secondNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLocationLabel;

@property (weak, nonatomic) IBOutlet UIImageView *thirdPlaceholderImageView;
@property (weak, nonatomic) IBOutlet UIButton *thirdImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdCheckImageView;
@property (weak, nonatomic) IBOutlet UILabel *thirdNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLocationLabel;

// block
@property (nonatomic, copy) UserTappedBlock userTapBlock;

+ (NSString *)reuseIdentifier;

- (void)changeCellStateSelected:(BOOL)selected;

- (void)updateCellWithFirstUser:(User *)firstUser
                     secondUser:(User *)secondUser
                      thirdUser:(User *)thirdUser
                  withConfirmed:(BOOL)confirmed;

- (IBAction)firstUserButtonPressed:(id)sender;
- (IBAction)secondUserButtonPressed:(id)sender;
- (IBAction)thirdUserButtonPressed:(id)sender;

- (void)setCellColor:(UIColor *)color;

- (void)updateCellWithFirstUser:(DevProfile *)firstUser
                     secondUser:(DevProfile *)secondUser
                      thirdUser:(DevProfile *)thirdUser;

@end
