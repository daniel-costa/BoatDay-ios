//
//  BDBoatListCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDBoatListCell.h"

@implementation BDBoatListCell

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
    
    self.name.font = [UIFont abelFontWithSize:16.0];
    
    self.boatType.font = [UIFont abelFontWithSize:14.0];
    
    self.addedDate.font = [UIFont abelFontWithSize:10.0];
    
    self.numberOfSeats.font = [UIFont abelFontWithSize:30.0];
    
    self.seatsLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
}

- (IBAction)messageBtnPressed:(id)sender {
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"BoatDay Team"
                                                          message:self.boat.rejectionMessage.text
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                otherButtonTitles: nil];
    
    [myAlertView show];
}

#pragma mark - Layout

- (void)updateLayoutWithBoat:(Boat*)boat {
    
    self.boat = boat;
    
    self.boatImage.image = [UIImage imageNamed:@"boat_av_blank"];
    self.boatImage.layer.cornerRadius = CGRectGetHeight(self.boatImage.frame) / 2.0;
    self.boatImage.clipsToBounds = YES;
    
    self.name.text = boat.name;
    self.boatType.text = [boat.type uppercaseString];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter birthdayDateFormatter];
    NSString *createdAt = [dateFormatter stringFromDate:boat.createdAt];
    
    self.addedDate.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"myBoats.cell.added", nil), createdAt];
    
    self.numberOfSeats.text = [NSString stringWithFormat:@"%d", [boat.passengerCapacity intValue]];
    
    self.seatsLabel.text = NSLocalizedString(@"myBoats.cell.seats", nil);
    
    self.messageButton.userInteractionEnabled = NO;
    
    // Put placeholder if we got no images
    if (boat.pictures.count > 0  && [boat.selectedPictureIndex integerValue] >= 0) {
        
        PFFile *theImage = boat.pictures[[boat.selectedPictureIndex integerValue]];
        
        // Get image from cache or from server if isnt available (background task)
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            self.boatImage.image = image;
            self.boatImage.layer.cornerRadius = CGRectGetHeight(self.boatImage.frame) / 2.0;
            self.boatImage.clipsToBounds = YES;
            
        }];
        
    }
    
    
}

#pragma mark - Private

- (void)changeCellStateHighlighted:(BOOL)highlighted {
    
    if (highlighted) {
        
        self.backgroundColor = [UIColor mediumGreenBoatDay];
        self.contentView.backgroundColor = [UIColor mediumGreenBoatDay];
        
        self.name.textColor = [UIColor whiteColor];
        self.boatType.textColor = [UIColor lightGrayBoatDay];
        self.addedDate.textColor = [UIColor lightGrayBoatDay];
        self.numberOfSeats.textColor = [UIColor whiteColor];
        self.seatsLabel.textColor = [UIColor whiteColor];
        
    }
    else {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.name.textColor = [UIColor greenBoatDay];
        self.boatType.textColor = [UIColor grayBoatDay];
        self.addedDate.textColor = [UIColor grayBoatDay];
        self.numberOfSeats.textColor = [UIColor mediumGreenBoatDay];
        self.seatsLabel.textColor = [UIColor mediumGreenBoatDay];
        
    }
    
    BoatStatus status = [self.boat.status integerValue];
    
    switch (status) {
        case BoatStatusDenied:
            self.statusImage.image = highlighted ? [UIImage imageNamed:@"cert_denied_white"] : [UIImage imageNamed:@"cert_denied"];
            self.messageButton.hidden = NO;
            self.messageButton.userInteractionEnabled = YES;
            [self.messageButton setBackgroundImage:highlighted ? [UIImage imageNamed:@"myboat_message_white"] : [UIImage imageNamed:@"myboat_message"]
                                          forState:UIControlStateNormal];
            break;
        case BoatStatusApproved:
            self.statusImage.image = highlighted ? [UIImage imageNamed:@"cert_approved_white"] : [UIImage imageNamed:@"cert_approved"];
            break;
        case BoatStatusPending:
            self.statusImage.image = highlighted ? [UIImage imageNamed:@"cert_pending_white"] : [UIImage imageNamed:@"cert_pending"];
            break;
        case BoatStatusNotSubmited:
            self.statusImage.image = highlighted ? [UIImage imageNamed:@"cert_inactive_white"] : [UIImage imageNamed:@"cert_inactive"];
            break;
        default:
            self.statusImage.image = nil;
            break;
    }
    
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

- (IBAction)messageButtonPress:(id)sender {
}
@end
