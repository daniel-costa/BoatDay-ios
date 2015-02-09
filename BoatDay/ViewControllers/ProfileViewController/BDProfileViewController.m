//
//  BDProfileViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 30/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDProfileViewController.h"

#import "BDReviewsListViewController.h"
#import "BDReportUserViewController.h"
#import "BDUserCertificationsViewController.h"
#import "BDInviteUserViewController.h"
#import "BDEditProfileViewController.h"

#import "UIImage+Resize.h"
#import "MHFacebookImageViewer.h"
#import "EDStarRating.h"
#import "UIAlertView+Blocks.h"

#define HEADER_HEIGHT 194.0f
#define HEADER_INIT_FRAME CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)
#define USER_INFO_HEADER_HEIGHT 50.0f
#define USER_INFO_HEADER_BIGGER_HEIGHT 60.0f
#define IMAGE_AND_NAME_OFFSET 50.0f

#define kBackgroundParallexFactor 0.5f
#define kCertificateButtonInitialY 10.0f

@interface BDProfileViewController () <UIScrollViewDelegate,MHFacebookImageViewerDatasource>

@property (nonatomic) ProfileType profileType;

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) SeatRequest *seatRequest;
@property (nonatomic) BOOL reviewsFetched;

@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) NSMutableArray *activities;

@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) UIImageView *userPlaceholderImageView;
@property (strong, nonatomic) UIButton *certificationsButton;

// Parallax

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) UIScrollView *backgroundScrollView;

// Bottom View
@property (strong, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet UIView *bottomHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userLittleImageView;
@property (weak, nonatomic) IBOutlet UIView *imageAndNameView;
@property (weak, nonatomic) IBOutlet UILabel *lastActiveLabel;
@property (weak, nonatomic) IBOutlet UIView *starAndEventsView;
@property (weak, nonatomic) IBOutlet UIButton *reviewsButton;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *commonFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *commonActivitiesLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIView *commonFriendsView;
@property (weak, nonatomic) IBOutlet UILabel *noActivitiesLabel;
@property (weak, nonatomic) IBOutlet UIView *commonActivitiesView;
@property (weak, nonatomic) IBOutlet UIView *viewBelowAbout;
@property (weak, nonatomic) IBOutlet UILabel *aboutMeLabel;
@property (weak, nonatomic) IBOutlet UILabel *noFriendsLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *commonFriendsScrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *friendsActivityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *activitiesScrollView;

@property (strong, nonatomic) EDStarRating *starRating;

// Seat Request
@property (strong, nonatomic) IBOutlet UIView *seatRequestResponseView;
@property (weak, nonatomic) IBOutlet UIView *seatRequestQuestionView;
@property (weak, nonatomic) IBOutlet UILabel *seatRequestTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *seatRequestRejectButton;
@property (weak, nonatomic) IBOutlet UIButton *seatRequestAcceptButton;
@property (weak, nonatomic) IBOutlet UIButton *seatRequestRemoveButton;
@property (weak, nonatomic) IBOutlet UILabel *seatRequestMessageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatRequestMessageTextLabel;

@property (strong, nonatomic) UIAlertView *rejectionAlertView;
@property (strong, nonatomic) NSArray *reviews;


- (IBAction)seatRequestRejectButtonPressed:(id)sender;
- (IBAction)seatRequestAcceptButtonPressed:(id)sender;
- (IBAction)seatRequestRemoveButtonPressed:(id)sender;

- (IBAction)reviewsButtonPressed:(id)sender;
- (IBAction)inviteButtonPressed:(id)sender;

@end

@implementation BDProfileViewController

// init this view with diferent profile types (self  and other)
- (instancetype)initWithUser:(User *)user andProfileType:(ProfileType)profileType {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _user = user;
    _profileType = profileType;
    
    return self;
    
}

- (instancetype)initWithSeatRequest:(SeatRequest*)seatRequest {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _user = seatRequest.user;
    _profileType = ProfileTypeOther;
    _seatRequest = seatRequest;
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"profile.title", nil);
    self.screenName =@"BDProfileViewController";

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedInNotification:)
                                                 name:@"loginFailed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedInNotification:)
                                                 name:@"userLoggedIn"
                                               object:nil];
    
    // I know that this line above is kinda stupid but:
    // when I come from Edit Profile, the picture is not updating
    // cause: self.user is taking a while to be updated
    // what I do here is a trick, I check the objectID (isEqual override), and assign the user again
    if ([self.user isEqual:[User currentUser]]) {
        self.user = [User currentUser];
    }
    
    if (![[Session sharedSession] dataWasFechted] && [self.user isEqual:[User currentUser]]) {
        
        [self addActivityViewforView:self.contentView];
        
        [[Session sharedSession] getUserRelationshipsData];
        
    }
    else {
        [self setupProfileView];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
    
}

#pragma mark - Setup Methods

- (void) setupProfileView {
    
    [self setupView];
    
    [self getUserImage];
    
    [self getFriends];
    
    [self getActivities];
    
    [self getReviews];
    
}

