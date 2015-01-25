//
//  BDLeftMenuNotificationTableViewCell.h
//  BoatDay
//
//  Created by Mieraidihaimu Mieraisan on 24/01/15.
//  Copyright (c) 2015 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDLeftMenuNotificationTableViewCell : UITableViewCell
+ (NSString *)reuseIdentifier;
@property (weak, nonatomic) IBOutlet UIImageView *notificationImageVIew;

@property (weak, nonatomic) IBOutlet UILabel *notificationDescriptionLabel;
@end
