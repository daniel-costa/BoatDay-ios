//
//  BDHostRegistrationFirstRowCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDHostRegistrationFirstRowCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *indicateLabel;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;

@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *birthdayButton;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;

@property (weak, nonatomic) IBOutlet UITextField *firstAddressLineTextField;
@property (weak, nonatomic) IBOutlet UILabel *firstAddressLineLabel;

@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UITextField *zipCodeTextField;
@property (weak, nonatomic) IBOutlet UILabel *zipCodeLabel;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;


@property (weak, nonatomic) IBOutlet UILabel *ssnLabel;

@property (weak, nonatomic) IBOutlet UITextField *ssnCodeTextFiled;


- (void)changeCellStateSelected:(BOOL)selected;

@end