- (void) setupNavigationBar {
    
    if ([User currentUser]) {
        
        if ([self.user isEqual:[User currentUser]]) {
            
            UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
            editButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
            [editButton setImage:[UIImage imageNamed:@"ico-Edit"] forState:UIControlStateNormal];
            [editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        } else {
            
            UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
            reportButton.frame = CGRectMake(0, 0, 30.0, 30.0);
            [reportButton setImage:[UIImage imageNamed:@"ico-Flag"] forState:UIControlStateNormal];
            [reportButton addTarget:self action:@selector(reportButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *reportButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reportButton];
            self.navigationItem.rightBarButtonItem = reportButtonItem;
            
        }
        
    }
    
}

// setup view
- (void) setupView {
    
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
    self.userImageView = [[UIImageView alloc] initWithFrame:HEADER_INIT_FRAME];
    self.userImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImageView.backgroundColor = [UIColor clearColor];
    
    // user imaga placeholder
    self.userPlaceholderImageView = [[UIImageView alloc] initWithFrame:HEADER_INIT_FRAME];
    self.userPlaceholderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.userPlaceholderImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    // certification List button
    self.certificationsButton = [[UIButton alloc] initWithFrame:CGRectMake(kCertificateButtonInitialY, kCertificateButtonInitialY, 35.0*1.5, 30.0*1.5)];
    self.certificationsButton.hidden = YES;
    
    [self.backgroundScrollView addSubview:self.userPlaceholderImageView];
    [self.backgroundScrollView addSubview:self.userImageView];
    
    // set infoView under userImageView
    setFrameY(self.userInfoView, CGRectGetMaxY(self.userImageView.frame));
    
    [self.mainScrollView addSubview:self.backgroundScrollView];
    [self.mainScrollView addSubview:self.userInfoView];
    
    //certificationsButton is on mainScrollView so we can have all the control on his position (so that we can change on scroll)
    [self.mainScrollView addSubview:self.certificationsButton];
    
    if ([self.user.objectId isEqualToString:[User currentUser].objectId]) {
        self.commonFriendsLabel.text = NSLocalizedString(@"profile.friendsWithBoatDay", nil);
        self.commonActivitiesLabel.text = NSLocalizedString(@"profile.myFavoriteActivities", nil);
        self.commonActivitiesView.hidden = true;
    }
    else {
        self.commonFriendsLabel.text = NSLocalizedString(@"profile.commonFriends", nil);
        self.commonActivitiesLabel.text = NSLocalizedString(@"profile.commonActivities", nil);
    }
    
    self.nameLabel.font = [UIFont quattroCentoRegularFontWithSize:21.0];
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.lastActiveLabel.font = [UIFont quattroCentoRegularFontWithSize:11.0];
    self.lastActiveLabel.textColor = [UIColor whiteColor];
    
    self.locationLabel.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.locationLabel.textColor = [UIColor yellowBoatDay];
    
    self.reviewsButton.titleLabel.font = [UIFont abelFontWithSize:21.0];
    [self.reviewsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.reviewsButton setTitleColor:[UIColor yellowBoatDay] forState:UIControlStateHighlighted];
    
    self.starRating = [[EDStarRating alloc] initWithFrame:CGRectMake(10.0, 18.0, 140.0, 21.0)];
    self.starRating.backgroundColor = [UIColor clearColor];
    self.starRating.starHighlightedImage = [UIImage imageNamed:@"starProfile_white"];
    self.starRating.starImage = [UIImage imageNamed:@"starProfile_yellow"];
    self.starRating.maxRating = 5.0;
    self.starRating.horizontalMargin = 2;
    self.starRating.editable = NO;
    self.starRating.displayMode=EDStarRatingDisplayFull;
    self.starRating.userInteractionEnabled = NO;
    self.starRating.rating = 0;
   
    
    self.aboutLabel.font = [UIFont abelFontWithSize:14.0];
    self.aboutLabel.textColor = [UIColor grayBoatDay];
    
    self.aboutMeLabel.font = [UIFont abelFontWithSize:14.0];
    self.aboutMeLabel.textColor = [UIColor grayBoatDay];
    
    self.commonFriendsLabel.font = [UIFont abelFontWithSize:14.0];
    self.commonFriendsLabel.textColor = [UIColor grayBoatDay];
    
    self.commonActivitiesLabel.font = [UIFont abelFontWithSize:14.0];
    self.commonActivitiesLabel.textColor = [UIColor whiteColor];
    
    if([User currentUser].hasEventsGoingOn) {
        self.inviteButton.titleLabel.font = [UIFont abelFontWithSize:14.0];
        [self.inviteButton setTitle:NSLocalizedString(@"profile.inviteButton", nil) forState:UIControlStateNormal];
        
        self.inviteButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
        [self.inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.inviteButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_off"] forState:UIControlStateNormal];
        [self.inviteButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_on"] forState:UIControlStateHighlighted];
    } else {
        self.inviteButton.hidden = true;
        self.viewBelowAbout.frame = CGRectMake(self.viewBelowAbout.frame.origin.x,
                                               self.viewBelowAbout.frame.origin.y,
                                               self.viewBelowAbout.frame.size.width,
                                               180);
    }
    
    if (self.seatRequest && !([[NSDate date] compare:self.seatRequest.event.startsAt] == NSOrderedDescending)) {
        [self setupSeatRequestView];
    }
    
}

- (void) getUserImage {
    
    //set image placeholder
    self.userPlaceholderImageView.image = [UIImage imageNamed:@"userPhotoCoverPlaceholder"];
    
    // user image is "hidden" while is getting its data on background
    self.userImageView.alpha = 0.0;
    
    if (self.user.pictures.count && [self.user.selectedPictureIndex integerValue] >= 0) {
        
        // set this image enable to be opened with MHFacebookImageViewer on tap

        [self.userImageView setupImageViewerWithDatasource:self initialIndex:[self.user.selectedPictureIndex integerValue] onOpen:nil onClose:nil];
        // the first picture is the one that is used in user profile (change this to the selected one)
        
        PFFile *file = self.user.pictures[[self.user.selectedPictureIndex integerValue]];
        
        // Get image from cache or from server if isnt available (background task)
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            self.userImageView.image = image;
            self.userLittleImageView.image = image;
            self.userLittleImageView.layer.cornerRadius = self.userLittleImageView.frame.size.height / 2.0;
            self.userLittleImageView.clipsToBounds = YES;
            
            // show imageView with nice effect
            [UIView showViewAnimated:self.userImageView withAlpha:YES andDuration:0.5];
            
        }];
        
    }
    
}
- (NSInteger) numberImagesForImageViewer:(MHFacebookImageViewer*) imageViewer{
    return self.user.pictures.count;
}

- (NSURL*) imageURLAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer{
    PFFile *file =self.user.pictures[index];
    return [NSURL URLWithString:[file url]];
}
- (UIImage*) imageDefaultAtIndex:(NSInteger)index imageViewer:(MHFacebookImageViewer*) imageViewer{
//    PFFile *file =self.user.pictures[index];
    
    return nil;
}
- (void) updateUserData {
    
    // setup navigation bar buttons
    [self setupNavigationBar];
    
    // update user information
    
    // name example: "Diogo N."
    self.nameLabel.text = self.user.shortName;
    
    self.locationLabel.text = [self.user fullLocation];
    
    // If this is the current user profile, he is always "Active Now"
    if ([self.user isEqual:[User currentUser]]) {

        // if current user, is active now!
        self.lastActiveLabel.text = NSLocalizedString(@"addReview.activeNow", nil);
        
        // hide button if is the current user and resize the view
        self.inviteButton.hidden = YES;
        setFrameHeight(self.viewBelowAbout, CGRectGetMaxY(self.commonActivitiesView.frame));
        
    }
    else {
        
        self.lastActiveLabel.text = [NSString stringWithFormat:@"Last Active: %@", @"MISSING DATE"];
        
    }
    
    self.lastActiveLabel.hidden = YES;
    
    // Active Events are the ones user is the host or is attending
    NSInteger averageReviewsStars = [[Session sharedSession] averageReviewsStarsWithReviews:self.reviews];
    
    self.starRating.rating = averageReviewsStars;
    if (self.reviews.count < 1) {
        
        if(self.reviewsButton.frame.size.height == 60) {
            self.aboutLabel.frame = CGRectMake(self.aboutLabel.frame.origin.x,
                                               self.aboutLabel.frame.origin.y - 38,
                                               self.aboutLabel.frame.size.width,
                                               self.aboutLabel.frame.size.height);
            
            self.aboutMeLabel.frame = CGRectMake(self.aboutMeLabel.frame.origin.x,
                                                 self.aboutMeLabel.frame.origin.y - 38,
                                                 self.aboutMeLabel.frame.size.width,
                                                 self.aboutMeLabel.frame.size.height);
            
            self.viewBelowAbout.frame = CGRectMake(self.viewBelowAbout.frame.origin.x,
                                                   self.viewBelowAbout.frame.origin.y - 38,
                                                   self.viewBelowAbout.frame.size.width,
                                                   self.viewBelowAbout.frame.size.height);
            
            self.starAndEventsView.frame = CGRectMake(self.starAndEventsView.frame.origin.x,
                                                      self.starAndEventsView.frame.origin.y,
                                                      self.starAndEventsView.frame.size.width,
                                                      22);
            
            self.reviewsButton.frame = CGRectMake(self.reviewsButton.frame.origin.x,
                                                  self.reviewsButton.frame.origin.y,
                                                  self.reviewsButton.frame.size.width,
                                                  22);
        }
        
        self.reviewsButton.titleLabel.font =[UIFont abelFontWithSize:12];
//        self.reviewsButton.enabled = false;
        [self.reviewsButton setTitle:[NSString stringWithFormat:@"NO %@", NSLocalizedString(@"profile.reviews", nil)] forState:UIControlStateNormal];
        self.reviewsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
//        self.reviewsButton.center = CGPointMake(self.view.center.x, self.reviewsButton.center.y);
    } else {
        
        if(self.reviewsButton.frame.size.height <= 60) {
            self.aboutLabel.frame = CGRectMake(self.aboutLabel.frame.origin.x,
                                               self.aboutLabel.frame.origin.y + 38,
                                               self.aboutLabel.frame.size.width,
                                               self.aboutLabel.frame.size.height);
            
            self.aboutMeLabel.frame = CGRectMake(self.aboutMeLabel.frame.origin.x,
                                                 self.aboutMeLabel.frame.origin.y + 38,
                                                 self.aboutMeLabel.frame.size.width,
                                                 self.aboutMeLabel.frame.size.height);
            
            self.viewBelowAbout.frame = CGRectMake(self.viewBelowAbout.frame.origin.x,
                                                   self.viewBelowAbout.frame.origin.y + 38,
                                                   self.viewBelowAbout.frame.size.width,
                                                   self.viewBelowAbout.frame.size.height);
            
            self.starAndEventsView.frame = CGRectMake(self.starAndEventsView.frame.origin.x,
                                                      self.starAndEventsView.frame.origin.y,
                                                      self.starAndEventsView.frame.size.width,
                                                      60);
            
            self.reviewsButton.frame = CGRectMake(self.reviewsButton.frame.origin.x,
                                                  self.reviewsButton.frame.origin.y,
                                                  self.reviewsButton.frame.size.width,
                                                  60);
        }
        
        [self.reviewsButton addSubview:self.starRating];
        self.reviewsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

        self.reviewsButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0, 10.0);
        [self.reviewsButton setTitle:[NSString stringWithFormat:@"%lu %@",
                                      (unsigned long)self.reviews.count,
                                      NSLocalizedString(@"profile.reviews", nil)]
                            forState:UIControlStateNormal];
    }
    
    
    self.aboutLabel.text = [[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"profile.about", nil), self.user.firstName] uppercaseString];
    
    if ([self.user.objectId isEqualToString:[User currentUser].objectId]) {
        self.aboutMeLabel.text = self.user.aboutMe ?:  NSLocalizedString(@"profile.noAboutTextSelf", nil);
    }
    else {
        // Other
        self.aboutMeLabel.text = self.user.aboutMe ?:  NSLocalizedString(@"profile.noAboutText", nil);
    }
    
    self.aboutMeLabel.numberOfLines = 0;
    self.aboutMeLabel.backgroundColor = [UIColor clearColor];

    setFrameHeight(self.aboutMeLabel, 350);
    setFrameWidth(self.aboutMeLabel, 280);
    
    [self.aboutMeLabel sizeToFit];
    
    // Adjust the y position of the view under aboutMe. And change the height of mainScrollView contentsize to fit the adjustments
    setFrameY(self.viewBelowAbout, CGRectGetMaxY(self.aboutMeLabel.frame) + 5.0);
    setFrameHeight(self.userInfoView, CGRectGetMaxY(self.viewBelowAbout.frame));
    
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.contentView.frame),
                                                 CGRectGetHeight(self.backgroundScrollView.frame) + CGRectGetHeight(self.userInfoView.frame));
    if (![User currentUser]) {
        self.inviteButton.enabled = NO;
    }
    
}

