//
//  BDEventGuestsCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEventGuestsCell.h"

static NSString * const kUserPlaceholder = @"user_av_blank_lg";

@implementation BDEventGuestsCell

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
    
    self.firstNameLabel.font = [UIFont quattroCentoRegularFontWithSize:14.0];
    self.secondNameLabel.font = [UIFont quattroCentoRegularFontWithSize:14.0];
    self.thirdNameLabel.font = [UIFont quattroCentoRegularFontWithSize:14.0];
    
    self.firstLocationLabel.font = [UIFont quattroCentoRegularFontWithSize:11.0];
    self.secondLocationLabel.font = [UIFont quattroCentoRegularFontWithSize:11.0];
    self.thirdLocationLabel.font = [UIFont quattroCentoRegularFontWithSize:11.0];
    
    self.firstNameLabel.minimumScaleFactor = 0.8;
    self.secondNameLabel.minimumScaleFactor = 0.8;
    self.thirdNameLabel.minimumScaleFactor = 0.8;
    
    self.firstLocationLabel.minimumScaleFactor = 0.8;
    self.secondLocationLabel.minimumScaleFactor = 0.8;
    self.thirdLocationLabel.minimumScaleFactor = 0.8;
    
    self.firstNameLabel.adjustsFontSizeToFitWidth = YES;
    self.secondNameLabel.adjustsFontSizeToFitWidth = YES;
    self.thirdNameLabel.adjustsFontSizeToFitWidth = YES;
    
    self.firstLocationLabel.adjustsFontSizeToFitWidth = YES;
    self.secondLocationLabel.adjustsFontSizeToFitWidth = YES;
    self.thirdLocationLabel.adjustsFontSizeToFitWidth = YES;
    
}

