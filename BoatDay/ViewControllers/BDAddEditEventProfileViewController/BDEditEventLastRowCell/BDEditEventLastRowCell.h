//
//  BDEditBoatFirstRowCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDEditEventLastRowCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *indicateLabel;

@property (weak, nonatomic) IBOutlet UITextField *eventNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UIButton *availableSeatsButton;
@property (weak, nonatomic) IBOutlet UILabel *availableSeatsLabel;

@property (weak, nonatomic) IBOutlet UITextField *pricePerSeatTextField;
@property (weak, nonatomic) IBOutlet UILabel *pricePerSeatLabel;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *pickUpTimeButton;
@property (weak, nonatomic) IBOutlet UILabel *pickUpTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *endTimeButton;

@property (weak, nonatomic) IBOutlet UIButton *estimatedIncomeButton;
@property (weak, nonatomic) IBOutlet UILabel *estimatedIncomeLabel;

- (void)changeCellStateSelected:(BOOL)selected;

@end
