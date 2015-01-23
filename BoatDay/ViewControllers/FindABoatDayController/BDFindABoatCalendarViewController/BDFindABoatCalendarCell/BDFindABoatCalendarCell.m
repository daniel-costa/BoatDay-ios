//
//  BDFindABoatCalendarCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindABoatCalendarCell.h"
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CoreText.h>

@implementation BDFindABoatCalendarCell

+ (NSString *)reuseIdentifier {
    
    return NSStringFromClass([self class]);
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    
    for (UIView *currentView in self.subviews)
    {
        if([currentView isKindOfClass:[UIScrollView class]])
        {
            ((UIScrollView *)currentView).delaysContentTouches = NO;
            break;
        }
    }
    
    self.eventName.font = [UIFont abelFontWithSize:15.0];
    self.eventName.textColor = [UIColor whiteColor];
    
    self.dateLabel.font = [UIFont abelFontWithSize:11.0];
    self.dateLabel.textColor = RGB(18.0, 78.0, 88.0);
    self.dateLabel.numberOfLines = 0;
    
    [UIView setRoundedView:self.placeholder
                toDiameter:CGRectGetHeight(self.placeholder.frame)];
    
    [self.picture.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    self.picture.alpha = 0.0;
    
}

#pragma mark - Update Methods

- (void) updateWithEvent:(Event *)event {
    
    self.eventName.text = event.name;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter eventsCardDateFormatter];
    NSString *eventDate = [dateFormatter stringFromDate:event.startsAt];
    NSString *timeLeft = [event.endDate timeLeftSinceDate:event.startsAt];
    self.dateLabel.text = [NSString stringWithFormat:@"%@\nDuration: %@", eventDate, timeLeft];
    
    NSString *coinSymbol = NSLocalizedString(@"coinSymbol", nil);
    self.price.attributedText = [self createPriceStringWithPrice:event.price andCoinSymbol:coinSymbol];
    
    if (event.boat.pictures.count) {
        
        self.picture.alpha = 0.0;
        
        PFFile *boatPictureFile = event.boat.pictures[[event.boat.selectedPictureIndex integerValue]];
        
        // Get image User from cache or from server if isnt available (background task)
        [boatPictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            self.picture.image = image;
            
            [UIView setRoundedView:self.picture
                        toDiameter:CGRectGetHeight(self.picture.frame)];
            
            [UIView showViewAnimated:self.picture
                           withAlpha:YES
                            duration:0.4
                            andDelay:0.0
                            andScale:NO];
            
            
        }];
        
    }
    
}

#pragma mark - Private

- (void)changeCellStateHighlighted:(BOOL)highlighted {
    
    if (highlighted) {
        
        [self setCellColor:[UIColor darkGreenBoatDay]];
        self.dateLabel.textColor = [UIColor whiteColor];
        
    }
    else {
        
        if (self.shouldBeGray) {
            [self setCellColor:[UIColor grayBoatDay]];
            self.dateLabel.textColor = [UIColor whiteColor];
        }
        else {
            [self setCellColor:RGB(58.0, 191.0, 187.0)];
            self.dateLabel.textColor = RGB(18.0, 78.0, 88.0);
        }
    }
    
}

- (void)changeCellStateSelected:(BOOL)selected {
    
    if (selected) {
        
        [self setCellColor:[UIColor darkGreenBoatDay]];
        self.dateLabel.textColor = [UIColor whiteColor];
        
    }
    else {
        
        if (self.shouldBeGray) {
            [self setCellColor:[UIColor grayBoatDay]];
            self.dateLabel.textColor = [UIColor whiteColor];
        }
        else {
            [self setCellColor:RGB(58.0, 191.0, 187.0)];
            self.dateLabel.textColor = RGB(18.0, 78.0, 88.0);
        }
        
    }
    
}

#pragma mark - Overriden Methods

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    [self changeCellStateHighlighted:highlighted];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    [self changeCellStateHighlighted:selected];
    
}

#pragma mark - String Methods

- (NSMutableAttributedString *)createPriceStringWithPrice:(NSNumber *)price andCoinSymbol:(NSString *)coinSymbol {
    
    NSString *string = [NSString stringWithFormat:@"%@%@", coinSymbol, price];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *font = [UIFont abelFontWithSize:35.0];
    UIFont *smallFont = [UIFont abelFontWithSize:22.0];
    
    [attString beginEditing];
    [attString addAttribute:NSFontAttributeName value:(font) range:NSMakeRange(1, string.length - 1)];
    [attString addAttribute:NSFontAttributeName value:(smallFont) range:NSMakeRange(0, 1)];
    [attString addAttribute:(NSString*)kCTSuperscriptAttributeName value:@"1" range:NSMakeRange(0, 1)];
    
    [attString addAttribute:(NSString*)kCTForegroundColorAttributeName value:self.price.textColor range:NSMakeRange(0, string.length - 1)];
    [attString endEditing];
    
    return attString;
    
}

- (void)setCellColor:(UIColor *)color{
    self.contentView.backgroundColor = color;
    self.backgroundColor = color;
}

@end
