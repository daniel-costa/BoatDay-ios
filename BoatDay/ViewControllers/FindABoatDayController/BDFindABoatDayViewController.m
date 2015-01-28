//
//  BDFindABoatDayViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindABoatDayViewController.h"
#import "HMSegmentedControl.h"
#import "BDFindABoatEventsViewController.h"
#import "BDFindABoatMapViewController.h"
#import "BDFindABoatCalendarViewController.h"
#import "BDFindABoatFilterViewController.h"
#import "BDDateRange.h"

#import "BDEventProfileViewController.h"

NSString *const kTimeFrame              = @"timeframe";
NSString *const kAvailableSeats         = @"availableSeats";
NSString *const kLocationString         = @"locationString";
NSString *const kLocationGeoPoint       = @"pickupLocation";
NSString *const kDistance               = @"distance";
NSString *const kSuggestedPrice         = @"suggestedPrice";
NSString *const kActivities             = @"activities";

NSString *const kChildrenPermitted      = @"childrenPermitted";
NSString *const kSmokingPermitted       = @"smokingPermitted";
NSString *const kAlcoholPermitted       = @"alcoholPermitted";

CGFloat const kMaxDistanceLocation    = 100;
CGFloat const kMinDistanceLocation    = 0.5;

@interface BDFindABoatDayViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) HMSegmentedControl *segmentedControl;

@property (strong, nonatomic) BDFindABoatEventsViewController *eventsViewController;
@property (strong, nonatomic) BDFindABoatMapViewController *mapViewController;
@property (strong, nonatomic) BDFindABoatCalendarViewController *calendarViewController;

@property (strong, nonatomic) UIBarButtonItem *filterButton;

@property (nonatomic) NSInteger lastIndex;

// Data
@property (nonatomic, strong) NSArray *events;

@property (strong, nonatomic) NSMutableDictionary *filterDictionary;

@end

@implementation BDFindABoatDayViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
        self.screenName =@"BDFindABoatDayViewController";

    self.title = NSLocalizedString(@"findABoat.title", nil);
    
    // Set default filter values
    [self setupDefaultValues];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.events) {
        
        [self resetView];
        
        [self setupView];
        
        [self getEvents];
        
        // setup navigation bar buttons
        [self setupNavigationBar];
        
    }
    
}

#pragma mark - Setup Methods

- (void) setupDefaultValues {
    
    if (!self.filterDictionary) {
        
        self.filterDictionary = [@{kTimeFrame: NSLocalizedString(@"findABoat.timeframe.any", nil),
                                   kAvailableSeats: NSLocalizedString(@"findABoat.availableSeats.noLimit", nil),
                                   kLocationString: NSLocalizedString(@"findABoat.location.none", nil),
                                   kLocationGeoPoint: [User currentUser].location,
                                   kDistance: @(kMaxDistanceLocation),
                                   kSuggestedPrice: NSLocalizedString(@"findABoat.suggestedDonation.noLimit", nil),
                                   kActivities: [@[] mutableCopy],
                                   kChildrenPermitted: @(-1),
                                   kSmokingPermitted: @(-1),
                                   kAlcoholPermitted: @(-1),
                                   
                                   } mutableCopy];
    }
    
}

- (void) resetView {
    
    UIViewController *fromViewController = [self.childViewControllers lastObject];
    [fromViewController removeFromParentViewController];
    [fromViewController.view removeFromSuperview];
    [self.segmentedControl removeFromSuperview];
    
}

