//
//  BDEventProfileDetailsViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEventProfileDetailsViewController.h"

#import "EDStarRating.h"
#import "MHFacebookImageViewer.h"
#import "UIImage+Resize.h"
#import "UIAlertView+Blocks.h"

#import "BDEventActivitiesViewController.h"
#import "BDGotoLocationViewController.h"
#import "BDSeatRequestViewController.h"
#import "BDFindUsersViewController.h"
#import "BDFinalizeContributionViewController.h"
#import "BDProfileViewController.h"

#define HEADER_HEIGHT 194.0f
#define HEADER_INIT_FRAME CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)
#define USER_INFO_HEADER_HEIGHT 50.0f
#define USER_INFO_HEADER_BIGGER_HEIGHT 60.0f
#define IMAGE_AND_NAME_OFFSET 50.0f

#define kBackgroundParallexFactor 0.5f

@interface BDEventProfileDetailsViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *activities;

// Parallax

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) UIScrollView *backgroundScrollView;
@property (strong, nonatomic) UIView *boatNameView;
@property (strong, nonatomic) UILabel *eventNameLabel;
@property (strong, nonatomic) UILabel *eventDateLabel;

@property (strong, nonatomic) UIImageView *eventImageView;
@property (strong, nonatomic) UIImageView *eventPlaceholderImageView;

// bottom View
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *buttonBottomView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSeatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;

// Header Bottom View

@property (weak, nonatomic) IBOutlet UIView *headerBottomView;
@property (weak, nonatomic) IBOutlet UILabel *headerBottomViewLabel;

// Event Info
@property (strong, nonatomic) IBOutlet UIView *eventInfoView;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *activitiesView;
@property (weak, nonatomic) IBOutlet UIScrollView *activitiesScrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitiesIndicator;
@property (weak, nonatomic) IBOutlet UIView *infoHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *hostedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userPlaceholderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userPictureImageView;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;
@property (weak, nonatomic) IBOutlet UIButton *pinLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *profileAccessView;
@property (weak, nonatomic) IBOutlet UILabel *noReviewLabel;

// Data
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) SeatRequest *userRequest;
@property (nonatomic) NSInteger numberOfUsersAttending;

@property (strong, nonatomic) NSArray *reviews;

- (IBAction)pinLocationButtonPressed:(id)sender;
- (IBAction)buttonBottomViewPressed:(id)sender;
- (IBAction)activitiesButtonPressed:(id)sender;

@end

@implementation BDEventProfileDetailsViewController

- (instancetype)initWithEvent:(Event *)event {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _event = event;
    
    return self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self setupView];
    
    [self getReviews];
    
}


#pragma mark - Get Data

- (void) getReviews {
    
    self.reviews = [[NSArray alloc] init];
    
    PFQuery *query = [Review query];
    [query includeKey:@"from"];
    [query includeKey:@"to"];
    [query whereKey:@"to" equalTo:self.event.host];
    [query whereKey:@"deleted" notEqualTo:@(YES)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            if (objects.count < 1) {
                self.ratingView.hidden = YES;
                [self.noReviewLabel setText:[NSString stringWithFormat:@"NO %@",NSLocalizedString(@"profile.reviews",nil)]];
            }else{
                self.reviews = objects ?: [[NSArray alloc] init];
                [self.noReviewLabel setText:@""];
                self.ratingView.hidden = NO;
                self.ratingView.rating = [[Session sharedSession] averageReviewsStarsWithReviews:self.reviews];
            
            }
            

        }
        
    }];
    
}


#pragma mark - Setup Methods

- (void) setupView {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    [self setupScrollView];
    
    [self setEventData];
    
    [self setupColorsAndFonts];
    
    [self getEventImage];
    
    [self setupBottomView];
    
    [self adjustScrollViewHeight];

}

