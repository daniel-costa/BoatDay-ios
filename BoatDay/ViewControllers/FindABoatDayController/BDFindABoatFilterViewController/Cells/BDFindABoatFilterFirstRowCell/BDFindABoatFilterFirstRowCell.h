//
//  BDFindABoatFilterFirstRowCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DistanceChangeBlock)(CGFloat distance);

@interface BDFindABoatFilterFirstRowCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (nonatomic, copy) DistanceChangeBlock distanceChangeBlock;

@property (weak, nonatomic) IBOutlet UILabel *locationTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@property (weak, nonatomic) IBOutlet UILabel *timeframeTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *timeframeButton;

@property (weak, nonatomic) IBOutlet UILabel *availableSeatsTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *availableSeatsButton;

@property (weak, nonatomic) IBOutlet UILabel *distanceTitleLabel;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *suggestedPriceTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *suggestedPriceButton;

@property (weak, nonatomic) IBOutlet UILabel *keywordsTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;


- (void) setSliderToMiles:(CGFloat) miles;

@end
