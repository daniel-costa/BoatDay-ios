//
//  BDEventProfileViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEventProfileViewController.h"
#import "HMSegmentedControl.h"
#import "BDDateRange.h"
#import "UIAlertView+Blocks.h"

#import "BDEventProfileDetailsViewController.h"
#import "BDEventProfileGuestsViewController.h"
#import "BDEventProfileWallViewController.h"

#import "BDProfileViewController.h"
#import "BDAddEditEventProfileViewController.h"

@interface BDEventProfileViewController ()

@property (strong, nonatomic) Event *event;

@property (strong, nonatomic) UIBarButtonItem *topRightButtonItem;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) HMSegmentedControl *segmentedControl;

@property (strong, nonatomic) BDEventProfileDetailsViewController *eventDetailsViewController;
@property (strong, nonatomic) BDEventProfileGuestsViewController *eventGuestsViewController;
@property (strong, nonatomic) BDEventProfileWallViewController *eventWallViewController;

@property (strong, nonatomic) UIBarButtonItem *filterButton;

@property (nonatomic) NSInteger lastIndex;

// Data

@end

@implementation BDEventProfileViewController

// init this view with an event
- (instancetype)initWithEvent:(Event *)event {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _event = event;
    
    return self;
    
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"eventProfile.title", nil);
    
    [self resetView];
    
    [self setupView];
    
    [self setupViewControllers];
    
    [self.segmentedControl setSelectedSegmentIndex:self.lastIndex];
    
    [self changeViewControllerToIndex:self.lastIndex];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (!self.event) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // setup navigation bar buttons
    [self setupNavigationBar];
    
}

#pragma mark - Setup Methods

- (void) resetView {
    
    UIViewController *fromViewController = [self.childViewControllers lastObject];
    [fromViewController removeFromParentViewController];
    [fromViewController.view removeFromSuperview];
    [self.segmentedControl removeFromSuperview];
    
}

- (void) setupNavigationBar {
    
    if ([User currentUser]) {
        
        if ([self.event.host isEqual:[User currentUser]]) {
            
            if ([self.event.startsAt compare:[NSDate date]] == NSOrderedDescending) {
                
                // create save button to navigatio bar at top of the view
                self.topRightButtonItem = [[UIBarButtonItem alloc]
                                           initWithTitle:NSLocalizedString(@"eventProfile.edit", nil)
                                           style:UIBarButtonItemStyleDone
                                           target:self
                                           action:@selector(editButtonPressed:)];
                
                self.navigationItem.rightBarButtonItem = self.topRightButtonItem;
                
            }
            
        } else {
            
            UIButton *flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
            flagButton.frame = CGRectMake(0, 0, 19, 22);
            [flagButton setImage:[UIImage imageNamed:@"nav_flag"] forState:UIControlStateNormal];
            [flagButton addTarget:self action:@selector(flagButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.topRightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:flagButton];
            self.navigationItem.rightBarButtonItem = self.topRightButtonItem;
            
        }
        
    }
    
}

- (void) setupView {
    
    [self setupSegmentedControl];
    
    setFrameY(self.containerView, CGRectGetMaxY(self.segmentedControl.frame));
    setFrameHeight(self.containerView, CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(self.segmentedControl.frame));
    
}

- (void) setupSegmentedControl {
    
    SeatRequest *userRequest = nil;
    
    // Check for user seats request
    for (SeatRequest *request in self.event.seatRequests) {
        
        if(![request isEqual:[NSNull null]]) {
            
            if ([request.user isEqual:[User currentUser]]) {
                
                // cant be rejected
                if ([request.status integerValue] == SeatRequestStatusAccepted) {
                    userRequest = request;
                }
                
            }
            
        }
        
    }
    
    if (userRequest || [self.event.host isEqual:[User currentUser]]) {
        
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                                 @[NSLocalizedString(@"eventProfile.segmentedControl.details", nil),
                                   NSLocalizedString(@"eventProfile.segmentedControl.guests", nil),
                                   NSLocalizedString(@"eventProfile.segmentedControl.wall", nil)]];
        
    } else {
        
        self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                                 @[NSLocalizedString(@"eventProfile.segmentedControl.details", nil),
                                   NSLocalizedString(@"eventProfile.segmentedControl.guests", nil)]];
        
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
    
    __weak BDEventProfileViewController *weakSelf = self;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        
        [weakSelf changeViewControllerToIndex:index];
        
    }];
    
    self.segmentedControl.hidden = YES;
    
    [self.contentView addSubview:self.segmentedControl];
    [UIView showViewAnimated:self.segmentedControl withAlpha:YES andDuration:0.6];
    
}

