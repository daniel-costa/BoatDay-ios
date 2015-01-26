//
//  BDInviteUserViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 25/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDInviteUserViewController.h"
#import "BDFindABoatCalendarCell.h"

@interface BDInviteUserViewController ()

@property (strong, nonatomic) User *user;

@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) Event *selectedEvent;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIBarButtonItem *inviteButton;

@property (weak, nonatomic) IBOutlet UIView *bottomHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userLittleImageView;
@property (weak, nonatomic) IBOutlet UIView *imageAndNameView;
@property (weak, nonatomic) IBOutlet UILabel *lastActiveLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageTitleLabel;

@property (strong, nonatomic) NSIndexPath *lastIndexPath;

@end

@implementation BDInviteUserViewController

- (instancetype)initWithUser:(User *)user{
    
    self = [super init];
    
    if( !self ) return nil;
    
    _user = user;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"inviteUser.title", nil);
    self.screenName =@"BDInviteUserViewController";

    [self setupTableView];
    
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // setup navigation bar buttons
    [self setupNavigationBar];
    
    [self getUserEvents];
    
}

- (void) setupNavigationBar {
    
    // create save button to navigatio bar at top of the view
    self.inviteButton = [[UIBarButtonItem alloc]
                         initWithTitle:NSLocalizedString(@"invite.sendInvite", nil)
                         style:UIBarButtonItemStyleDone
                         target:self
                         action:@selector(inviteButtonPressed:)];
    
    // create cancel button to navigatio bar at top of the view
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"editProfile.cancel", nil)
                                     style:UIBarButtonItemStyleDone
                                     target:self
                                     action:@selector(cancelButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    
}

#pragma mark - Setup Methods

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDFindABoatCalendarCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDFindABoatCalendarCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor whiteColor];;
    
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)setupView {
    
    self.nameLabel.font = [UIFont quattroCentoRegularFontWithSize:21.0];
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.lastActiveLabel.font = [UIFont quattroCentoRegularFontWithSize:11.0];
    self.lastActiveLabel.textColor = [UIColor whiteColor];
    
    self.locationLabel.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.locationLabel.textColor = [UIColor yellowBoatDay];
    
    [self getUserImage];
    
    // name example: "Diogo N."
    self.nameLabel.text = self.user.shortName;
    
    self.locationLabel.text = [self.user fullLocation];
    
    /*
    // If this is the current user profile, he is always "Active Now"
    if ([self.user isEqual:[User currentUser]]) {
        
        // if current user, is active now!
        self.lastActiveLabel.text = NSLocalizedString(@"addReview.activeNow", nil);
        
    }
    else {
        
        self.lastActiveLabel.text = [NSString stringWithFormat:@"Last Active: %@", @"MISSING DATE"];
        
    }
    */
    
    self.lastActiveLabel.hidden = YES;
    
    self.messageTitleLabel.text = NSLocalizedString(@"inviteUser.selectAnEvent", nil);
    self.messageTitleLabel.backgroundColor = RGB(45, 143, 140);
    self.messageTitleLabel.textColor = [UIColor whiteColor];
    self.messageTitleLabel.font = [UIFont abelFontWithSize:12.0];
    
}

- (void) getUserImage {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"getUserImage"
                                                                label:self.screenName
                                                                value:nil] build]];


    // user image is "hidden" while is getting its data on background
    self.userLittleImageView.alpha = 0.0;
    
    if (self.user.pictures.count) {
        
        // the first picture is the one that is used in user profile (change this to the selected one)
        PFFile *file = self.user.pictures[0];
        
        // Get image from cache or from server if isnt available (background task)
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            self.userLittleImageView.image = image;
            self.userLittleImageView.layer.cornerRadius = self.userLittleImageView.frame.size.height / 2.0;
            self.userLittleImageView.clipsToBounds = YES;
            
            // show imageView with nice effect
            [UIView showViewAnimated:self.userLittleImageView withAlpha:YES andDuration:0.3];
            
        }];
        
    }
    else {
        
        self.userLittleImageView.image = [UIImage imageNamed:@"user_av_blank_lg"];
        [UIView showViewAnimated:self.userLittleImageView withAlpha:YES andDuration:0.3];
        
    }
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event *event = self.events[indexPath.row];
    
    BDFindABoatCalendarCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDFindABoatCalendarCell reuseIdentifier]];
    
    [cell updateWithEvent:event];
    
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

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath compare: self.lastIndexPath] == NSOrderedSame) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.lastIndexPath = nil;
        
    }
    else {
        
        self.lastIndexPath = indexPath;
        
    }
    
    Event *event = self.events[indexPath.row];
    
    if ([self.selectedEvent.objectId isEqualToString:event.objectId]) {
        self.selectedEvent = nil;
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        
    } else {
        self.selectedEvent = event;
        [self.navigationItem setRightBarButtonItem:self.inviteButton animated:YES];
    }
    
}

#pragma mark - Action Methods