- (void) setupScrollView {
    
    [[self.mainScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self.backgroundScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // main scrollView
    self.mainScrollView.delegate = self;
    self.mainScrollView.bounces = YES;
    self.mainScrollView.alwaysBounceVertical = YES;
    self.mainScrollView.contentSize = CGSizeZero;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.delaysContentTouches = NO;
    
    // top image scrollView (for parallax effect)
    self.backgroundScrollView = [[UIScrollView alloc] initWithFrame:HEADER_INIT_FRAME];
    self.backgroundScrollView.scrollEnabled = NO;
    self.backgroundScrollView.contentSize = CGSizeMake(self.mainScrollView.frame.size.width, 1000);
    self.backgroundScrollView.showsVerticalScrollIndicator = YES;
    
    // user image
    self.eventImageView = [[UIImageView alloc] initWithFrame:HEADER_INIT_FRAME];
    self.eventImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.eventImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.eventImageView.backgroundColor = [UIColor clearColor];
    
    // user image placeholder
    self.eventPlaceholderImageView = [[UIImageView alloc] initWithFrame:HEADER_INIT_FRAME];
    self.eventPlaceholderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.eventPlaceholderImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.backgroundScrollView addSubview:self.eventPlaceholderImageView];
    [self.backgroundScrollView addSubview:self.eventImageView];
    
    // set infoView under userImageView
    setFrameY(self.eventInfoView, CGRectGetMaxY(self.eventImageView.frame));
    
    [self.mainScrollView addSubview:self.backgroundScrollView];
    [self.mainScrollView addSubview:self.eventInfoView];
    
    CGFloat boatNameViewHeight = 36.0;
    self.boatNameView = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(self.eventImageView.frame) - boatNameViewHeight, CGRectGetHeight(self.view.frame), boatNameViewHeight)];
    self.boatNameView.backgroundColor = [UIColor clearColor];
    [self.mainScrollView addSubview:self.boatNameView];
    
    UIView *boatNameViewBackground = [[UIView alloc] initWithFrame:self.boatNameView.bounds];
    boatNameViewBackground.backgroundColor = [UIColor blackColor];
    boatNameViewBackground.alpha = 0.5;
    [self.boatNameView addSubview:boatNameViewBackground];
    
    self.eventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 160.0, boatNameViewHeight)];
    self.eventNameLabel.minimumScaleFactor = 0.5;
    self.eventNameLabel.textColor = [UIColor whiteColor];
    self.eventNameLabel.textAlignment = NSTextAlignmentLeft;
    [self.boatNameView addSubview:self.eventNameLabel];
    
    CGFloat eventDateLabelWidth = 125.0;
    self.eventDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - eventDateLabelWidth - 10.0, 2.0, eventDateLabelWidth, boatNameViewHeight)];
    self.eventDateLabel.minimumScaleFactor = 0.5;
    self.eventDateLabel.numberOfLines = 0;
    self.eventDateLabel.textColor = [UIColor whiteColor];
    self.eventDateLabel.textAlignment = NSTextAlignmentRight;
    [self.boatNameView addSubview:self.eventDateLabel];
    
}

- (void) adjustScrollViewHeight {
    
    if (!self.headerBottomView.hidden) {
        setFrameHeight(self.mainScrollView, CGRectGetMinY(self.headerBottomView.frame));
    }
    else {
        setFrameHeight(self.mainScrollView, CGRectGetHeight(self.view.frame));
    }
    
    [self.eventDescriptionLabel sizeToFit];
    
    setFrameHeight(self.eventInfoView, CGRectGetMaxY(self.eventDescriptionLabel.frame) + 5.0);
    setFrameY(self.eventInfoView, CGRectGetMaxY(self.backgroundScrollView.frame));
    
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame),
                                                 CGRectGetHeight(self.backgroundScrollView.frame) + CGRectGetHeight(self.eventInfoView.frame));
    
}

- (void) setupColorsAndFonts {
    
    self.eventNameLabel.textColor = [UIColor whiteColor];
    self.eventNameLabel.font = [UIFont quattroCentoRegularFontWithSize:17.0];
    self.eventNameLabel.minimumScaleFactor = 0.9;
    self.eventNameLabel.adjustsFontSizeToFitWidth = YES;
    
    self.eventDateLabel.textColor = RGB(51, 191, 217);
    self.eventDateLabel.font = [UIFont quattroCentoRegularFontWithSize:12.0];
    self.eventDateLabel.minimumScaleFactor = 0.9;
    self.eventDateLabel.adjustsFontSizeToFitWidth = YES;
    
    self.hostedByLabel.textColor = [UIColor whiteColor];
    self.hostedByLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    
    self.locationLabel.textColor = [UIColor yellowBoatDay];
    self.locationLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    
    self.eventDescriptionTitleLabel.textColor = [UIColor grayBoatDay];
    self.eventDescriptionTitleLabel.font = [UIFont quattoCentoItalicFontWithSize:14.0];
    
    self.eventDescriptionLabel.textColor = [UIColor grayBoatDay];
    self.eventDescriptionLabel.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    
}

