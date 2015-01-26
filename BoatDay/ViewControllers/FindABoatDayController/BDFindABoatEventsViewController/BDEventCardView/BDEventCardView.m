//
//  BDEventCardView.m
//  BoatDay
//
//  Created by Diogo Nunes on 30/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEventCardView.h"
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CoreText.h>
#import "NSDate+Extensions.h"

@implementation BDEventCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    
    self.contentMode = UIViewContentModeCenter;
    self.backgroundColor = [UIColor clearColor];
    
    self.numberOfSeatsLabel.font = [UIFont abelFontWithSize:70.0];
    self.numberOfSeatsLabel.textColor = [UIColor whiteColor];
    
    self.openSeatsLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.openSeatsLabel.textColor = [UIColor whiteColor];
    self.openSeatsLabel.text = NSLocalizedString(@"eventCard.view.openSeats", nil);
    
    self.seatsLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.seatsLabel.textColor = [UIColor whiteColor];
    
    self.userNameLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.userNameLabel.textColor = [UIColor whiteColor];
    
    self.locationLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.locationLabel.textColor = [UIColor yellowBoatDay];
    
    self.eventNameLabel.font = [UIFont quattroCentoBoldFontWithSize:16.0];
    self.eventNameLabel.textColor = [UIColor whiteColor];
    
    self.suggestedLabel.textColor = [UIColor whiteColor];
    self.suggestedLabel.font = [UIFont abelFontWithSize:9.0];
    self.suggestedLabel.textAlignment = NSTextAlignmentRight;
    self.suggestedLabel.text = NSLocalizedString(@"eventProfile.suggestedContribution", nil);
    self.suggestedLabel.hidden = YES;

    self.dateLabel.font = [UIFont quattroCentoRegularFontWithSize:11.0];
    self.dateLabel.textColor = RGB(18.0, 78.0, 88.0);
    
    self.starRating.backgroundColor = [UIColor clearColor];
    self.starRating.starHighlightedImage = [UIImage imageNamed:@"rating_single_white"];
    self.starRating.starImage = [UIImage imageNamed:@"rating_single_green"];
    self.starRating.maxRating = 5.0;
    self.starRating.horizontalMargin = 1;
    self.starRating.editable = NO;
    self.starRating.displayMode = EDStarRatingDisplayFull;
    self.starRating.userInteractionEnabled = NO;
    self.starRating.rating = 0;
    
    self.boatPlaceholderImageView.image = [UIImage imageNamed:@"eventCardPlaceholder"];
    
    self.userPicturePlaceholderImageView.image = [UIImage imageNamed:@"user_av_blank"];
    [UIView setRoundedView:self.userPicturePlaceholderImageView
                toDiameter:CGRectGetHeight(self.userPicturePlaceholderImageView.frame)];
    
    [self.userPicturePlaceholderImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.userPicturePlaceholderImageView.layer setBorderWidth:1.0];
    
    self.userPictureImageView.alpha = 0.0;
    self.boatImageView.alpha = 0.0;
    
    self.statusLabel.font = [UIFont abelFontWithSize:12.0];
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.backgroundColor = [UIColor greenBoatDay];
    
}

#pragma mark - Update Methods