- (void) setupNavigationBar {
    
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [filterButton setImage:[UIImage imageNamed:@"ico-Filter"] forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.filterButton = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    
}

- (void) setupView {
    
    [self setupSegmentedControl];
    
    setFrameY(self.containerView, CGRectGetMaxY(self.segmentedControl.frame));
    setFrameHeight(self.containerView, CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(self.segmentedControl.frame));
    
    
}

- (void) setupSegmentedControl {
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                             @[NSLocalizedString(@"findABoat.segmentedControl.events", nil),
                               NSLocalizedString(@"findABoat.segmentedControl.map", nil),
                               NSLocalizedString(@"findABoat.segmentedControl.calendar", nil)]];
    
    self.segmentedControl.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, 44.0);
    
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionIndicatorHeight = 6.0;
    self.segmentedControl.selectionIndicatorColor = RGB(53.0, 191.0, 217.0);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleCustom;
    self.segmentedControl.backgroundColor = RGB(229.0, 230.0, 231.0);
    self.segmentedControl.font = [UIFont abelFontWithSize:16.0];
    self.segmentedControl.textColor = RGB(109.0, 110.0, 112.0);
    self.segmentedControl.selectedTextColor = RGB(109.0, 110.0, 112.0);
    self.segmentedControl.selectionIndicatorWidth = 83.0f;
    
    __weak BDFindABoatDayViewController *weakSelf = self;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        
        [weakSelf changeViewControllerToIndex:index];
        
    }];
    
    self.segmentedControl.hidden = YES;
    
    [self.contentView addSubview:self.segmentedControl];
    [UIView showViewAnimated:self.segmentedControl withAlpha:YES andDuration:0.6];
    
}

- (void) setupViewControllers {
    
    self.eventsViewController = [[BDFindABoatEventsViewController alloc] initWithEvents:self.events];
    
    __weak BDFindABoatDayViewController *weakSelf = self;
    
    [self.eventsViewController setEventTappedBlock:^(Event *event){
        
        BDEventProfileViewController *eventViewController = [[BDEventProfileViewController alloc] initWithEvent:event];
        [weakSelf.navigationController pushViewController:eventViewController animated:YES];
        
    }];
    
    self.mapViewController = [[BDFindABoatMapViewController alloc] initWithEvents:self.events];
    self.mapViewController.mapCenter = self.filterDictionary[kLocationGeoPoint];
    
    [self.mapViewController setEventTappedBlock:^(Event *event){
        
        BDEventProfileViewController *eventViewController = [[BDEventProfileViewController alloc] initWithEvent:event];
        [weakSelf.navigationController pushViewController:eventViewController animated:YES];
        
    }];
    
    self.calendarViewController = [[BDFindABoatCalendarViewController alloc] initWithEvents:self.events];
    
    [self.calendarViewController setEventTappedBlock:^(Event *event){
        
        BDEventProfileViewController *eventViewController = [[BDEventProfileViewController alloc] initWithEvent:event];
        [weakSelf.navigationController pushViewController:eventViewController animated:YES];
        
    }];
    
}

- (void) changeViewControllerToIndex:(FindABoatTab)index {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"segmentedControlChangeView"
                                                                label:self.screenName
                                                                value:nil] build]];


    self.segmentedControl.userInteractionEnabled = NO;
    
    UIViewController *fromViewController = [self.childViewControllers lastObject];
    UIViewController *toViewController;
    
    NSInteger lastIndex = self.lastIndex;
    self.lastIndex = index;
    
    switch (index) {
        case FindABoatTabEvents:
            toViewController = self.eventsViewController;
            break;
        case FindABoatTabMap:
            toViewController = self.mapViewController;
            break;
        case FindABoatTabCalendar:
            toViewController = self.calendarViewController;
            break;
        default:
            break;
    }
    
    setFrameHeight(toViewController.view, CGRectGetHeight(self.containerView.frame));
    
    // If is the first time
    if (!self.childViewControllers.count) {
        
        [self addChildViewController:toViewController];
        [self.containerView addSubview:toViewController.view];
        
        self.segmentedControl.userInteractionEnabled = YES;
        
        return;
        
    } else {
        
        [fromViewController willMoveToParentViewController:nil];
        [self addChildViewController:toViewController];
        
        CGFloat width = CGRectGetWidth(self.containerView.frame);
        
        if (index > lastIndex) {
            setFrameX(toViewController.view, width);
        }
        else {
            setFrameX(toViewController.view, -width);
        }
        toViewController.view.alpha = 0.0;
        
        [self transitionFromViewController:fromViewController
                          toViewController:toViewController
                                  duration:0.25
                                   options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionTransitionNone
                                animations:^{
                                    
                                    if (index > lastIndex) {
                                        setFrameX(fromViewController.view, -width);
                                    }
                                    else {
                                        setFrameX(fromViewController.view, width);
                                    }
                                    
                                    setFrameX(toViewController.view, 0.0);
                                    
                                }
                                completion:^(BOOL finished){
                                    
                                    [fromViewController removeFromParentViewController];
                                    [toViewController didMoveToParentViewController:self];
                                    
                                    self.segmentedControl.userInteractionEnabled = YES;
                                    
                                }];
        
        [UIView showViewAnimated:toViewController.view withAlpha:YES andDuration:0.6];
        
    }
    
}

