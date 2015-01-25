//
//  BDMyEventsViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDMyEventsViewController.h"
#import "HMSegmentedControl.h"

#import "BDDateRange.h"
#import "BDAddEditEventProfileViewController.h"
#import "BDEventProfileViewController.h"
#import "BDEventListViewController.h"
@interface BDMyEventsViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) HMSegmentedControl *segmentedControl;

@property (strong, nonatomic) BDEventListViewController *eventHostingViewController;
@property (strong, nonatomic) BDEventListViewController *eventAttendingViewController;
@property (strong, nonatomic) BDEventListViewController *eventHistoryViewController;

@property (strong, nonatomic) UIBarButtonItem *filterButton;

@property (nonatomic) NSInteger lastIndex;

// Data
@property (nonatomic, strong) NSMutableArray *hostingEvents;
@property (nonatomic, strong) NSMutableArray *attendingEvents;
@property (nonatomic, strong) NSMutableArray *historyEvents;

@property (strong, nonatomic) User *user;

@end

@implementation BDMyEventsViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
        self.screenName =@"BDMyEventsViewController";

    self.user = [User currentUser];
    
    self.title = NSLocalizedString(@"myEvents.title", nil);
    
    // setup navigation bar buttons
    [self setupNavigationBar];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self resetView];
    
    [self setupView];
    
    [self getEvents];
    
}

#pragma mark - Setup Methods

- (void) setupNavigationBar {
    
    if (self.user.hostRegistration && [self.user.hostRegistration.status integerValue] == HostRegistrationStatusAccepted) {
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake(0, 0, 25, 25);
        [addButton setImage:[UIImage imageNamed:@"ico-Add"] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
        self.navigationItem.rightBarButtonItem = addButtonItem;
        
    }
    
}

- (void) resetView {
    
    UIViewController *fromViewController = [self.childViewControllers lastObject];
    [fromViewController removeFromParentViewController];
    [fromViewController.view removeFromSuperview];
    [self.segmentedControl removeFromSuperview];
    
}

- (void) setupView {
    
    [self setupSegmentedControl];
    
    setFrameY(self.containerView, CGRectGetMaxY(self.segmentedControl.frame));
    setFrameHeight(self.containerView, CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(self.segmentedControl.frame));
    
}

- (void) setupSegmentedControl {
    
    if (self.user.hostRegistration) {
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                                 @[NSLocalizedString(@"myEvents.segmentedControl.hostingEvents", nil),
                                   NSLocalizedString(@"myEvents.segmentedControl.attendingEvents", nil),
                                   NSLocalizedString(@"myEvents.segmentedControl.historyEvents", nil)]];
    }
    else {
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                                 @[NSLocalizedString(@"myEvents.segmentedControl.attendingEvents", nil),
                                   NSLocalizedString(@"myEvents.segmentedControl.historyEvents", nil)]];
    }
    
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
    
    __weak BDMyEventsViewController *weakSelf = self;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        
        [weakSelf changeViewControllerToIndex:index];
        
    }];
    
    self.segmentedControl.hidden = YES;
    
    [self.contentView addSubview:self.segmentedControl];
    [UIView showViewAnimated:self.segmentedControl withAlpha:YES andDuration:0.6];
    
}

- (void) setupViewControllers {
    
    self.eventHostingViewController = [[BDEventListViewController alloc] initWithEventsHostingAndHistory:self.hostingEvents];

    
    __weak BDMyEventsViewController *weakSelf = self;
    
    [self.eventHostingViewController setEventTappedBlock:^(Event *event){
        
        BDEventProfileViewController *eventViewController = [[BDEventProfileViewController alloc] initWithEvent:event];
        [weakSelf.navigationController pushViewController:eventViewController animated:YES];
        
    }];
    
    self.eventAttendingViewController = [[BDEventListViewController alloc] initWithEvents:self.attendingEvents];
    
    [self.eventAttendingViewController setEventTappedBlock:^(Event *event){
        
        BDEventProfileViewController *eventViewController = [[BDEventProfileViewController alloc] initWithEvent:event];
        [weakSelf.navigationController pushViewController:eventViewController animated:YES];
        
    }];
    
    self.eventHistoryViewController = [[BDEventListViewController alloc] initWithEventsHostingAndHistory:self.historyEvents];
    
    [self.eventHistoryViewController setEventTappedBlock:^(Event *event){
        
        BDEventProfileViewController *eventViewController = [[BDEventProfileViewController alloc] initWithEvent:event];
        [weakSelf.navigationController pushViewController:eventViewController animated:YES];
        
    }];
    
}