#pragma mark - Seat Request Response Methods

- (void) setupSeatRequestView {
    
    self.seatRequestTitleLabel.font = [UIFont abelFontWithSize:14.0];
    self.seatRequestTitleLabel.textColor = [UIColor whiteColor];
    
    self.seatRequestMessageTitleLabel.font = [UIFont abelFontWithSize:14.0];
    self.seatRequestMessageTitleLabel.textColor = [UIColor whiteColor];
    
    self.seatRequestMessageTextLabel.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.seatRequestMessageTextLabel.textColor = [UIColor whiteColor];
    
    switch ([self.seatRequest.status integerValue]) {
        case SeatRequestStatusAccepted:
            [self setRequestSetupAcceptedState];
            break;
        case SeatRequestStatusPending:
        {
            if ([self.seatRequest.pendingInvite boolValue]) {
                [self setRequestSetupPendingInvitationState];
            }
            else {
                [self setRequestSetupPendingState];
            }
            
        }
            break;
        case SeatRequestStatusRejected:
            return;
            break;
        default:
            break;
    }
    
    [self addSeatRequestView];
    
}

- (void) addSeatRequestView {
    
    setFrameY(self.seatRequestResponseView, 0.0);
    
    setFrameY(self.mainScrollView, CGRectGetMaxY(self.seatRequestResponseView.frame));
    
    setFrameHeight(self.mainScrollView, CGRectGetHeight(self.contentView.frame) - CGRectGetMaxY(self.seatRequestResponseView.frame));
    
    [self.contentView addSubview:self.seatRequestResponseView];
    
}