- (void) setEventData {
    
    self.eventNameLabel.text = self.event.name;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter eventProfileDateFormatter];
    NSString *eventDate = [dateFormatter stringFromDate:self.event.startsAt];
    NSString *timeLeft = [self.event.endDate timeLeftSinceDate:self.event.startsAt];
    self.eventDateLabel.text = [NSString stringWithFormat:@"%@\nDuration: %@", eventDate, timeLeft];
    
    //set image placeholder
    self.userPlaceholderImageView.image = [UIImage imageNamed:@"boatPhotoCoverPlaceholder"];
    
    if (self.event.host.pictures.count) {
        
        // set this image enable to be opened with User Profile on tap
        UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hostPicturePressed)];
        [self.profileAccessView setUserInteractionEnabled:YES];
        [self.profileAccessView addGestureRecognizer:newTap];
        
        // the first picture is the one that is used in user profile (change this to the selected one)
        PFFile *file = self.event.host.pictures[[self.event.host.selectedPictureIndex integerValue]];
        
        // Get image from cache or from server if isnt available (background task)
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            self.userPictureImageView.image = image;
            
            [UIView setRoundedView:self.userPictureImageView
                        toDiameter:CGRectGetHeight(self.userPictureImageView.frame)];
            
            [UIView showViewAnimated:self.userPictureImageView
                           withAlpha:YES
                            duration:0.2
                            andDelay:0.0
                            andScale:NO];
            
            [UIView hideViewAnimated:self.userPlaceholderImageView
                           withAlpha:YES
                         andDuration:0.3];
            
        }];
        
    }
    
    self.ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_single_white"];
    self.ratingView.starImage = [UIImage imageNamed:@"rating_single_green"];
    self.ratingView.maxRating = 5.0;
    self.ratingView.horizontalMargin = 12;
    self.ratingView.editable = YES;
    self.ratingView.displayMode = EDStarRatingDisplayFull;
    self.ratingView.userInteractionEnabled = NO;
    
    [self getActivities];
    
    self.hostedByLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"eventCard.hostedBy", nil), [self.event.host shortName]];
    self.locationLabel.text = self.event.locationName;
    self.eventDescriptionTitleLabel.text = NSLocalizedString(@"eventProfile.emptyEventDescription", nil);
    self.eventDescriptionLabel.text = self.event.eventDescription;
    
}

- (void) getEventImage {
    
    //set image placeholder
    self.userPlaceholderImageView.image = [UIImage imageNamed:@"boatPhotoCoverPlaceholder"];
    
    // user image is "hidden" while is getting its data on background
    self.eventImageView.alpha = 0.0;
    
    if (self.event.boat.pictures.count) {
        
        // set this image enable to be opened with MHFacebookImageViewer on tap
        [self.eventImageView setupImageViewer];
        
        // the first picture is the one that is used in user profile (change this to the selected one)
        PFFile *file = self.event.boat.pictures[[self.event.boat.selectedPictureIndex integerValue]];
        
        // Get image from cache or from server if isnt available (background task)
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            self.eventImageView.image = image;
            
            // show imageView with nice effect
            [UIView showViewAnimated:self.eventImageView withAlpha:YES andDuration:0.3];
            
        }];
        
    }
    
}

#pragma mark - Bottom View Methods

