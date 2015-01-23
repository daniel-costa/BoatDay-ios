//
//  BDPersonalInfoPaymentCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDPersonalInfoPaymentCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *ssnLabel;
@property (weak, nonatomic) IBOutlet UITextField *ssnTextField;

- (void)changeCellStateSelected:(BOOL)selected;

@end