- (void) setRequestSetupPendingInvitationState {
    
    // remove invitation
    self.seatRequestAcceptButton.hidden = YES;
    self.seatRequestRejectButton.hidden = YES;
    self.seatRequestMessageTextLabel.hidden = YES;
    self.seatRequestMessageTitleLabel.hidden = YES;
    
    self.seatRequestRemoveButton.hidden = NO;
    
    self.seatRequestTitleLabel.text = NSLocalizedString(@"userProfile.seatRequest.removeInvitation", nil);
    
    self.seatRequestRemoveButton.titleLabel.font = [UIFont abelFontWithSize:14.0];
    
    [self.seatRequestRemoveButton setTitle:NSLocalizedString(@"userProfile.seatRequest.remove", nil) forState:UIControlStateNormal];
    
    setFrameHeight(self.seatRequestResponseView, CGRectGetMaxY(self.seatRequestQuestionView.frame));
    
}

- (void) setRequestSetupAcceptedState {
    
    // remove user
    self.seatRequestAcceptButton.hidden = YES;
    self.seatRequestRejectButton.hidden = YES;
    self.seatRequestMessageTextLabel.hidden = YES;
    self.seatRequestMessageTitleLabel.hidden = YES;
    
    self.seatRequestRemoveButton.hidden = NO;
    
    self.seatRequestTitleLabel.text = NSLocalizedString(@"userProfile.seatRequest.removeUser", nil);
    
    self.seatRequestRemoveButton.titleLabel.font = [UIFont abelFontWithSize:14.0];
    
    [self.seatRequestRemoveButton setTitle:NSLocalizedString(@"userProfile.seatRequest.remove", nil) forState:UIControlStateNormal];
    
    setFrameHeight(self.seatRequestResponseView, CGRectGetMaxY(self.seatRequestQuestionView.frame));
    
}