- (void) updateCardWithEvent:(Event *)event {
    
//    NSInteger numberOfUsersAttending = 0;
//    
//    // Check for user seats request
//    for (SeatRequest *request in event.seatRequests) {
//        
//        if(![request isEqual:[NSNull null]]) {
//            if ([request.status integerValue] == SeatRequestStatusAccepted) {
//                numberOfUsersAttending += [request.numberOfSeats integerValue];
//            }
//        }
//        
//    }
//    
//    NSInteger availableSeats = event.availableSeats.integerValue - numberOfUsersAttending;
    self.numberOfSeatsLabel.text = [NSString stringWithFormat:@"%ld", (long)event.freeSeats.integerValue];
    self.seatsLabel.text = [NSString stringWithFormat:@"%ld %@", (long)event.availableSeats.integerValue, NSLocalizedString(@"eventCard.view.totalSeats", nil)];

    self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"eventCard.hostedBy", nil), [event.host shortName]];
    
    self.locationLabel.text = event.locationName;
    
    //self.starRating.rating = [[Session sharedSession] averageReviewsStarsForUser:event.host];
    self.starRating.hidden = YES;
    
    self.eventNameLabel.text = event.name;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter eventsCardDateFormatter];
    NSString *eventDate = [dateFormatter stringFromDate:event.startsAt];
    NSString *timeLeft = [event.endDate timeLeftSinceDate:event.startsAt];
    self.dateLabel.text = [NSString stringWithFormat:@"%@\nDuration: %@", eventDate, timeLeft];
    
    NSString *coinSymbol = NSLocalizedString(@"coinSymbol", nil);
    
    self.priceLabel.attributedText = [self createPriceStringWithPrice:GetSeatPrice([NSNumber numberWithInt:event.price.integerValue])
                                                        andCoinSymbol:coinSymbol];
    
    if (event.host.pictures.count && [event.host.selectedPictureIndex integerValue] >= 0) {
        
        PFFile *userPictureFile = event.host.pictures[[event.host.selectedPictureIndex integerValue]];
        
        // Get image User from cache or from server if isnt available (background task)
        [userPictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            self.userPictureImageView.image = image;
            
            [UIView setRoundedView:self.userPictureImageView
                        toDiameter:CGRectGetHeight(self.userPictureImageView.frame)];
            
            [UIView showViewAnimated:self.userPictureImageView
                           withAlpha:YES
                            duration:0.2
                            andDelay:0.0
                            andScale:NO];
            
            [UIView hideViewAnimated:self.userPicturePlaceholderImageView
                           withAlpha:YES
                         andDuration:0.3];
        }];
    } else {
        
        self.userPictureImageView.image = [UIImage imageNamed:@"user_av_none"];
        
        [UIView setRoundedView:self.userPictureImageView
                    toDiameter:CGRectGetHeight(self.userPictureImageView.frame)];
        
        [UIView showViewAnimated:self.userPictureImageView
                       withAlpha:YES
                        duration:0.2
                        andDelay:0.0
                        andScale:NO];
        
        [UIView hideViewAnimated:self.userPicturePlaceholderImageView
                       withAlpha:YES
                     andDuration:0.3];
        
    }
    
    if (event.boat.pictures.count && [event.boat.selectedPictureIndex integerValue] >= 0) {
        
        PFFile *boatPictureFile = event.boat.pictures[[event.boat.selectedPictureIndex integerValue]];
        
        // Get image User from cache or from server if isnt available (background task)
        [boatPictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            self.boatImageView.image = image;
            
            [UIView showViewAnimated:self.boatImageView
                           withAlpha:YES
                            duration:0.2
                            andDelay:0.0
                            andScale:NO];
            
            [UIView hideViewAnimated:self.boatPlaceholderImageView
                           withAlpha:YES
                         andDuration:0.3];
        }];
        
    }
    
    NSDate *nowDate = [NSDate date];
    
    // starts later than "now"
    if ([event.startsAt compare:nowDate] == NSOrderedDescending) {
        
        if ([event.host isEqual:[User currentUser]]) {
            
            // User is hosting the event
            
            switch ([event.status integerValue]) {
                case EventStatusNotSubmited:
                    self.statusLabel.text = NSLocalizedString(@"eventCard.status.hosting.notsubmited", nil);
                    self.statusLabel.backgroundColor = [UIColor yellowBoatDay];
                    break;
                case EventStatusDenied:
                    self.statusLabel.text = NSLocalizedString(@"eventCard.status.hosting.denied", nil);
                    self.statusLabel.backgroundColor = [UIColor redBoatDay];
                    break;
                case EventStatusApproved:
                    self.statusLabel.text = NSLocalizedString(@"eventCard.status.hosting.approved", nil);
                    self.statusLabel.backgroundColor = [UIColor greenBoatDay];
                    break;
                case EventStatusPending:
                    self.statusLabel.text = NSLocalizedString(@"eventCard.status.hosting.pending", nil);
                    self.statusLabel.backgroundColor = [UIColor yellowBoatDay];
                    break;
                case EventStatusCanceled:
                    self.statusLabel.text = NSLocalizedString(@"eventCard.status.hosting.canceled", nil);
                    self.statusLabel.backgroundColor = [UIColor redBoatDay];
                    break;
                default:
                    break;
            }
            
            
        }
        else {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@", [User currentUser]];
            NSArray *filteredArray = [event.seatRequests filteredArrayUsingPredicate:predicate];
            SeatRequest *seatRequest = nil;
            
            for (SeatRequest *sReq in filteredArray) {
                if ([sReq.status integerValue] != SeatRequestStatusRejected) {
                    seatRequest = sReq;
                    break;
                } else {
                    seatRequest = sReq;
                }
            }
            
            if (seatRequest) {
                switch ([seatRequest.status integerValue]) {
                    case SeatRequestStatusPending:
                        self.statusLabel.text = NSLocalizedString(@"eventCard.status.attending.pending", nil);
                        self.statusLabel.backgroundColor = [UIColor yellowBoatDay];
                        break;
                    case SeatRequestStatusAccepted:
                        self.statusLabel.text = NSLocalizedString(@"eventCard.status.attending.accepted", nil);
                        self.statusLabel.backgroundColor = [UIColor greenBoatDay];
                        break;
                    case SeatRequestStatusRejected:
                        self.statusLabel.text = NSLocalizedString(@"eventCard.status.attending.rejected", nil);
                        self.statusLabel.backgroundColor = [UIColor redBoatDay];
                        break;
                    default:
                        break;
                }
            }
            else {
                self.statusLabel.text = NSLocalizedString(@"eventCard.status.somethingWentWrong", nil);
                self.statusLabel.backgroundColor = [UIColor greenBoatDay];
            }
            
        }
        
    }
    else {
        
        // end later than "now"
        if ([nowDate compare:event.endDate] == NSOrderedDescending){
            // history
            self.statusLabel.text = NSLocalizedString(@"eventCard.status.history.eventOver", nil);
            self.statusLabel.backgroundColor = [UIColor redBoatDay];
        }
        else {
            //event is live
            self.statusLabel.text = NSLocalizedString(@"eventCard.status.eventIsLive", nil);
            self.statusLabel.backgroundColor = [UIColor greenBoatDay];
        }
        
    }
    
}

#pragma mark - String Methods

- (NSMutableAttributedString *)createPriceStringWithPrice:(NSNumber *)price andCoinSymbol:(NSString *)coinSymbol {
    
    NSString *string = [NSString stringWithFormat:@"%@%@", coinSymbol, price];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *font = [UIFont abelFontWithSize:39.0];
    UIFont *smallFont = [UIFont abelFontWithSize:24.0];
    [attString beginEditing];
    [attString addAttribute:NSFontAttributeName value:(font) range:NSMakeRange(1, string.length - 1)];
     [attString addAttribute:NSFontAttributeName value:(smallFont) range:NSMakeRange(0, 1)];
    [attString addAttribute:(NSString*)kCTSuperscriptAttributeName value:@"1" range:NSMakeRange(0, 1)];
    
    [attString addAttribute:(NSString*)kCTForegroundColorAttributeName value:self.priceLabel.textColor range:NSMakeRange(0, string.length - 1)];
    [attString endEditing];
    
    return attString;
    
}



@end