- (void) setupBottomView {
    
    self.numberOfUsersAttending = 0;
    SeatRequest *userRequest = nil;
    
    // Check for user seats request
    for (SeatRequest *request in self.event.seatRequests) {
        
        if(![request isEqual:[NSNull null]]) {
            
            if ([request.user isEqual:[User currentUser]]) {
                userRequest = request;
                
                // cant be rejected
                if ([request.status integerValue] == SeatRequestStatusRejected) {
                    userRequest = nil;
                }
                
                // cant be an invite from the host
                if ([request.pendingInvite integerValue]) {
                    userRequest = nil;
                }
                
            }
            
            if ([request.status integerValue] == SeatRequestStatusAccepted) {
                self.numberOfUsersAttending += [request.numberOfSeats integerValue];
            }
        }
    }
    
    NSInteger availableSeats = self.event.availableSeats.integerValue - self.numberOfUsersAttending;
    
    if (!userRequest && self.event.freeSeats.integerValue == 0) {
        self.buttonBottomView.enabled = NO;
    }
    
    
    self.userRequest = userRequest;
    
    // if event already started
    if ([[NSDate date] compare:self.event.startsAt] == NSOrderedDescending ||
        [[NSDate date] compare:self.event.startsAt] == NSOrderedSame) {
        
        [self setupButtonViewEventStarted];
        
    } else {
        
        [self setupButtonViewEventDidntStart];
        
    }
    
}