- (void)updateCellWithFirstUser:(User *)firstUser
                     secondUser:(User*)secondUser
                      thirdUser:(User*)thirdUser
                  withConfirmed:(BOOL)confirmed {
    
    self.firstUser = firstUser;
    self.secondUser = secondUser;
    self.thirdUser = thirdUser;
    
    if (confirmed) {
        
        [self setCellColor:[UIColor eventsGreenBoatDay]];
        
        self.firstNameLabel.textColor = [UIColor whiteColor];
        self.secondNameLabel.textColor = [UIColor whiteColor];
        self.thirdNameLabel.textColor = [UIColor whiteColor];
        
        self.firstCheckImageView.hidden = NO;
        self.secondCheckImageView.hidden = NO;
        self.thirdCheckImageView.hidden = NO;
        
    } else {
        
        [self setCellColor:[UIColor whiteColor]];
        
        self.firstNameLabel.textColor = [UIColor eventsGreenBoatDay];
        self.secondNameLabel.textColor = [UIColor eventsGreenBoatDay];
        self.thirdNameLabel.textColor = [UIColor eventsGreenBoatDay];
        
        self.firstCheckImageView.hidden = YES;
        self.secondCheckImageView.hidden = YES;
        self.thirdCheckImageView.hidden = YES;
        
    }
    
    self.firstLocationLabel.textColor = [UIColor eventsDarkGreenBoatDay];
    self.secondLocationLabel.textColor = [UIColor eventsDarkGreenBoatDay];
    self.thirdLocationLabel.textColor = [UIColor eventsDarkGreenBoatDay];
    
    if (firstUser) {
        
        self.firstImageView.alpha = 0.0;
        
        self.firstNameLabel.hidden = NO;
        self.firstLocationLabel.hidden = NO;
        self.firstPlaceholderImageView.hidden = NO;
        self.firstImageView.hidden = NO;
        
        self.firstNameLabel.text = firstUser.shortName;
        self.firstLocationLabel.text = firstUser.fullLocation;
        
        if (firstUser.pictures.count > 0 && [firstUser.selectedPictureIndex integerValue] >= 0) {
            
            PFFile *theImage = firstUser.pictures[[firstUser.selectedPictureIndex integerValue]];
            
            self.firstPlaceholderImageView.image = [UIImage imageNamed:kUserPlaceholder];
            
            [UIView setRoundedView:self.firstPlaceholderImageView
                        toDiameter:CGRectGetHeight(self.firstPlaceholderImageView.frame)];
            
            // Get image from cache or from server if isnt available (background task)
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                UIImage *image = [UIImage imageWithData:data];
                
                if (error) {
                    image = [UIImage imageNamed:kUserPlaceholder];
                }
                
                [self.firstOriginImageView setImage:image];
                
                [UIView setRoundedView:self.firstOriginImageView
                            toDiameter:CGRectGetHeight(self.firstOriginImageView.frame)];
                
                [UIView showViewAnimated:self.firstOriginImageView withAlpha:YES andDuration:0.2];
                
            }];
            
        } else {
            
            [self.firstOriginImageView setImage:[UIImage imageNamed:kUserPlaceholder]];
            
            [UIView setRoundedView:self.firstOriginImageView
                        toDiameter:CGRectGetHeight(self.firstOriginImageView.frame)];
            [UIView showViewAnimated:self.firstImageView withAlpha:YES andDuration:0.2];
            
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pSelectedFirst)];
        [self.firstOriginImageView addGestureRecognizer:tap];
        [self.firstOriginImageView setUserInteractionEnabled:YES];
        self.firstPlaceholderImageView.hidden = YES;
        self.firstImageView.hidden = YES;
    } else {
        self.firstNameLabel.hidden = YES;
        self.firstLocationLabel.hidden = YES;
        self.firstPlaceholderImageView.hidden = YES;
        self.firstImageView.hidden = YES;
        self.firstCheckImageView.hidden = YES;
        self.firstOriginImageView.hidden = YES;
    }
    
    if (secondUser) {
        
        self.secondImageView.alpha = 0.0;
        
        self.secondNameLabel.hidden = NO;
        self.secondLocationLabel.hidden = NO;
        self.secondPlaceholderImageView.hidden = NO;
        self.secondImageView.hidden = NO;
        
        self.secondNameLabel.text = secondUser.shortName;
        self.secondLocationLabel.text = secondUser.fullLocation;
        
        if (secondUser.pictures.count > 0 && [secondUser.selectedPictureIndex integerValue] >= 0) {
            
            PFFile *theImage = secondUser.pictures[[secondUser.selectedPictureIndex integerValue]];
            
            self.secondPlaceholderImageView.image = [UIImage imageNamed:kUserPlaceholder];
            [UIView setRoundedView:self.secondPlaceholderImageView
                        toDiameter:CGRectGetHeight(self.secondPlaceholderImageView.frame)];
            
            
            // Get image from cache or from server if isnt available (background task)
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                UIImage *image = [UIImage imageWithData:data];
                
                if (error) {
                    image = [UIImage imageNamed:kUserPlaceholder];
                }
                
                [self.secondOriginImageView setImage:image];
//                
                [UIView setRoundedView:self.secondOriginImageView
                            toDiameter:CGRectGetHeight(self.secondOriginImageView.frame)];
                
                [UIView showViewAnimated:self.secondOriginImageView withAlpha:YES andDuration:0.2];
                
            }];
            
        } else {
            
            [self.secondOriginImageView setImage:[UIImage imageNamed:kUserPlaceholder]];
//            
            [UIView setRoundedView:self.secondOriginImageView
                        toDiameter:CGRectGetHeight(self.secondOriginImageView.frame)];
            
            [UIView showViewAnimated:self.secondOriginImageView withAlpha:YES andDuration:0.2];
            
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pSelectedSecond)];
        [self.secondOriginImageView addGestureRecognizer:tap];
        [self.secondOriginImageView setUserInteractionEnabled:YES];
        self.secondPlaceholderImageView.hidden = YES;
        self.secondImageView.hidden = YES;
        
    } else {
        self.secondNameLabel.hidden = YES;
        self.secondLocationLabel.hidden = YES;
        self.secondPlaceholderImageView.hidden = YES;
        self.secondImageView.hidden = YES;
        self.secondCheckImageView.hidden = YES;
        self.secondOriginImageView.hidden = YES;
    }
    
    if (thirdUser) {
        
        self.thirdImageView.alpha = 0.0;
        
        self.thirdNameLabel.hidden = NO;
        self.thirdLocationLabel.hidden = NO;
        self.thirdPlaceholderImageView.hidden = NO;
        self.thirdImageView.hidden = NO;
        
        self.thirdNameLabel.text = thirdUser.shortName;
        self.thirdLocationLabel.text = thirdUser.fullLocation;
        
        if (thirdUser.pictures.count > 0 && [thirdUser.selectedPictureIndex integerValue] >= 0) {
            
            PFFile *theImage = thirdUser.pictures[[thirdUser.selectedPictureIndex integerValue]];
            
            self.thirdPlaceholderImageView.image = [UIImage imageNamed:kUserPlaceholder];
            [UIView setRoundedView:self.thirdPlaceholderImageView
                        toDiameter:CGRectGetHeight(self.thirdPlaceholderImageView.frame)];
            
            
            // Get image from cache or from server if isnt available (background task)
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                UIImage *image = [UIImage imageWithData:data];
                
                if (error) {
                    image = [UIImage imageNamed:kUserPlaceholder];
                }
                
                [self.thirdOriginImageView setImage:image];
                
                [UIView setRoundedView:self.thirdOriginImageView
                            toDiameter:CGRectGetHeight(self.thirdOriginImageView.frame)];
                
                [UIView showViewAnimated:self.thirdOriginImageView withAlpha:YES andDuration:0.2];
                
            }];
            
        } else {
            
            [self.thirdOriginImageView setImage:[UIImage imageNamed:kUserPlaceholder]];
            
            [UIView setRoundedView:self.thirdOriginImageView
                        toDiameter:CGRectGetHeight(self.thirdOriginImageView.frame)];
            
            [UIView showViewAnimated:self.thirdOriginImageView withAlpha:YES andDuration:0.2];
            
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pSelectedThrid)];
        [self.thirdOriginImageView addGestureRecognizer:tap];
        [self.thirdOriginImageView setUserInteractionEnabled:YES];
        self.thirdPlaceholderImageView.hidden = YES;
        self.thirdImageView.hidden = YES;
        
    } else {
        self.thirdNameLabel.hidden = YES;
        self.thirdLocationLabel.hidden = YES;
        self.thirdPlaceholderImageView.hidden = YES;
        self.thirdImageView.hidden = YES;
        self.thirdCheckImageView.hidden = YES;
        self.thirdOriginImageView.hidden = YES;
    }
    
    
}
- (void)pSelectedFirst{
    if (self.userTapBlock){
        self.userTapBlock(self.firstUser);
    }

}

