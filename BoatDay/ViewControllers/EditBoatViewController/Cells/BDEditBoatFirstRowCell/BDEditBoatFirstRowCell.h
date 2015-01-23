//
//  BDEditBoatFirstRowCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDEditBoatFirstRowCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *indicateLabel;

@property (weak, nonatomic) IBOutlet UITextField *boatNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *boatNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UITextField *typeTextField;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@property (weak, nonatomic) IBOutlet UITextField *lengthTextField;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;

@property (weak, nonatomic) IBOutlet UITextField *capacityTextField;
@property (weak, nonatomic) IBOutlet UILabel *capacityLabel;

@property (weak, nonatomic) IBOutlet UILabel *buildYearNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *buildYearButton;


- (void)changeCellStateSelected:(BOOL)selected;

@end