- (void) setupButtonViewEventStarted {
    
    BOOL eventIsLive = [NSDate isDate:[NSDate date] inRangeFirstDate:self.event.startsAt lastDate:self.event.endDate];

    NSInteger hoursTimeframe = [Session sharedSession].finalizeContributionTimeframeWindowHours;
    
    NSDate *timeFrameDate = [self.event.endDate dateByAddingTimeInterval:hoursTimeframe*60*60];
    
    // if it's not done within X hours after the event then they will be automatically charged
    BOOL isInTimeframeHours = [NSDate isDate:[NSDate date] inRangeFirstDate:self.event.endDate lastDate:timeFrameDate];
    
    // if it is in the timeframe, user attend the event, user has not paid
    if (!eventIsLive &&
        isInTimeframeHours &&
        self.userRequest &&
        !self.userRequest.transactionId &&
        ![self.userRequest.userDidPayFromTheApp boolValue] &&
        [self.userRequest.status integerValue] == SeatRequestStatusAccepted) {
        
        // finalize contribution
        
        self.headerBottomViewLabel.backgroundColor = [UIColor clearColor];
        self.headerBottomViewLabel.font = [UIFont abelFontWithSize:12.0];
        self.headerBottomViewLabel.textColor = [UIColor whiteColor];
        
        self.headerBottomView.backgroundColor = [UIColor yellowBoatDay];
        self.headerBottomViewLabel.text = NSLocalizedString(@"eventProfile.confirmedGuest", nil);
        
        self.buttonBottomView.titleLabel.font = [UIFont abelFontWithSize:24.0];
        
        [self.buttonBottomView setTitle:NSLocalizedString(@"eventProfile.finalizeContribution", nil) forState:UIControlStateNormal];
        [self.buttonBottomView setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_off"] forState:UIControlStateNormal];
        [self.buttonBottomView setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_on"] forState:UIControlStateHighlighted];
        
        self.numberOfSeatsLabel.backgroundColor = [UIColor clearColor];
        self.numberOfSeatsLabel.textColor = [UIColor mediumGreenBoatDay];
        self.numberOfSeatsLabel.font = [UIFont abelFontWithSize:30.0];
        self.numberOfSeatsLabel.text = [self.userRequest.numberOfSeats stringValue];
        self.numberOfSeatsLabel.minimumScaleFactor = 0.3;
        self.numberOfSeatsLabel.adjustsFontSizeToFitWidth = YES;
        
        self.seatsLabel.backgroundColor = [UIColor clearColor];
        self.seatsLabel.textColor = [UIColor mediumGreenBoatDay];
        self.seatsLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
        self.seatsLabel.text = NSLocalizedString(@"eventProfile.seats", nil);
        
    } else {
        
        // hide bottomView
        self.headerBottomView.hidden = YES;
        self.bottomView.hidden = YES;
        
    }
    
}

- (void) setupButtonViewEventDidntStart {
    
    if (self.userRequest) { // attending
        
        self.headerBottomViewLabel.backgroundColor = [UIColor clearColor];
        self.headerBottomViewLabel.font = [UIFont abelFontWithSize:12.0];
        self.headerBottomViewLabel.textColor = [UIColor whiteColor];
        
        switch ([self.userRequest.status integerValue]) {
            case SeatRequestStatusAccepted:
                
                self.headerBottomView.backgroundColor = [UIColor yellowBoatDay];
                self.headerBottomViewLabel.text = NSLocalizedString(@"eventProfile.confirmedGuest", nil);
                
                break;
            case SeatRequestStatusPending:
                
                self.headerBottomView.backgroundColor = [UIColor greenBoatDay];
                self.headerBottomViewLabel.text = NSLocalizedString(@"eventProfile.pendingRequest", nil);
                
                break;
            default:
                break;
        }
        
        self.buttonBottomView.titleLabel.font = [UIFont abelFontWithSize:24.0];
        
        [self.buttonBottomView setTitle:NSLocalizedString(@"eventProfile.cancelSeats", nil) forState:UIControlStateNormal];
        [self.buttonBottomView setBackgroundImage:[UIImage imageNamed:@"button_lg_red_off"] forState:UIControlStateNormal];
        [self.buttonBottomView setBackgroundImage:[UIImage imageNamed:@"button_lg_red_on"] forState:UIControlStateHighlighted];
        
        self.numberOfSeatsLabel.backgroundColor = [UIColor clearColor];
        self.numberOfSeatsLabel.textColor = [UIColor mediumGreenBoatDay];
        self.numberOfSeatsLabel.font = [UIFont abelFontWithSize:30.0];
        self.numberOfSeatsLabel.text = [self.userRequest.numberOfSeats stringValue];
        
        self.seatsLabel.backgroundColor = [UIColor clearColor];
        self.seatsLabel.textColor = [UIColor mediumGreenBoatDay];
        self.seatsLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
        self.seatsLabel.text = NSLocalizedString(@"eventProfile.seats", nil);
        
    } else {
        
        // If is the event host
        if ([self.event.host isEqual:[User currentUser]]) {
            
            [self.buttonBottomView setTitle:NSLocalizedString(@"eventProfile.inviteUsers", nil) forState:UIControlStateNormal];
            
        } else { // not attending
            
            self.headerBottomViewLabel.backgroundColor = [UIColor clearColor];
            self.headerBottomViewLabel.font = [UIFont abelFontWithSize:12.0];
            self.headerBottomViewLabel.textColor = [UIColor whiteColor];
            
            self.headerBottomView.backgroundColor = [UIColor yellowBoatDay];
            self.headerBottomViewLabel.text = NSLocalizedString(@"eventProfile.confirmedGuest", nil);
            
            self.buttonBottomView.titleLabel.font = [UIFont abelFontWithSize:24.0];
            
            self.headerBottomViewLabel.attributedText = [self createSuggestedContributionAttStringWithPrice:self.event.price withColor:[UIColor whiteColor]];
            [self.buttonBottomView setTitle:NSLocalizedString(@"eventProfile.requestSeats", nil) forState:UIControlStateNormal];
            
        }
        
        self.buttonBottomView.titleLabel.font = [UIFont abelFontWithSize:24.0];
        [self.buttonBottomView setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_off"] forState:UIControlStateNormal];
        [self.buttonBottomView setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_on"] forState:UIControlStateHighlighted];
        
        self.numberOfSeatsLabel.backgroundColor = [UIColor clearColor];
        self.numberOfSeatsLabel.textColor = [UIColor mediumGreenBoatDay];
        self.numberOfSeatsLabel.font = [UIFont abelFontWithSize:30.0];
        self.numberOfSeatsLabel.text = [NSString stringWithFormat:@"%ld/%ld",
                                        self.event.freeSeats.integerValue,
                                        self.event.availableSeats.integerValue];
        
        self.seatsLabel.backgroundColor = [UIColor clearColor];
        self.seatsLabel.textColor = [UIColor mediumGreenBoatDay];
        self.seatsLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
        self.seatsLabel.text = NSLocalizedString(@"eventProfile.seats", nil);
        
    }
    
    self.numberOfSeatsLabel.minimumScaleFactor = 0.3;
    self.numberOfSeatsLabel.adjustsFontSizeToFitWidth = YES;
    
}

- (NSMutableAttributedString *)createSuggestedContributionAttStringWithPrice:(NSNumber *)price withColor:(UIColor*)color{
    
    NSString *suggestedContribution = NSLocalizedString(@"eventProfile.suggestedContribution", nil);
    
    NSString *coinSymbol = NSLocalizedString(@"coinSymbol", nil);
    
    NSString *priceString = [NSString stringWithFormat:@"%@%@", coinSymbol, price];
    
    NSString *string = [NSString stringWithFormat:@"%@ %@", suggestedContribution, priceString];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *suggestedContributionFont = [UIFont quattoCentoItalicFontWithSize:12.0];
    UIFont *priceFont = [UIFont quattoCentoBoldItalicFontWithSize:16.0];
    
    [attString beginEditing];
    [attString addAttribute:NSFontAttributeName value:suggestedContributionFont range:NSMakeRange(0, suggestedContribution.length - 1)];
    [attString addAttribute:NSFontAttributeName value:priceFont range:NSMakeRange(suggestedContribution.length+1, priceString.length)];
    
    [attString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, string.length )];
    
    [attString endEditing];
    
    return attString;
    
}

#pragma mark - Activities ScrollView

- (void) getActivities {
    
    NSMutableArray *activitiesTemp = [[NSMutableArray alloc] init];
    activitiesTemp = self.event.activities;
    
    self.activities = [[NSMutableArray alloc] init];
    
    [[Session sharedSession].allActivities enumerateObjectsUsingBlock:^(Activity *activity, NSUInteger idx, BOOL *stop) {
        
        if ([activitiesTemp containsObject:activity]) {
            [self.activities addObject:activity];
        }
        
    }];
    
    [self setupActivitiesScrollView];
    
}

- (void) setupActivitiesScrollView {
    
    [self.activitiesIndicator stopAnimating];
    self.activitiesIndicator.hidden = YES;
    
    CGFloat spaceBetween = 10.0;
    CGFloat xPosition = 10.0;
    CGFloat yPosition = 3.0;
    CGFloat buttonWidth = 45.0;
    
    UIButton *activityButton;
    UIImage *image;
    BOOL hasPermission;
    
    // Drink Permissions
    activityButton = [[UIButton alloc] init];
    activityButton.frame = CGRectMake(xPosition, yPosition, buttonWidth, buttonWidth);
    hasPermission = [self.event.alcoholPermitted boolValue];
    image = hasPermission ? [UIImage imageNamed:@"activity_parental_drinking_yes"] : [UIImage imageNamed:@"activity_parental_drinking_no"];
    [activityButton setImage:image forState:UIControlStateNormal];
    activityButton.userInteractionEnabled = NO;
    xPosition += (buttonWidth + spaceBetween);
    [self.activitiesScrollView addSubview:activityButton];
    
    // Smoking Permissions
    activityButton = [[UIButton alloc] init];
    activityButton.frame = CGRectMake(xPosition, yPosition, buttonWidth, buttonWidth);
    hasPermission = [self.event.smokingPermitted boolValue];
    image = hasPermission ? [UIImage imageNamed:@"activity_parental_smoking_yes"] : [UIImage imageNamed:@"activity_parental_smoking_no"];  [activityButton setImage:image forState:UIControlStateNormal];
    activityButton.userInteractionEnabled = NO;
    xPosition += (buttonWidth + spaceBetween);
    [self.activitiesScrollView addSubview:activityButton];
    
    // Children Permissions
    activityButton = [[UIButton alloc] init];
    activityButton.frame = CGRectMake(xPosition, yPosition, buttonWidth, buttonWidth);
    hasPermission = [self.event.childrenPermitted boolValue];
    image = hasPermission ? [UIImage imageNamed:@"activity_parental_children_yes"] : [UIImage imageNamed:@"activity_parental_children_no"];
    [activityButton setImage:image forState:UIControlStateNormal];
    activityButton.userInteractionEnabled = NO;
    xPosition += (buttonWidth + spaceBetween);
    [self.activitiesScrollView addSubview:activityButton];
    
    for (int i = 0; i < self.activities.count; i++) {
        
        Activity *activity = self.activities[i];
        
        UIButton *userButton = [[UIButton alloc] init];
        userButton.frame = CGRectMake(xPosition, yPosition, buttonWidth, buttonWidth);
        
        PFFile *theImage = activity.picture;
        
        // Get image from cache or from server if isnt available (background task)
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            [userButton setImage:image forState:UIControlStateNormal];
            userButton.userInteractionEnabled = NO;
            
        }];
        
        [self.activitiesScrollView addSubview:userButton];
        
        xPosition += (buttonWidth + spaceBetween);
        
    }
    
    CGFloat scrollContentWidth = xPosition;
    
    [self.activitiesScrollView setContentSize:CGSizeMake(scrollContentWidth, CGRectGetHeight(self.activitiesScrollView.frame))];
    self.activitiesScrollView.showsHorizontalScrollIndicator = NO;
    UITapGestureRecognizer *tapToAccessActivityDetail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToOpenActivityDetail)];
    [self.activitiesScrollView addGestureRecognizer:tapToAccessActivityDetail];
    
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect rect = HEADER_INIT_FRAME;
    
    // Here is where I do the "Zooming" image
    if (scrollView.contentOffset.y < 0.0f) {
        
        CGFloat delta = fabs(MIN(0.0f, self.mainScrollView.contentOffset.y));
        self.backgroundScrollView.frame = CGRectMake(CGRectGetMinX(rect) - delta / 2.0f, CGRectGetMinY(rect) - delta, CGRectGetWidth(rect) + delta, CGRectGetHeight(rect) + delta);
        
    } else {
        
        CGFloat offsetY = self.mainScrollView.contentOffset.y;
        
        // if y offset is lesse then top view height
        if (offsetY <= self.backgroundScrollView.frame.size.height) {
            
            // adjust scrollview offset and userframe sizes
            self.backgroundScrollView.frame = rect;
            self.eventInfoView.frame = (CGRect){.origin = {0, CGRectGetMinY(rect) + CGRectGetHeight(rect)}, .size = self.eventInfoView.frame.size };
            [self.backgroundScrollView setContentOffset:CGPointMake(0, -offsetY * kBackgroundParallexFactor)animated:NO];
            
        }
        
    }
    
}

