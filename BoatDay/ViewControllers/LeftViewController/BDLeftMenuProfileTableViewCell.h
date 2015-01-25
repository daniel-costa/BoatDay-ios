//
//  BDLeftMenuProfileTableViewCell.h
//  BoatDay
//
//  Created by Mieraidihaimu Mieraisan on 24/01/15.
//  Copyright (c) 2015 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDLeftMenuProfileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
- (void)updateProfileCellWith:(UIImage *)profileImage profileName:(NSString *)profileName;
+ (NSString *)reuseIdentifier;
@end
