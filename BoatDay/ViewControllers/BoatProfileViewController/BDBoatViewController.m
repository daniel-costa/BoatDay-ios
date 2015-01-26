//
//  BDBoatViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 23/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDBoatViewController.h"
#import "DNButtonContainerView.h"
#import "MHFacebookImageViewer.h"
#import "UIImage+Resize.h"
#import <AddressBookUI/AddressBookUI.h>
#import "BDBoatMessageViewController.h"
#import "BDAddEditBoatViewController.h"

#define HEADER_HEIGHT 194.0f
#define HEADER_INIT_FRAME CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)
#define USER_INFO_HEADER_HEIGHT 50.0f
#define USER_INFO_HEADER_BIGGER_HEIGHT 60.0f
#define IMAGE_AND_NAME_OFFSET 50.0f

#define kBackgroundParallexFactor 0.5f

@interface BDBoatViewController () <UIScrollViewDelegate, DNButtonContainerViewDelegate>

@property (strong, nonatomic) Boat *boat;

// Parallax

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) UIScrollView *backgroundScrollView;

// Boat Image
@property (strong, nonatomic) IBOutlet UIImageView *boatImageView;
@property (strong, nonatomic) IBOutlet UIImageView *placeholderImageView;

// Header View
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *addedDateLabel;

// Info View

@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UILabel *boatDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lenghtTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lenghtLabel;
@property (weak, nonatomic) IBOutlet UILabel *capacityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *capacityLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildYearTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *safetyFeaturesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *safetyFeaturesLabel;

// Rejected View

@property (strong, nonatomic) IBOutlet DNButtonContainerView *rejectedView;
@property (weak, nonatomic) IBOutlet UILabel *rejectedViewTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rejectedViewSubTitleLabel;

@end

@implementation BDBoatViewController

// init this view with diferent profile types (self  and other)
- (instancetype)initWithBoat:(Boat *)boat {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _boat = boat;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
        self.screenName =@"BDBoatViewController";

    // setup navigation bar buttons
    [self setupNavigationBar];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.boat) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self setupView];
    
    [self getBoatImage];
    
    if (self.boat.rejectionMessage && ![self.rejectedView superview]) {
        
        self.rejectedViewTitleLabel.font = [UIFont abelFontWithSize:14.0];
        self.rejectedViewTitleLabel.textColor = [UIColor whiteColor];
        self.rejectedViewTitleLabel.text = NSLocalizedString(@"boatProfile.rejectedMessage.title", nil);
        
        self.rejectedViewSubTitleLabel.font = [UIFont quattroCentoRegularFontWithSize:12.0];
        self.rejectedViewSubTitleLabel.textColor = [UIColor whiteColor];
        self.rejectedViewSubTitleLabel.text = NSLocalizedString(@"boatProfile.rejectedMessage.subTitle", nil);
        
        setFrameY(self.rejectedView, 0.0);
        
        [self.contentView addSubview:self.rejectedView];
        
        setFrameY(self.mainScrollView, CGRectGetMaxY(self.rejectedView.frame));
        setFrameHeight(self.mainScrollView, CGRectGetHeight(self.contentView.frame) - CGRectGetMaxY(self.rejectedView.frame));
        
    }

    
}

#pragma mark - Setup Methods

- (void) setupNavigationBar {
    
    self.title = NSLocalizedString(@"boatProfile.title", nil);
    
    if ([self.boat.owner.objectId isEqualToString:[User currentUser].objectId]) {
        
        // create save button to navigatio bar at top of the view
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
        [editButton setImage:[UIImage imageNamed:@"ico-Edit"] forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        
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
    self.boatImageView = [[UIImageView alloc] initWithFrame:HEADER_INIT_FRAME];
    self.boatImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.boatImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.boatImageView.backgroundColor = [UIColor clearColor];
    
    // user imaga placeholder
    self.placeholderImageView = [[UIImageView alloc] initWithFrame:HEADER_INIT_FRAME];
    self.placeholderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.placeholderImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.backgroundScrollView addSubview:self.placeholderImageView];
    [self.backgroundScrollView addSubview:self.boatImageView];
    
    // set infoView under userImageView
    setFrameY(self.infoView, CGRectGetMaxY(self.boatImageView.frame));
    
    [self.mainScrollView addSubview:self.backgroundScrollView];
    [self.mainScrollView addSubview:self.infoView];
    
    self.locationLabel.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.locationLabel.textColor = [UIColor yellowBoatDay];
    
    self.nameLabel.font = [UIFont quattroCentoRegularFontWithSize:21.0];
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.addedDateLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.addedDateLabel.textColor = [UIColor whiteColor];
    
    self.boatDetailsLabel.font = [UIFont abelFontWithSize:14.0];
    self.boatDetailsLabel.textColor = [UIColor grayBoatDay];
    self.boatDetailsLabel.text = NSLocalizedString(@"boatProfile.boatDetails", nil);
    
    self.typeTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.typeTitleLabel.textColor = [UIColor grayBoatDay];
    self.typeTitleLabel.text = NSLocalizedString(@"boatProfile.type", nil);
    
    self.lenghtTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.lenghtTitleLabel.textColor = [UIColor grayBoatDay];
    self.lenghtTitleLabel.text = NSLocalizedString(@"boatProfile.length", nil);
    
    self.capacityTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.capacityTitleLabel.textColor = [UIColor grayBoatDay];
    self.capacityTitleLabel.text = NSLocalizedString(@"boatProfile.capacity", nil);
    
    self.buildYearTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.buildYearTitleLabel.textColor = [UIColor grayBoatDay];
    self.buildYearTitleLabel.text = NSLocalizedString(@"boatProfile.buildYear", nil);
    
    self.safetyFeaturesTitleLabel.font = [UIFont abelFontWithSize:12.0];
    self.safetyFeaturesTitleLabel.textColor = [UIColor grayBoatDay];
    self.safetyFeaturesTitleLabel.text = NSLocalizedString(@"boatProfile.safetyFeatures", nil);
    
    [self updateBoatInformation];
    
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.contentView.frame),
                                                 CGRectGetHeight(self.backgroundScrollView.frame) + CGRectGetHeight(self.infoView.frame));
    
}