- (void)pSelectedSecond{
    if (self.userTapBlock){
        self.userTapBlock(self.secondUser);
    }
}
- (void)pSelectedThrid{
    if (self.userTapBlock){
        self.userTapBlock(self.thirdUser);
    }
}


- (IBAction)firstUserButtonPressed:(id)sender {
    if (self.userTapBlock){
        self.userTapBlock(self.firstUser);
    }
}

- (IBAction)secondUserButtonPressed:(id)sender {
    if (self.userTapBlock){
        self.userTapBlock(self.secondUser);
    }
}

- (IBAction)thirdUserButtonPressed:(id)sender {
    if (self.userTapBlock){
        self.userTapBlock(self.thirdUser);
    }
}

#pragma mark - Private

- (void)changeCellStateHighlighted:(BOOL)highlighted {
    
}

- (void)changeCellStateSelected:(BOOL)selected {
    
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


- (void)setCellColor:(UIColor *)color{
    self.contentView.backgroundColor = color;
    self.backgroundColor = color;
}

#pragma mark - DevProfile

- (void)updateCellWithFirstUser:(DevProfile *)firstUser
                     secondUser:(DevProfile *)secondUser
                      thirdUser:(DevProfile *)thirdUser {
    
    [self setCellColor:[UIColor whiteColor]];
    
    self.firstNameLabel.textColor = [UIColor eventsGreenBoatDay];
    self.secondNameLabel.textColor = [UIColor eventsGreenBoatDay];
    self.thirdNameLabel.textColor = [UIColor eventsGreenBoatDay];
    
    self.firstCheckImageView.hidden = YES;
    self.secondCheckImageView.hidden = YES;
    self.thirdCheckImageView.hidden = YES;
    
    self.firstLocationLabel.textColor = [UIColor eventsDarkGreenBoatDay];
    self.secondLocationLabel.textColor = [UIColor eventsDarkGreenBoatDay];
    self.thirdLocationLabel.textColor = [UIColor eventsDarkGreenBoatDay];
    
    if (firstUser) {
        
        self.firstImageView.alpha = 1.0;
        
        self.firstNameLabel.hidden = NO;
        self.firstLocationLabel.hidden = NO;
        self.firstPlaceholderImageView.hidden = NO;
        self.firstImageView.hidden = NO;
        
        self.firstNameLabel.text = firstUser.name;
        self.firstLocationLabel.text = firstUser.position;
        
        UIImage *image = [UIImage imageNamed:firstUser.imageName];
        
        [self.firstImageView setImage:image forState:UIControlStateNormal];
        
        [UIView setRoundedView:self.firstImageView
                    toDiameter:CGRectGetHeight(self.firstImageView.frame)];
        
        [UIView showViewAnimated:self.firstImageView withAlpha:YES andDuration:0.2];
        
        [UIView hideViewAnimated:self.firstPlaceholderImageView
                       withAlpha:YES
                     andDuration:0.3];
        
    } else {
        self.firstNameLabel.hidden = YES;
        self.firstLocationLabel.hidden = YES;
        self.firstPlaceholderImageView.hidden = YES;
        self.firstImageView.hidden = YES;
        self.firstCheckImageView.hidden = YES;
    }
    
    if (secondUser) {
        
        self.secondImageView.alpha = 0.0;
        
        self.secondNameLabel.hidden = NO;
        self.secondLocationLabel.hidden = NO;
        self.secondPlaceholderImageView.hidden = NO;
        self.secondImageView.hidden = NO;
        
        self.secondNameLabel.text = secondUser.name;
        self.secondLocationLabel.text = secondUser.position;
        
        UIImage *image = [UIImage imageNamed:secondUser.imageName];
        
        [self.secondImageView setImage:image forState:UIControlStateNormal];
        
        [UIView setRoundedView:self.secondImageView
                    toDiameter:CGRectGetHeight(self.secondImageView.frame)];
        
        [UIView showViewAnimated:self.secondImageView withAlpha:YES andDuration:0.2];
        
    } else {
        self.secondNameLabel.hidden = YES;
        self.secondLocationLabel.hidden = YES;
        self.secondPlaceholderImageView.hidden = YES;
        self.secondImageView.hidden = YES;
        self.secondCheckImageView.hidden = YES;
        
    }
    
    if (thirdUser) {
        
        self.thirdImageView.alpha = 0.0;
        
        self.thirdNameLabel.hidden = NO;
        self.thirdLocationLabel.hidden = NO;
        self.thirdPlaceholderImageView.hidden = NO;
        self.thirdImageView.hidden = NO;
        
        self.thirdNameLabel.text = thirdUser.name;
        self.thirdLocationLabel.text = thirdUser.position;
        
        UIImage *image = [UIImage imageNamed:thirdUser.imageName];
        
        [self.thirdImageView setImage:image forState:UIControlStateNormal];
        
        [UIView setRoundedView:self.thirdImageView
                    toDiameter:CGRectGetHeight(self.thirdImageView.frame)];
        
        [UIView showViewAnimated:self.thirdImageView withAlpha:YES andDuration:0.2];
        
    } else {
        
        self.thirdNameLabel.hidden = YES;
        self.thirdLocationLabel.hidden = YES;
        self.thirdPlaceholderImageView.hidden = YES;
        self.thirdImageView.hidden = YES;
        self.thirdCheckImageView.hidden = YES;
        
    }
    
}

@end
