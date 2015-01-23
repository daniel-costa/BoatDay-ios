//
//  BDTextViewCell.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDEditProfileAboutMeCell : UITableViewCell

+ (NSString *)reuseIdentifier;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *charRemainingLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;

- (void)changeCellStateSelected:(BOOL)selected;
- (void)updateCell;
- (void)charRemainingUpdate;

@end