- (void) setRequestSetupPendingState {
    
    self.seatRequestAcceptButton.hidden = NO;
    self.seatRequestRejectButton.hidden = NO;
    self.seatRequestRemoveButton.hidden = YES;
    
    if ([self.seatRequest.numberOfSeats integerValue] == 1) {
        self.seatRequestTitleLabel.text = NSLocalizedString(@"userProfile.seatRequest.pedingRequests.single", nil);
    }
    else {
        self.seatRequestTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"userProfile.seatRequest.pedingRequests.multiple", nil), self.seatRequest.numberOfSeats];
    }
    
    if ([NSString isStringEmpty:self.seatRequest.message]) {
        
        self.seatRequestMessageTextLabel.hidden = YES;
        self.seatRequestMessageTitleLabel.hidden = YES;
        
        setFrameHeight(self.seatRequestResponseView, CGRectGetMaxY(self.seatRequestQuestionView.frame));
        
    }
    else {
        
        self.seatRequestMessageTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"userProfile.seatRequest.titleMessage", nil), [self.seatRequest.user.firstName uppercaseString]];
        
        self.seatRequestMessageTextLabel.text = self.seatRequest.message;
        
        [self.seatRequestMessageTextLabel sizeToFit];
        
        setFrameHeight(self.seatRequestResponseView, CGRectGetMaxY(self.seatRequestMessageTextLabel.frame) + 5.0);
        
    }
    
}

#pragma mark - Get Data Information Methods

