//
//  BDNotificationsCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDNotificationsCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

- (void)updateLayoutWithNotification:(Notification*)notification;

- (void)setCellColor:(UIColor *)color;

@end