#pragma mark - Get Data and Filter Methods

- (void)getEvents {
    
    // Add a loading view while we fetch the data
    [self addActivityViewforView:self.contentView];
    
    PFQuery *query = [Event query];
    [query includeKey:@"boat"];
    [query includeKey:@"host"];
    [query includeKey:@"host.hostRegistration"];
    [query includeKey:@"host.reviews"];
    [query includeKey:@"activities"];
    [query includeKey:@"attendees"];
    [query includeKey:@"seatRequests"];
    [query includeKey:@"seatRequests.user"];
    [query includeKey:@"seatRequests.event"];
    
    [query orderByAscending:@"startsAt"];
    
    [query whereKey:@"startsAt" greaterThan:[NSDate date]];
    [query whereKey:@"status" equalTo:@(EventStatusApproved)];
    [query whereKey:@"deleted" notEqualTo:@(YES)];
    [query whereKey:@"freeSeats" greaterThan:@(0)];
    
    [self setTimeframeFilter:self.filterDictionary[kTimeFrame] forQuery:query];
    
    [self setAvailableSeatsFilter:self.filterDictionary[kAvailableSeats] forQuery:query];
    
    [self setLocationFilterWithLocation:self.filterDictionary[kLocationGeoPoint] andDistance:self.filterDictionary[kDistance] forQuery:query];
    
    [self setSuggestedDonationFilter:self.filterDictionary[kSuggestedPrice] forQuery:query];
    
    [self setPermissionFilterWithKey:kChildrenPermitted forQuery:query];
    
    [self setPermissionFilterWithKey:kSmokingPermitted forQuery:query];
    
    [self setPermissionFilterWithKey:kAlcoholPermitted forQuery:query];
    
    [self setActivitiesFilterForQuery:query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        
        // We got all the data, we can remove the loading view
        [self removeActivityViewFromView:self.contentView];
        
        if (!error) {
            
            self.segmentedControl.hidden = NO;
            
            self.events = events;
            
            [self.navigationItem setRightBarButtonItem:self.filterButton animated:YES];
            
            [self setupViewControllers];
            
            [self changeViewControllerToIndex:FindABoatTabEvents];
            
        } else {
            
            // If something is wrong (99% is no connection), shows a warning
            [self addNoConnectionView];
            
        }
        
    }];
    
}

// Timeframe filter query
- (void) setTimeframeFilter:(NSString*)timeframe forQuery:(PFQuery*)query {
    
    BDDateRange *dateRange = nil;
    
    if ([timeframe isEqualToString:NSLocalizedString(@"findABoat.timeframe.today", nil)]) {
        
        dateRange = [BDDateRange rangeForDayContainingDate:[NSDate date]];
        
    }
    else
        if ([timeframe isEqualToString:NSLocalizedString(@"findABoat.timeframe.thisWeek", nil)]) {
            
            dateRange = [BDDateRange rangeForWeekContainingDate:[NSDate date]];
            
        }
        else
            if ([timeframe isEqualToString:NSLocalizedString(@"findABoat.timeframe.thisMonth", nil)]) {
                
                dateRange = [BDDateRange rangeForMonthContainingDate:[NSDate date]];
                
            }
            else
                if ([timeframe isEqualToString:NSLocalizedString(@"findABoat.timeframe.thisYear", nil)]) {
                    
                    dateRange = [BDDateRange rangeForYearContainingDate:[NSDate date]];
                    
                }
    
    if (dateRange) {
        
        [query whereKey:@"startsAt" greaterThan:dateRange.startDate];
        [query whereKey:@"startsAt" lessThan:dateRange.endDate];
        
    }
    
}