- (void) getReviews {
    
    [self addActivityViewforView:self.contentView];
    
    PFQuery *query = [Review query];
    [query includeKey:@"from"];
    [query includeKey:@"to"];
    [query whereKey:@"to" equalTo:self.user];
    [query whereKey:@"deleted" notEqualTo:@(YES)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            self.reviews = objects ?: [[NSArray alloc] init];
            self.reviewsFetched = YES;
            
            [self updateUserData];
        }
        else {
            [self addNoConnectionView];
        }
        
        [self removeActivityViewFromView:self.contentView];
        
    }];

}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect rect = HEADER_INIT_FRAME;
    
    // Here is where I do the "Zooming" image
    if (scrollView.contentOffset.y < 0.0f) {
        
        CGFloat delta = fabs(MIN(0.0f, self.mainScrollView.contentOffset.y));
        self.backgroundScrollView.frame = CGRectMake(CGRectGetMinX(rect) - delta / 2.0f, CGRectGetMinY(rect) - delta, CGRectGetWidth(rect) + delta, CGRectGetHeight(rect) + delta);
        
        // little fancy move to the certification button (visual effect)
        setFrameY(self.certificationsButton, kCertificateButtonInitialY + (scrollView.contentOffset.y * 0.98));
        
        self.certificationsButton.alpha = 1.0;
        
    } else {
        
        CGFloat offsetY = self.mainScrollView.contentOffset.y;
        
        // if y offset is lesse then top view height
        if (offsetY <= self.backgroundScrollView.frame.size.height) {
            
            self.userLittleImageView.alpha = 0.0;
            
            setFrameY(self.bottomHeaderView, 0.0);
            setFrameHeight(self.bottomHeaderView, USER_INFO_HEADER_HEIGHT);
            
            // Certification Button adjustments (visual effects)
            CGFloat certificationSpaceHeight = kCertificateButtonInitialY * 2.0 + CGRectGetHeight(self.certificationsButton.frame);
            CGFloat maximumCertificatesButtonY = CGRectGetHeight(self.backgroundScrollView.frame) - certificationSpaceHeight;
            
            if (offsetY < maximumCertificatesButtonY) {
                
                // set imageAndNameView view to default position (outside the screen)
                setFrameX(self.imageAndNameView, - IMAGE_AND_NAME_OFFSET);
                
                // set change certificationsButton position on scroll
                setFrameY(self.certificationsButton, kCertificateButtonInitialY + offsetY*0.98);
                self.certificationsButton.alpha = 1.0;
                
            }
            else {
                
                CGFloat percent = MIN(1 , (offsetY - maximumCertificatesButtonY) / certificationSpaceHeight);
                
                // animate position of imageAndNameView to show the image
                self.userLittleImageView.alpha = percent;
                setFrameX(self.imageAndNameView, - (IMAGE_AND_NAME_OFFSET * (1 - percent)));
                
                self.certificationsButton.alpha = 1 - percent;
                
            }
            
            // adjust scrollview offset and userframe sizes
            self.backgroundScrollView.frame = rect;
            self.userInfoView.frame = (CGRect){.origin = {0, CGRectGetMinY(rect) + CGRectGetHeight(rect)}, .size = self.userInfoView.frame.size };
            [self.backgroundScrollView setContentOffset:CGPointMake(0, -offsetY * kBackgroundParallexFactor)animated:NO];
            
        }
        else {
            
            setFrameX(self.imageAndNameView, 0.0);
            
            self.userLittleImageView.alpha = 1.0;
            
            CGFloat offsetY = HEADER_HEIGHT - self.mainScrollView.contentOffset.y;
            offsetY *= -1;
            
            setFrameY(self.bottomHeaderView, offsetY);
            
            if (offsetY < USER_INFO_HEADER_BIGGER_HEIGHT - USER_INFO_HEADER_HEIGHT) {
                setFrameHeight(self.bottomHeaderView, USER_INFO_HEADER_HEIGHT + offsetY);
            }
            else {
                
                if (offsetY > USER_INFO_HEADER_BIGGER_HEIGHT - USER_INFO_HEADER_HEIGHT) {
                    setFrameHeight(self.bottomHeaderView, USER_INFO_HEADER_BIGGER_HEIGHT);
                }
                
            }
            
        }
    }
}

#pragma mark - Seat Request Response Action Methods

- (void) setSeatRequestStatus:(SeatRequestStatus)status {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    if (status == SeatRequestStatusAccepted) {
        
        self.seatRequest.pendingInvite = @(NO);
        [self acceptSeatRequest];
        
    } else {
        
        if ([self.seatRequest.pendingInvite boolValue]) {
        
            [self rejectSeatRequest];

        }
        else {
            
            self.rejectionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"profile.seatRequest.rejectAlert.title", nil)
                                                                 message:NSLocalizedString(@"profile.seatRequest.rejectAlert.message", nil)
                                                        cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"errorMessages.ok", nil) action:^{
                
                [self rejectSeatRequest];
                
            }]
                                                        otherButtonItems:nil];
            
            self.rejectionAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [[self.rejectionAlertView textFieldAtIndex:0] setPlaceholder:NSLocalizedString(@"addEditEvent.deleteAlert.messageHere", nil)];
            
            [self.rejectionAlertView show];
            
        }

        
    }
    
    
}


- (IBAction)seatRequestRejectButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"seatRequestRejectButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    

    [self setSeatRequestStatus:SeatRequestStatusRejected];
    
}

- (IBAction)seatRequestAcceptButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"seatRequestAcceptButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    [self setSeatRequestStatus:SeatRequestStatusAccepted];
    
}

- (IBAction)seatRequestRemoveButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"seatRequestRemoveButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    [self setSeatRequestStatus:SeatRequestStatusRejected];
    
}

#pragma mark - Accept/Reject Seat Request Parse Methods

