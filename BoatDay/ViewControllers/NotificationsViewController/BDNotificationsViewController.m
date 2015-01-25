//
//  BDNotificationsViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 02/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDNotificationsViewController.h"
#import "BDNotificationsCell.h"

#import "BDBoatViewController.h"
#import "BDEventProfileViewController.h"
#import "BDProfileViewController.h"
#import "BDReviewsListViewController.h"
#import "UIAlertView+Blocks.h"

@interface BDNotificationsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *notifications;

@end

@implementation BDNotificationsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
        self.screenName =@"BDNotificationsViewController";

    self.title = NSLocalizedString(@"notifications.title", nil);
    
    [self setupTableView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar];
    
    [self getData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
//    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
}

#pragma mark - Setup Methods

- (void) setupNavigationBarButtons {
    
    if (self.notifications.count > 0) {
        
        // create save button to navigation bar at top of the view
        UIBarButtonItem *clearAllButton = [[UIBarButtonItem alloc]
                                           initWithTitle:NSLocalizedString(@"notifications.clearAll", nil)
                                           style:UIBarButtonItemStyleDone
                                           target:self
                                           action:@selector(clearAllButtonPressed)];
        
        self.navigationItem.rightBarButtonItem = clearAllButton;
        
    } else {
        
        self.navigationItem.rightBarButtonItem = nil;

    }

}

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDNotificationsCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDNotificationsCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor whiteColor];
    
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

#pragma mark - Get Data Information Methods

- (void) getData {
    
    [self addActivityViewforView:self.contentView];
    
    PFQuery *query = [Notification query];
    [query orderByDescending:@"createdAt"];
    
    [query whereKey:@"user" equalTo:[User currentUser]];
    [query whereKey:@"deleted" notEqualTo:@(YES)];
    
    [query includeKey:@"boat"];
    [query includeKey:@"boat.owner"];
    [query includeKey:@"boat.rejectionMessage"];
    [query includeKey:@"boat.safetyFeatures"];
    
    [query includeKey:@"event"];
    [query includeKey:@"event.boat"];
    [query includeKey:@"event.host"];
    [query includeKey:@"event.host.reviews"];
    
    [query includeKey:@"event.activities"];
    [query includeKey:@"event.seatRequests"];
    [query includeKey:@"event.seatRequests.user"];
    
    [query includeKey:@"user"];
    [query includeKey:@"user.activities"];
    
    [query includeKey:@"seatRequest"];
    [query includeKey:@"seatRequest.event"];
    [query includeKey:@"seatRequest.user"];
    
    [query includeKey:@"certification"];
    [query includeKey:@"certification.type"];
    
    [query includeKey:@"review"];
    [query includeKey:@"review.from"];
    [query includeKey:@"review.to"];
    
    [query includeKey:@"message"];
    
    self.tableView.alpha = 0.0;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *notifications, NSError *error) {
        
        [self removeActivityViewFromView:self.contentView];
        
        if (!error) {
            
            self.notifications = [NSMutableArray arrayWithArray:notifications];
            
            [self.tableView reloadData];
            
            [UIView showViewAnimated:self.tableView withAlpha:YES andDuration:0.3];
        }
        else {
            [self addNoConnectionView];
        }
        
        [self setupNavigationBarButtons];
        
    }];
    
}

#pragma mark - UITableView Datasource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDNotificationsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDNotificationsCell reuseIdentifier]];
    
    Notification *notification = self.notifications[indexPath.row];
    
    [cell updateLayoutWithNotification:notification];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Notification *notification = self.notifications[indexPath.row];
        
        [self.notifications removeObject:notification];
        [self.tableView reloadData];
        
        notification.deleted = @(YES);
        [notification saveEventually];
        
    }
    
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"didSelectNotifications"
                                                                label:self.screenName
                                                                value:nil] build]];


    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Notification *notification = self.notifications[indexPath.row];
    
    BOOL read = [notification.read boolValue];
    
    if (!read) {
        
        notification.read = @(YES);
        [notification saveEventually];
        
    } else {
        
        BDNotificationsCell *cell = (BDNotificationsCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell setCellColor:[UIColor grayBoatDay]];
        
    }
    
    [self openViewControllerFromNotification:notification];
    
}

