//
//  BDMyEventListCell.h
//  BoatDay
//
//  Created by Mieraidihaimu Mieraisan on 24/01/15.
//  Copyright (c) 2015 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LABEL_TAG 100
#define IMAGE_TAG 101
#define VIEWS_PREFIX 9000

@interface BDMyEventListCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UIImageView *placeholder;
@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) BOOL shouldBeGray;

- (void)changeCellStateSelected:(BOOL)selected;

- (void) updateWithEvent:(Event *)event;

@end