- (void) acceptSeatRequest {
    
    PFQuery *query = [SeatRequest query];
    [query includeKey:@"event"];
    [query whereKey:@"event" equalTo:self.seatRequest.event];
    [query whereKey:@"status" equalTo:@(SeatRequestStatusAccepted)];
    [query whereKey:@"deleted" notEqualTo:@(YES)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSInteger numberOfUsersAttending = 0;
        
        // Check for user seats request
        for (SeatRequest *request in objects) {
            
            if(![request isEqual:[NSNull null]]) {
                if ([request.status integerValue] == SeatRequestStatusAccepted) {
                    numberOfUsersAttending += [request.numberOfSeats integerValue];
                }
            }
            
        }
        
        
        if (self.seatRequest.event.freeSeats.integerValue >= self.seatRequest.numberOfSeats.integerValue) {
            
            Notification *notification = [Notification object];
            notification.user = self.user;
            notification.event  = self.seatRequest.event;
            notification.read  = @(NO);
            notification.seatRequest = self.seatRequest;
            notification.text = NSLocalizedString(@"notifications.type.seatRequestApproved", nil);
            notification.notificationType = @(NotificationTypeRequestApproved);
            notification.deleted = @(NO);
            
            self.seatRequest.status = @(SeatRequestStatusAccepted);
            self.seatRequest.event.freeSeats = @(self.seatRequest.event.freeSeats.integerValue - self.seatRequest.numberOfSeats.integerValue);
            [PFObject saveAllInBackground:@[self.seatRequest, notification] block:^(BOOL succeeded, NSError *error) {
                
                [SVProgressHUD dismiss];
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            
        }
        else {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"profile.seatRequest.noSeats.title", nil)
                                                                  message:NSLocalizedString(@"profile.seatRequest.noSeats.message", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            [SVProgressHUD dismiss];
            return;
        }
        
    }];
    
}

- (void) rejectSeatRequest {
    
    NSString *rejectionMessage = [[self.rejectionAlertView textFieldAtIndex:0] text];
    
    Notification *notification = [Notification object];
    notification.user = self.user;
    notification.event  = self.seatRequest.event;
    notification.seatRequest  = self.seatRequest;
    notification.read  = @(NO);
    notification.deleted = @(NO);
    
    self.seatRequest.status = @(SeatRequestStatusRejected);

    if ([self.seatRequest.pendingInvite boolValue]) {
        
        //remove invitation
        self.seatRequest.pendingInvite = @(NO);
        notification.text = NSLocalizedString(@"notifications.type.invitationRemoved", nil);
        notification.notificationType = @(NotificationTypeEventInvitationRemoved);

        [PFObject saveAllInBackground:@[self.seatRequest, notification] block:^(BOOL succeeded, NSError *error) {
            
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
    }
    else {
        
        self.seatRequest.event.freeSeats = @(self.seatRequest.event.freeSeats.integerValue + self.seatRequest.numberOfSeats.integerValue);
        
        // seat request cancelation
        notification.text = [NSString stringWithFormat: NSLocalizedString(@"notifications.type.seatRequestRejected", nil), self.seatRequest.event.name];
        notification.notificationType = @(NotificationTypeRequestRejected);

        AdminMessage *message = [AdminMessage object];
        message.text = rejectionMessage;
        message.user = self.user;
        message.event = self.seatRequest.event;
        message.deleted = @(NO);
        notification.message = message;
        
        [PFObject saveAllInBackground:@[self.seatRequest, message, notification] block:^(BOOL succeeded, NSError *error) {
            
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
    }

    
    
}

#pragma mark - Action Methods

- (IBAction)reviewsButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"reviewsButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    BDReviewsListViewController *reviewListViewController = [[BDReviewsListViewController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:reviewListViewController animated:YES];
    
}

- (IBAction)reportButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"reportButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    BDReportUserViewController *reportUserViewController = [[BDReportUserViewController alloc] initWithUserToReport:self.user];
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:reportUserViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void) certificationsListButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"certificationsListButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    BDUserCertificationsViewController *userCertificationsViewController = [[BDUserCertificationsViewController alloc] initWithUser:self.user];
    [self.navigationController pushViewController:userCertificationsViewController animated:YES];
    
}

- (IBAction)inviteButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"inviteButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    
    BDInviteUserViewController *inviteUserViewController = [[BDInviteUserViewController alloc] initWithUser:self.user];
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:inviteUserViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void) editButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"editButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    BDEditProfileViewController *editUserViewController = [[BDEditProfileViewController alloc] init];
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:editUserViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

#pragma mark - Friends ScrollView

- (void) getFriends {
    
    if ([User currentUser]) {
        
        PFQuery *query = [User query];
        [query whereKey:@"deleted" notEqualTo:@(YES)];
        
        if ([self.user.objectId isEqualToString:[User currentUser].objectId]) {
            [query whereKey:@"friendsFacebookID" equalTo:[User currentUser].facebookID];
        }
        else {
            if (self.user.facebookID) {
                [query whereKey:@"friendsFacebookID" containsAllObjectsInArray:@[self.user.facebookID, [User currentUser].facebookID]];
            }
        }
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            
            self.friendsActivityIndicator.hidden = YES;
            
            if (!error) {
                
                self.friends = users;
                
                [self setupFriendsScrollView];
                
            }
            else {

                [self setupFriendsScrollView];
                
            }
            
        }];
        
    }
    else {
        
        self.friendsActivityIndicator.hidden = YES;
        
    }
    
}

