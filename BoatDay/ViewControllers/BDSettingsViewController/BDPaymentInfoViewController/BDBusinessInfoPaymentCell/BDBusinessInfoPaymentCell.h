//
//  BDBusinessInfoPaymentCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDBusinessInfoPaymentCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *businessNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *businessNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *taxIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *taxIdTextField;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *confirmLabel;


- (void)changeCellStateSelected:(BOOL)selected;

- (void)setEnabled:(BOOL)enabled;

@end