- (void) setupViewControllers {
    
    self.eventDetailsViewController = [[BDEventProfileDetailsViewController alloc] initWithEvent:self.event];
    
    self.eventGuestsViewController = [[BDEventProfileGuestsViewController alloc] initWithEvent:self.event];
    
    __weak BDEventProfileViewController *weakSelf = self;
    
    [self.eventGuestsViewController setUserTapBlock:^(User *user, SeatRequest *seatRequest) {
        
        if ([[User currentUser] isEqual:weakSelf.event.host]) {
            
            BDProfileViewController *profileViewController = [[BDProfileViewController alloc] initWithSeatRequest:seatRequest];
            [weakSelf.navigationController pushViewController:profileViewController animated:YES];
            
        } else {
            
            BDProfileViewController *profileViewController = [[BDProfileViewController alloc] initWithUser:user andProfileType:ProfileTypeOther];
            [weakSelf.navigationController pushViewController:profileViewController animated:YES];
            
        }
    }];
    
    self.eventWallViewController = [[BDEventProfileWallViewController alloc] initWithEvent:self.event];
    
    [self.eventWallViewController setUserTapBlock:^(User *user) {
        
        ProfileType type = ProfileTypeOther;
        
        if ([user isEqual:[User currentUser]]) {
            type = ProfileTypeSelf;
            
        }
        BDProfileViewController *profileViewController = [[BDProfileViewController alloc] initWithUser:user andProfileType:type];
        [weakSelf.navigationController pushViewController:profileViewController animated:YES];
        
    }];
    
}

- (void) changeViewControllerToIndex:(EventProfileTab)index {
    
    self.segmentedControl.userInteractionEnabled = NO;
    
    UIViewController *fromViewController = [self.childViewControllers lastObject];
    UIViewController *toViewController;
    
    NSInteger lastIndex = self.lastIndex;
    self.lastIndex = index;
    
    switch (index) {
        case EventProfileTabDetails:
            toViewController = self.eventDetailsViewController;
            break;
        case EventProfileTabGuests:
            toViewController = self.eventGuestsViewController;
            break;
        case EventProfileTabWall:
            toViewController = self.eventWallViewController;
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

#pragma mark - Action Methods

- (void) editButtonPressed:(id)sender {
    
    BDAddEditEventProfileViewController *editEventViewController = [[BDAddEditEventProfileViewController alloc] initWithEvent:self.event];
    [editEventViewController setEventDeletedBlock:^(){
        
        self.event = nil;
        
    }];
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:editEventViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void) flagButtonPressed:(id)sender {
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"eventProfile.flagConfirmation.title", nil)
                                message:NSLocalizedString(@"eventProfile.flagConfirmation.message", nil)
                       cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.noButton", nil) action:^{
        
        // Handle "Cancel"
        
    }]
                       otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.yesButton", nil) action:^{
        
        [self flagEvent];
        
        
    }], nil] show];
    
}

- (void) flagEvent {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    Report *report = [Report object];
    report.from = [User currentUser];
    report.event = self.event;
    report.message = NSLocalizedString(@"eventProfile.flagMessage", nil);
    report.deleted = @(NO);
    
    [report saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"eventProfile.flagAlert.title", nil)
                                                              message:[NSString stringWithFormat:NSLocalizedString(@"eventProfile.flagAlert.message", nil), self.event.name]
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
        [SVProgressHUD dismiss];
        
    }];
    
}

@end