- (IBAction)inviteButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"inviteButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    NSArray *saveArray;
    
    Notification *notification = [Notification object];
    notification.user = self.user;
    notification.event  = self.selectedEvent;
    notification.read  = @(NO);
    notification.text = [NSString stringWithFormat:NSLocalizedString(@"inviteUser.eventInvitationNotification", nil), [User currentUser].fullName, self.selectedEvent.name];
    notification.notificationType = @(NotificationTypeNewEventInvitation);
    notification.deleted = @(NO);
    
    if ([self.selectedEvent.host isEqual:[User currentUser]]) {
        
        SeatRequest *hostInvite = [SeatRequest object];
        hostInvite.user = self.user;
        hostInvite.event = self.selectedEvent;
        hostInvite.numberOfSeats = @(0);
        hostInvite.status = @(SeatRequestStatusPending);
        hostInvite.pendingInvite = @(YES);
        hostInvite.deleted = @(NO);
        
        if (!self.selectedEvent.seatRequests) {
            self.selectedEvent.seatRequests = [[NSMutableArray alloc] init];
        }
        
        [self.selectedEvent.seatRequests addObject:hostInvite];
        
        saveArray = @[hostInvite, notification, self.selectedEvent];
        
    }
    else {
        
        Invite *invite = [Invite object];
        invite.from  = [User currentUser];
        invite.to  = self.user;
        invite.event  = self.selectedEvent;
        invite.deleted = @(NO);
        
        saveArray = @[invite, notification];
        
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    [PFObject saveAllInBackground:saveArray block:^(BOOL succeeded, NSError *error) {
        
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"cancelButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Get Events Methods

- (void) getUserEvents {
    
    [self addActivityViewforView:self.contentView];
    
    // Event that self.user is host
    PFQuery *eventQuery = [Event query];
    [eventQuery includeKey:@"user"];
    [eventQuery includeKey:@"boat"];
    [eventQuery whereKey:@"startsAt" greaterThan:[NSDate date]];
    [eventQuery whereKey:@"host" equalTo:[User currentUser]];
    [eventQuery whereKey:@"deleted" notEqualTo:@(YES)];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        
        // Event that self.user is attending
        PFQuery *attendingQuery = [Event query];
        [attendingQuery whereKey:@"startsAt" greaterThan:[NSDate date]];
        [attendingQuery whereKey:@"deleted" notEqualTo:@(YES)];
        
        PFQuery *attendingSeatRequestQuery = [SeatRequest query];
        [attendingSeatRequestQuery includeKey:@"event"];
        [attendingSeatRequestQuery includeKey:@"event.user"];
        [attendingSeatRequestQuery includeKey:@"event.boat"];
        [attendingSeatRequestQuery whereKey:@"event" matchesQuery:attendingQuery];
        [attendingSeatRequestQuery whereKey:@"user" equalTo:[User currentUser]];
        [attendingSeatRequestQuery whereKey:@"status" equalTo:@(SeatRequestStatusAccepted)];
        [attendingSeatRequestQuery whereKey:@"deleted" notEqualTo:@(YES)];
        
        [attendingSeatRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *seatRequests, NSError *error) {
            
            NSMutableArray *allPossibleEvents = [NSMutableArray arrayWithArray:events];
            
            for (SeatRequest *seatRequest in seatRequests) {
                [allPossibleEvents addObject:seatRequest.event];
            }
            
            NSDictionary *eventsDictionary = [self createUserEventsDictionaryWithEvents:allPossibleEvents andUser:[User currentUser]];
            
            NSArray *newArray = [NSArray arrayWithArray:eventsDictionary[@"host"]];
            self.events = [newArray arrayByAddingObjectsFromArray:eventsDictionary[@"attending"]];
            
            [self removeActivityViewFromView:self.contentView];
            
            [self.tableView reloadData];
            
        }];
        
    }];
    
}

- (NSDictionary*) createUserEventsDictionaryWithEvents:(NSArray*)events andUser:(User*)user{
    
    NSMutableArray *hostEvents = [[NSMutableArray alloc] init];
    NSMutableArray *attendingEvents = [[NSMutableArray alloc] init];
    NSMutableArray *pastEvents = [[NSMutableArray alloc] init];
    
    for (Event *event in events) {
        
        if([user.objectId isEqualToString:event.host.objectId]) {
            
            // User is the host
            
            if ([event.startsAt compare:[NSDate date]] == NSOrderedDescending) {
                
                // Event didn't happen yet
                [hostEvents addObject:event];
                
            } else {
                
                // Past event
                [pastEvents addObject:event];
                
            }
            
        } else {
            
            // User is an attendee
            
            if ([event.startsAt compare:[NSDate date]] == NSOrderedDescending) {
                
                // Event didn't happen yet
                [attendingEvents addObject:event];
                
                
            } else {
                
                // Past event
                [pastEvents addObject:event];
                
            }
            
        }
        
    }
    
    return @{@"host": hostEvents, @"attending": attendingEvents, @"past": pastEvents};
    
}


@end