- (void) updateBoatInformation {
    
    self.nameLabel.text = self.boat.name;
    self.typeLabel.text = self.boat.type;
    self.lenghtLabel.text = [NSString stringWithFormat:@"%@ %@", [self.boat.length stringValue], NSLocalizedString(@"boatProfile.lengthMetric", nil)];
    self.capacityLabel.text = [NSString stringWithFormat:@"%@ %@", [self.boat.passengerCapacity stringValue], NSLocalizedString(@"boatProfile.passengers", nil)];
    self.buildYearLabel.text = [self.boat.buildYear stringValue];
    
    setFrameWidth(self.safetyFeaturesLabel, 275.0);
    setFrameHeight(self.safetyFeaturesLabel, 100.0);
    if (self.boat.safetyFeatures.count) {
        self.safetyFeaturesLabel.text = [[self.boat.safetyFeatures valueForKey:@"name"] componentsJoinedByString:@", "];
        self.safetyFeaturesLabel.text = [NSString stringWithFormat:@"%@.", self.safetyFeaturesLabel.text];
    }
    else {
        self.safetyFeaturesLabel.text = NSLocalizedString(@"boatProfile.noSafetyFeatures", nil);
        
    }
    
    [self.safetyFeaturesLabel sizeToFit];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter birthdayDateFormatter];
    NSString *createdAt = [dateFormatter stringFromDate:self.boat.createdAt];
    self.addedDateLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"boatProfile.addedDate", nil), createdAt];
    
    if(self.boat.location) {
        self.locationLabel.text = NSLocalizedString(@"boatProfile.findingLocation", nil);
        [self setLocationLabelFromGeoPoint:self.boat.location];
    }
    else {
        self.locationLabel.text = NSLocalizedString(@"boatProfile.locationNotFound", nil);
    }
    
}

- (void) setLocationLabelFromGeoPoint:(PFGeoPoint *)geoPoint {
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if (error){
                           
                           self.locationLabel.text = NSLocalizedString(@"boatProfile.locationNotFound", nil);
                           
                           return;
                           
                       }
                       
                       CLPlacemark *placemark = placemarks[0];
                       self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.country];
                       
                   }];
    
}

- (void) getBoatImage {
    
    //set image placeholder
    self.placeholderImageView.image = [UIImage imageNamed:@"boatPhotoCoverPlaceholder"];
    
    // user image is "hidden" while is getting its data on background
    self.boatImageView.alpha = 0.0;
    
    if (self.boat.pictures.count && [self.boat.selectedPictureIndex integerValue] >= 0) {
        
        // set this image enable to be opened with MHFacebookImageViewer on tap
        [self.boatImageView setupImageViewer];
        
        // the first picture is the one that is used in user profile (change this to the selected one)
        PFFile *file = self.boat.pictures[[self.boat.selectedPictureIndex integerValue]];
        self.boatImageView.alpha = 0.0;
        // Get image from cache or from server if isnt available (background task)
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            self.boatImageView.image = image;
            
            // show imageView with nice effect
            [UIView showViewAnimated:self.boatImageView withAlpha:YES andDuration:0.5];
            
        }];
        
    }
    
}

#pragma mark - Action Methods

-(void) editButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"editButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    BDAddEditBoatViewController *editBoatViewController = [[BDAddEditBoatViewController alloc] initWithBoat:self.boat];
    [editBoatViewController setBoatDeletedBlock:^(){
        
        self.boat = nil;
        
    }];
    
    editBoatViewController.locationString = self.locationLabel.text;
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:editBoatViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
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
            self.infoView.frame = (CGRect){.origin = {0, CGRectGetMinY(rect) + CGRectGetHeight(rect)}, .size = self.infoView.frame.size };
            [self.backgroundScrollView setContentOffset:CGPointMake(0, -offsetY * kBackgroundParallexFactor)animated:NO];
            
        }
        
    }
    
}

#pragma mark - DNButtonContainerView Delegate Methods

- (void)touchedButtonContainerView:(UIView*)view {
    
    if (view == self.rejectedView) {
        
        self.rejectedView.backgroundColor = [UIColor whiteColor];
        self.rejectedViewTitleLabel.textColor = RGB(203.0, 22.0, 50.0);
        self.rejectedViewSubTitleLabel.textColor = RGB(203.0, 22.0, 50.0);
        
    }
    
}

- (void)releasedButtonContainerView:(UIView*)view {
    
    if (view == self.rejectedView) {
        
        self.rejectedView.backgroundColor = RGB(203.0, 22.0, 50.0);
        self.rejectedViewTitleLabel.textColor = [UIColor whiteColor];
        self.rejectedViewSubTitleLabel.textColor = [UIColor whiteColor];
        
    }
    
}

- (void)pressedButtonContainerView:(UIView*)view {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"pressedButtonContainerView"
                                                                label:self.screenName
                                                                value:nil] build]];


    if (view == self.rejectedView) {
        
        BDBoatMessageViewController *messageViewController = [[BDBoatMessageViewController alloc] initWithNotificationForBoat:self.boat];
        [self.navigationController pushViewController:messageViewController animated:YES];
        
    }
    
}

@end