- (void) setupFriendsScrollView {
    
    if (self.friends.count) {
        
        [self.commonFriendsScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        CGFloat spaceBetween = 10.0;
        CGFloat xPosition = 20.0;
        CGFloat yPosition = 0.0;
        CGFloat buttonWidth = 50.0;
        
        for (int i = 0; i < self.friends.count; i++) {
            
            User *user = self.friends[i];
            
            UIButton *userButton = [[UIButton alloc] init];
            userButton.frame = CGRectMake(xPosition, yPosition, buttonWidth, buttonWidth);
            userButton.tag = i;
            [userButton addTarget:self action:@selector(friendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            PFFile *theImage = user.pictures[[user.selectedPictureIndex integerValue]];
            
            // Get image from cache or from server if isnt available (background task)
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                UIImage *image = [UIImage imageWithData:data];
                image = [image imageByScalingToSize:CGSizeMake(buttonWidth, buttonWidth)];
                [userButton setImage:image forState:UIControlStateNormal];
                
                userButton.layer.cornerRadius = buttonWidth / 2.0;
                userButton.clipsToBounds = YES;
                
            }];
            
            [self.commonFriendsScrollView addSubview:userButton];
            
            xPosition += (buttonWidth + spaceBetween);
            
        }
        
        CGFloat scrollContentWidth = xPosition;
        
        [self.commonFriendsScrollView setContentSize:CGSizeMake(scrollContentWidth, CGRectGetHeight(self.commonFriendsScrollView.frame))];
        self.commonFriendsScrollView.showsHorizontalScrollIndicator = NO;
        
    } else {
        
        self.noFriendsLabel.hidden = NO;
        self.noFriendsLabel.font = [UIFont abelFontWithSize:13.0];
        self.noFriendsLabel.textColor = [UIColor grayBoatDay];
        self.noFriendsLabel.numberOfLines = 0;
        
        if ([self.user.objectId isEqualToString:[User currentUser].objectId]) {
            self.noFriendsLabel.text = NSLocalizedString(@"profile.noFriends", nil);
        }
        else {
            // Common
            self.noFriendsLabel.text = NSLocalizedString(@"profile.noFriendsInCommon", nil);
            
        }
        
    }
}

-(void) friendButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"friendButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    UIButton *userButton = (UIButton*)sender;
    User *friend = self.friends[userButton.tag];
    
    BDProfileViewController *profileViewController = [[BDProfileViewController alloc] initWithUser:friend andProfileType:ProfileTypeOther];
    
    [self.navigationController pushViewController:profileViewController animated:YES];
    
}

#pragma mark - Activities ScrollView

- (void) getActivities {
    
    NSMutableArray *activitiesTemp = [[NSMutableArray alloc] init];
    
    if ([self.user.objectId isEqualToString:[User currentUser].objectId]) {
        
        activitiesTemp = [User currentUser].activities;
    }
    else {
        
        [[User currentUser].activities enumerateObjectsUsingBlock:^(Activity *activity, NSUInteger idx, BOOL *stop) {
            
            if ([self.user.activities containsObject:activity]) {
                [activitiesTemp addObject:activity];
            }
            
        }];
        
    }
    
    self.activities = [[NSMutableArray alloc] init];
    
    [[Session sharedSession].allActivities enumerateObjectsUsingBlock:^(Activity *activity, NSUInteger idx, BOOL *stop) {
        
        if ([activitiesTemp containsObject:activity]) {
            [self.activities addObject:activity];
        }
        
    }];
    
    
    [self setupActivitiesScrollView];
    
}

- (void) setupActivitiesScrollView {
    
    if (self.activities.count) {
        
        [self.activitiesScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        CGFloat spaceBetween = 10.0;
        CGFloat xPosition = 10.0;
        CGFloat yPosition = 0.0;
        CGFloat buttonWidth = 45.0;
        
        for (int i = 0; i < self.activities.count; i++) {
            
            Activity *activity = self.activities[i];
            
            UIImageView *userButton = [[UIImageView alloc] init];
            userButton.frame = CGRectMake(xPosition, yPosition, buttonWidth, buttonWidth);
            
            PFFile *theImage = activity.picture;
            
            // Get image from cache or from server if isnt available (background task)
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                UIImage *image = [UIImage imageWithData:data];
                
                [userButton setImage:image];
                userButton.userInteractionEnabled = NO;
                
            }];
            
            [self.activitiesScrollView addSubview:userButton];
            
            xPosition += (buttonWidth + spaceBetween);
            
        }
        
        CGFloat scrollContentWidth = xPosition;
        
        [self.activitiesScrollView setContentSize:CGSizeMake(scrollContentWidth, CGRectGetHeight(self.activitiesScrollView.frame))];
        self.activitiesScrollView.showsHorizontalScrollIndicator = NO;
        self.noActivitiesLabel.hidden = YES;
        
    }
    else {
        
        self.noActivitiesLabel.hidden = NO;
        self.noActivitiesLabel.font = [UIFont abelFontWithSize:13.0];
        self.noActivitiesLabel.textColor = [UIColor whiteColor];
        self.noActivitiesLabel.numberOfLines = 0;
        
        if ([self.user.objectId isEqualToString:[User currentUser].objectId]) {
            self.noActivitiesLabel.text = NSLocalizedString(@"profile.noActivities", nil);
        }
        else {
            // Common
            self.noActivitiesLabel.text = NSLocalizedString(@"profile.noActivitiesInCommon", nil);
            
        }
        
    }
    
}

#pragma mark - Notification Methods

- (void) userLoggedInNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"userLoggedIn"]) {
        
        [self setupProfileView];
        
    }
    
    if ([[notification name] isEqualToString:@"loginFailed"]) {
        
        [[Session sharedSession] getUserRelationshipsData];
        
    }
    
}

@end

