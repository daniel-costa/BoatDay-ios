//
//  BDDefaultTableViewCell.h
//  BoatDay
//
//  Created by Mieraidihaimu Mieraisan on 25/01/15.
//  Copyright (c) 2015 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDDefaultTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cellNames;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
+ (NSString *)reuseIdentifier;
- (void) updateCellWith:(NSString *)name imageName:(NSString *)imageName;
@property (weak, nonatomic) IBOutlet UIView *lineBreakers;
@end