#pragma mark - Action Methods

- (IBAction)pinLocationButtonPressed:(id)sender {
    
    BDGotoLocationViewController *gotoLocationViewController = [[BDGotoLocationViewController alloc] initWithEvent:self.event];
    [self.navigationController pushViewController:gotoLocationViewController animated:YES];
    
}

-(void)tapToOpenActivityDetail{

    BDEventActivitiesViewController *activitiesViewController = [[BDEventActivitiesViewController alloc] initWithEvent:self.event];
    [self.navigationController pushViewController:activitiesViewController animated:YES];
}

- (IBAction)activitiesButtonPressed:(id)sender {
    
    BDEventActivitiesViewController *activitiesViewController = [[BDEventActivitiesViewController alloc] initWithEvent:self.event];
    [self.navigationController pushViewController:activitiesViewController animated:YES];
    
}

- (void) hostPicturePressed {
    
    ProfileType type = [self.event.host isEqual:[User currentUser]] ? ProfileTypeSelf : ProfileTypeOther;
    
    BDProfileViewController *profileViewController = [[BDProfileViewController alloc] initWithUser:self.event.host andProfileType:type];
    [self.navigationController pushViewController:profileViewController animated:YES];
    
}

#pragma mark - Seat Requests Methods

- (IBAction)buttonBottomViewPressed:(id)sender {
    
    // If not logged
    if (![User currentUser]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notLoggedIn.alertview.title", nil)
                                                              message:NSLocalizedString(@"notLoggedIn.alertview.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    } else {
        
        // if event ended
        if ([[NSDate date] compare:self.event.endDate] == NSOrderedDescending ||
            [[NSDate date] compare:self.event.endDate] == NSOrderedSame) {
            
            // finalize contribution
            
            // Seat Request View
            BDFinalizeContributionViewController *finalizeContributionViewController = [[BDFinalizeContributionViewController alloc] initWithEvent:self.event andSeatRequest:self.userRequest];
            MMNavigationController *viewController = [[MMNavigationController alloc] initWithRootViewController:finalizeContributionViewController];
            [self.navigationController presentViewController:viewController animated:YES completion:nil];
            
        } else {
            
            if (self.userRequest) { // attending
                
                [self cancelSeatReservation];
                
                // Cancel request
                
            } else {
                
                // If is the event host
                if ([self.event.host isEqual:[User currentUser]]) {
                    
                    // Invite new users
                    BDFindUsersViewController *findUsersViewController = [[BDFindUsersViewController alloc] init];
                    [self.navigationController pushViewController:findUsersViewController animated:YES];
                    
                    
                } else { // not attending
                    
                    // Seat Request View
                    BDSeatRequestViewController *seatRequestViewController = [[BDSeatRequestViewController alloc] initWithEvent:self.event];
                    MMNavigationController *viewController = [[MMNavigationController alloc] initWithRootViewController:seatRequestViewController];
                    [self.navigationController presentViewController:viewController animated:YES completion:nil];
                    
                }
            }
            
        }
        
    }
    
}

- (void) cancelSeatReservation {
    
    NSInteger hoursAgo = [Session sharedSession].cancelRequestTimeframeWindowHours;
    
    NSDate *hoursAgoDate = [self.event.startsAt dateByAddingTimeInterval:-hoursAgo*60*60];
    
    // if a user cancels a seat within 24 hours of the BoatDay, we need to hit the API to charge them a fee
    BOOL isInTimeframeHours = [NSDate isDate:[NSDate date] inRangeFirstDate:hoursAgoDate lastDate:self.event.startsAt];
    
    if (isInTimeframeHours) {
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"eventProfile.cancelRequest.title", nil)
                                    message:NSLocalizedString(@"eventProfile.cancelRequest.message", nil)
                           cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.noButton", nil) action:nil]
                           otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.yesButton", nil) action:^{
            
            if (![NSString isStringEmpty:[User currentUser].braintreePaymentToken] &&
                ![NSString isStringEmpty:self.event.host.hostRegistration.merchantId]) {
                
                [[BDPaymentServiceManager sharedManager] chargeCancellationFeeWithRequestID:self.userRequest.objectId
                                                                               sessionToken:[User currentUser].sessionToken
                                                                               paymentToken:[User currentUser].braintreePaymentToken
                                                                                 merchantID:self.event.host.hostRegistration.merchantId
                                                                                  withBlock:nil];
                
            }
            
            [self cancelSeatReservationOnParse];
            
        }], nil] show];
    }
    else {
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"eventProfile.seatRequest.deleteTitle", nil)
                                    message:NSLocalizedString(@"eventProfile.seatRequest.deleteMessage", nil)
                           cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.noButton", nil) action:nil]
                           otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.yesButton", nil) action:^{
            
            // Handle "Delete"
            [self cancelSeatReservationOnParse];
            
        }], nil] show];
        
    }
    
}

