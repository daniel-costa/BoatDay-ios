//
//  BDFindABoatCalendarCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LABEL_TAG 100
#define IMAGE_TAG 101
#define VIEWS_PREFIX 9000

@interface BDFindABoatCalendarCell : UITableViewCell

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