// Available Seats filter query
- (void) setAvailableSeatsFilter:(NSString*)availableSeats forQuery:(PFQuery*)query {
    
    if ([availableSeats isEqualToString:NSLocalizedString(@"findABoat.availableSeats.noLimit", nil)]) {
        return;
    }
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *seats = [f numberFromString:availableSeats];
    
    [query whereKey:@"freeSeats" greaterThanOrEqualTo:seats];
    
}

// Location and Distance filter query
- (void) setLocationFilterWithLocation:(PFGeoPoint*)geoPoint andDistance:(NSNumber *)distance forQuery:(PFQuery*)query {
    
    if (geoPoint == (id)[NSNull null]) {
        return;
    }
    
    if([distance floatValue] == 100.0) {
        distance = [NSNumber numberWithInt:500];
    }
    
    [query whereKey:kLocationGeoPoint nearGeoPoint:geoPoint withinMiles:[distance floatValue]];

    
}

// Set permission Filter query
- (void) setActivitiesFilterForQuery:(PFQuery*)query {
    
    NSArray *activitiesArray = self.filterDictionary[kActivities];
    if (activitiesArray.count > 0) {
        [query whereKey:kActivities containsAllObjectsInArray:activitiesArray];
    }
    
}

// Set permission Filter query
- (void) setPermissionFilterWithKey:(NSString*)key forQuery:(PFQuery*)query {
    
    if ([self.filterDictionary[key] integerValue] != -1) {
        BOOL permission = [self.filterDictionary[key] boolValue];
        [query whereKey:key equalTo:@(permission)];
    }
    
}

// Suggested Donation filter query
- (void) setSuggestedDonationFilter:(NSString*)suggestedDonation forQuery:(PFQuery*)query {
    
    CGFloat maximumPrice = -1;
    
    if ([suggestedDonation isEqualToString:NSLocalizedString(@"findABoat.suggestedDonation.under25", nil)]) {
        
        maximumPrice = 25;
    }
    else
        if ([suggestedDonation isEqualToString:NSLocalizedString(@"findABoat.suggestedDonation.under50", nil)]) {
            
            maximumPrice = 50;
            
        }
        else
            if ([suggestedDonation isEqualToString:NSLocalizedString(@"findABoat.suggestedDonation.under100", nil)]) {
                
                maximumPrice = 100;
                
            }
            else
                if ([suggestedDonation isEqualToString:NSLocalizedString(@"findABoat.suggestedDonation.under250", nil)]) {
                    
                    maximumPrice = 250;
                    
                }
                else
                    if ([suggestedDonation isEqualToString:NSLocalizedString(@"findABoat.suggestedDonation.under500", nil)]) {
                        
                        maximumPrice = 500;
                        
                    }
    
    if (maximumPrice != -1) {
        
        [query whereKey:@"price" lessThanOrEqualTo:@(maximumPrice)];
        
    }
    
}

#pragma mark - Action Methods

- (void) filterButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"filterButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    BDFindABoatFilterViewController *filterViewController = [[BDFindABoatFilterViewController alloc] initWithFilterDictionary:self.filterDictionary];
    
    [filterViewController setFilterDictionaryChangeBlock:^(NSMutableDictionary *filterDictionary) {
        
        self.filterDictionary = filterDictionary;
        self.events = nil;
        
    }];
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:filterViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}


@end