- (void) cancelSeatReservationOnParse {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    self.userRequest.status = @(SeatRequestStatusRejected);
    
    NSMutableArray *objectsToSave = [[NSMutableArray alloc] init];
    
    [objectsToSave addObject:self.userRequest];
    
    // Notification to the host of the event
    
    Notification *notification = [Notification object];
    notification.user = self.event.host;
    notification.event = self.event;
    notification.seatRequest = self.userRequest;
    notification.read = @(NO);
    notification.notificationType = @(NotificationTypeSeatRequestCanceledByUser);
    notification.text = [NSString stringWithFormat:NSLocalizedString(@"eventProfile.cancelationNotification", nil), self.userRequest.user.fullName, self.event.name];
    notification.deleted = @(NO);
    [objectsToSave addObject:notification];
    
    // Notification to all the users that are attending to event
    for (SeatRequest *seatRequest in self.event.seatRequests) {
        
        if ([seatRequest.status integerValue] == SeatRequestStatusAccepted) {
            
            if (![seatRequest.user isEqual:[User currentUser]]) {
                
                Notification *notification = [Notification object];
                notification.user = seatRequest.user;
                notification.event = self.event;
                notification.seatRequest = self.userRequest;
                notification.read = @(NO);
                notification.notificationType = @(NotificationTypeSeatRequestCanceledByUser);
                notification.text = [NSString stringWithFormat:NSLocalizedString(@"eventProfile.cancelationNotification", nil), self.userRequest.user.fullName, self.event.name];
                notification.deleted = @(NO);
                [objectsToSave addObject:notification];
                
            }
            
        }
        
    }
    
    [PFObject saveAllInBackground:objectsToSave block:^(BOOL succeeded, NSError *error) {
        
        [self setupView];
        
        [SVProgressHUD dismiss];
        
    }];
    
}

@end
