//
//  BDSelectDestinationPaymentCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SegmentedControlChangeBlock)(NSInteger index);

@interface BDSelectDestinationPaymentCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (nonatomic, copy) SegmentedControlChangeBlock segmentedControlChangeBlock;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UIView *bankAccountView;
@property (weak, nonatomic) IBOutlet UIView *venmoView;

// Bank Account
@property (weak, nonatomic) IBOutlet UILabel *bAIndicateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bAAccountNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *bAAccountNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *bARoutingNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *bARoutingNumberTextField;

// Venmo
@property (weak, nonatomic) IBOutlet UILabel *venmoIndicateLabel;
@property (weak, nonatomic) IBOutlet UILabel *venmoEmailLabel;
@property (weak, nonatomic) IBOutlet UITextField *venmoEmailTextField;
@property (weak, nonatomic) IBOutlet UILabel *venmoPhoneNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *venmoPhoneNumberTextField;

- (IBAction)segmentedValueChanged:(id)sender;

- (void)changeCellStateSelected:(BOOL)selected;

@end
