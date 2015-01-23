//
//  BDFindABoatFilterFamilyContentViewCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBSwitch.h"

// Define activities change block
typedef void (^MBSwitchChangeBlock)(BOOL isOn);

@interface BDFindABoatFilterFamilyContentViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MBSwitch *MBSwitch;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, copy) MBSwitchChangeBlock mbSwitchChangeBlock;

+ (NSString *)reuseIdentifier;

- (void)changeCellStateSelected:(BOOL)selected;

@end
