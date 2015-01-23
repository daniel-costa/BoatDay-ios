//
//  BDActivitiesListCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LABEL_TAG 100
#define IMAGE_TAG 101
#define VIEWS_PREFIX 9000

@protocol BDActivitiesListCellDelegate <NSObject>

- (void)viewTappedAtSection:(NSInteger)section andRow:(NSInteger)row isSelected:(BOOL)selected;

@end


@interface BDActivitiesListCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (nonatomic, weak) id<BDActivitiesListCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@property (weak, nonatomic) IBOutlet UIView *thirdView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImageView;
@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;

@property (weak, nonatomic) IBOutlet UIView *fourthView;
@property (weak, nonatomic) IBOutlet UIImageView *fourthImageView;
@property (weak, nonatomic) IBOutlet UILabel *fourthLabel;

@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (nonatomic) NSInteger section;


- (void)changeCellStateSelected:(BOOL)selected;
- (void)updateCell;

@end