- (void) openViewControllerFromNotification:(Notification*)notification {
    
    UIViewController *viewController;
    
    NotificationType type = [notification.notificationType integerValue];
    
    switch (type) {
        case NotificationTypeBoatApproved:
            
            viewController = [[BDBoatViewController alloc] initWithBoat:notification.boat];
            
            break;
        case NotificationTypeBoatRejected:
            
            viewController = [[BDBoatViewController alloc] initWithBoat:notification.boat];
            
            break;
        case NotificationTypeSeatRequest:
            
            viewController = [[BDProfileViewController alloc] initWithSeatRequest:notification.seatRequest];
            break;
        case NotificationTypeRequestApproved:
            
            viewController = [[BDEventProfileViewController alloc] initWithEvent:notification.event];
            
            break;
        case NotificationTypeRequestRejected:
        {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notifications.rejectionMessage.title", nil)
                                                                  message:notification.message.text ?: NSLocalizedString(@"notifications.rejectionMessage.defaultMessage", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
        }
            break;
        case NotificationTypeUserCertificationApproved:
            break;
        case NotificationTypeUserCertificationRejected:
            break;
        case NotificationTypeNewChatMessage:
            
            viewController = [[BDEventProfileViewController alloc] initWithEvent:notification.event];
            
            break;
        case NotificationTypeNewEventInvitation:
            
            viewController = [[BDEventProfileViewController alloc] initWithEvent:notification.event];
            
            break;
        case NotificationTypeRemovedFromAnEvent:
            
            viewController = [[BDEventProfileViewController alloc] initWithEvent:notification.event];
            
            break;
        case NotificationTypeEventRemoved:
        {
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notification.eventDeleted.title", nil)
                                                                  message:notification.message.text
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                        otherButtonTitles:nil];
            
            [myAlertView show];
        }
            break;
        case NotificationTypeNewReview:
            
            viewController = [[BDReviewsListViewController alloc] initWithUser:notification.user];
            
            break;
        case NotificationTypeHostRegistrationApproved:
            break;
        case NotificationTypeHostRegistrationRejected:
            break;
        case NotificationTypeSeatRequestCanceledByUser:
            viewController = [[BDEventProfileViewController alloc] initWithEvent:notification.event];
            break;
        case NotificationTypePaymentReminder:
            viewController = [[BDEventProfileViewController alloc] initWithEvent:notification.event];
            break;
        case NotificationTypeMerchantApproved:
            break;
        case NotificationTypeMerchantDeclined:
            break;
        case NotificationTypeEventEnded:
        {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notification.eventEnded.title", nil)
                                        message:NSLocalizedString(@"notification.eventEnded.message", nil)
                               cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"errorMessages.ok", nil) action:^{
                
                BDEventProfileViewController *viewController = [[BDEventProfileViewController alloc] initWithEvent:notification.event];
                
                [self.navigationController pushViewController:viewController animated:YES];
                
            }]
                               otherButtonItems:nil] show];
            
        }
            break;
        case NotificationTypeEventWillStartIn48H:
            viewController = [[BDEventProfileViewController alloc] initWithEvent:notification.event];
            break;
        case NotificationTypeEventInvitationRemoved:
            viewController = [[BDEventProfileViewController alloc] initWithEvent:notification.event];
            break;
        default:
            break;
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}

#pragma mark - NoConnectionView Delegate Methods

// If user taps or try to reload the No Connection View (maybe he turned on the internet connection)
// We must try to get the data we need
- (void) refreshViewFromNoConnectionView {
    
    [self removeNoConnectionView];
    
    [self getData];
    
}

#pragma mark - Action Methods

- (void) clearAllButtonPressed {
 [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"clearAllButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [SVProgressHUD show];
    
    for (Notification *notification in self.notifications) {
        
        notification.deleted = @(YES);
        
    }
    [PFObject saveAllInBackground:self.notifications block:^(BOOL succeeded, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        [self.notifications removeAllObjects];
        [self.tableView reloadData];
        [self setupNavigationBarButtons];

    }];

    
}


@end