- (void) changeViewControllerToIndex:(NSInteger)index {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"segmentedControlChangeView"
                                                                label:self.screenName
                                                                value:nil] build]];


    self.segmentedControl.userInteractionEnabled = NO;
    
    UIViewController *fromViewController = [self.childViewControllers lastObject];
    UIViewController *toViewController;
    
    NSInteger lastIndex = self.lastIndex;
    self.lastIndex = index;
    
    if (self.user.hostRegistration) {
        switch (index) {
            case 0:
                toViewController = self.eventHostingViewController;
                break;
            case 1:
                toViewController = self.eventAttendingViewController;
                break;
            case 2:
                toViewController = self.eventHistoryViewController;
                break;
            default:
                break;
        }
        
    }
    else {
        
        switch (index) {
            case 0:
                toViewController = self.eventAttendingViewController;
                break;
            case 1:
                toViewController = self.eventHistoryViewController;
                break;
            default:
                break;
        }
        
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
    
    PFQuery *seatRequestQuery = [SeatRequest query];
    [seatRequestQuery whereKey:@"user" equalTo:[User currentUser]];
    [seatRequestQuery whereKey:@"status" notEqualTo:@(SeatRequestStatusRejected)];
    [seatRequestQuery whereKey:@"deleted" notEqualTo:@(YES)];
    
    PFQuery *attendeesQuery = [Event query];
    [attendeesQuery whereKey:@"seatRequests" matchesQuery:seatRequestQuery];
    [attendeesQuery whereKey:@"deleted" notEqualTo:@(YES)];
    
    PFQuery *hostQuery = [Event query];
    [hostQuery whereKey:@"host" equalTo:self.user];
    [hostQuery whereKey:@"deleted" notEqualTo:@(YES)];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[attendeesQuery, hostQuery]];
    [query includeKey:@"boat"];
    [query includeKey:@"host"];
    [query includeKey:@"host.reviews"];
    [query includeKey:@"host.hostRegistration"];
    [query includeKey:@"activities"];
    [query includeKey:@"seatRequests"];
    [query includeKey:@"seatRequests.user"];
    [query includeKey:@"seatRequests.event"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        
        // We got all the data, we can remove the loading view
        [self removeActivityViewFromView:self.contentView];
        
        if (!error) {
            
            // create 3 diferent events array
            [self createEventsArraysFromEvents:events];
            
            self.segmentedControl.hidden = NO;
            
            [self setupViewControllers];
            
            [self changeViewControllerToIndex:FindABoatTabEvents];
            
        } else {
            
            // If something is wrong (99% is no connection), shows a warning
            [self addNoConnectionView];
            
        }
        
    }];
    
}

- (void)createEventsArraysFromEvents:(NSArray*)events {
    
    NSDate *nowDate = [NSDate date];
    
    self.hostingEvents = [[NSMutableArray alloc] init];
    self.attendingEvents = [[NSMutableArray alloc] init];
    self.historyEvents = [[NSMutableArray alloc] init];
    
    for (Event *event in events) {
        
        // ends later than "now"
        if ([event.endDate compare:nowDate] == NSOrderedDescending) {
            
            if ([event.host isEqual:self.user]) {
                [self.hostingEvents addObject:event];
            }
            else {
                [self.attendingEvents addObject:event];
            }
            
        }
        else { // history
            
            [self.historyEvents addObject:event];
            
        }
        
    }
    
}

#pragma mark - IBAction Methods

-(void) addButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"addButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    if (![Session sharedSession].hostRegistration.merchantId) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"myEvents.merchantIdAlertView.title", nil)
                                                              message:NSLocalizedString(@"myEvents.merchantIdAlertView.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
        
    }
    
    BDAddEditEventProfileViewController *viewController = [[BDAddEditEventProfileViewController alloc] init];
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:viewController];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    
}

@end
