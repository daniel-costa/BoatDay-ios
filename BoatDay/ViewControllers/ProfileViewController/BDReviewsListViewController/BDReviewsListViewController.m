//
//  BDReviewsListViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 25/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDReviewsListViewController.h"
#import "BDReviewsListCell.h"
#import "BDAddReviewViewController.h"

@interface BDReviewsListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) User *user;

@property (strong, nonatomic) NSArray *reviews;

@end

@implementation BDReviewsListViewController

- (instancetype)initWithUser:(User *)user {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _user = user;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"reviews.title", nil);
    
    // setup view
    [self setupTableView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self checkIfUserCanAddReview];
    [self getReviews];
    
}

- (void) showAddReviewButton {
    
    if (![self.user isEqual:[User currentUser]]) {
        
        // create save button to navigatio bar at top of the view
        UIBarButtonItem *addReviewButton = [[UIBarButtonItem alloc]
                                            initWithTitle:NSLocalizedString(@"reviews.addReview", nil)
                                            style:UIBarButtonItemStyleDone
                                            target:self
                                            action:@selector(addReviewButtonPressed)];
        
        self.navigationItem.rightBarButtonItem = addReviewButton;
        
    }
    
}

- (void) addReviewButtonPressed {
    
    BDAddReviewViewController *addReviewViewController = [[BDAddReviewViewController alloc] initWithUserToReview:self.user];
    
    [self.navigationController pushViewController:addReviewViewController animated:YES];
    
}

- (void) checkIfUserCanAddReview {
    
    if ([User currentUser]) {
        
        // If I was in an Event that self.user was host
        PFQuery *eventQuery = [Event query];
        [eventQuery whereKey:@"startsAt" lessThan:[NSDate date]];
        [eventQuery whereKey:@"host" equalTo:self.user];
        [eventQuery whereKey:@"deleted" notEqualTo:@(YES)];
        
        PFQuery *otherHostquery = [SeatRequest query];
        [otherHostquery whereKey:@"event" matchesQuery:eventQuery];
        [otherHostquery whereKey:@"user" equalTo:[User currentUser]];
        [otherHostquery whereKey:@"status" equalTo:@(SeatRequestStatusAccepted)];
        [otherHostquery whereKey:@"deleted" notEqualTo:@(YES)];
        
        // If self.user was in an Event that I host
        PFQuery *eventHostQuery = [Event query];
        [eventHostQuery whereKey:@"startsAt" lessThan:[NSDate date]];
        [eventHostQuery whereKey:@"host" equalTo:[User currentUser]];
        [eventHostQuery whereKey:@"deleted" notEqualTo:@(YES)];
        
        PFQuery *myHostquery = [SeatRequest query];
        [myHostquery whereKey:@"event" matchesQuery:eventHostQuery];
        [myHostquery whereKey:@"user" equalTo:self.user];
        [myHostquery whereKey:@"status" equalTo:@(SeatRequestStatusAccepted)];
        [myHostquery whereKey:@"deleted" notEqualTo:@(YES)];
        
        PFQuery *query = [PFQuery orQueryWithSubqueries:@[otherHostquery, myHostquery]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (objects.count) {
                [self showAddReviewButton];
            }
            
        }];
        
    }
    
}

- (void) getReviews {
    
    self.tableView.hidden = YES;
    
    [self addActivityViewforView:self.contentView];
    
    PFQuery *query = [Review query];
    [query includeKey:@"from"];
    [query whereKey:@"to" equalTo:self.user];
    [query whereKey:@"deleted" notEqualTo:@(YES)];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        self.reviews = objects;
        [self.tableView reloadData];
        
        [UIView showViewAnimated:self.tableView withAlpha:YES andDuration:0.3];

        [self removeActivityViewFromView:self.contentView];


    }];
    
}

#pragma mark - Setup Methods

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDReviewsListCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDReviewsListCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor whiteColor];
    
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

#pragma mark - UITableView Datasource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDReviewsListCell *cell = (BDReviewsListCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // get the bottom of message label to know the cell's height
    return CGRectGetMaxY(cell.messageLabel.frame) + 10.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.reviews.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDReviewsListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDReviewsListCell reuseIdentifier]];
    
    Review *review = self.reviews[indexPath.row];
    
    [cell updateLayoutWithReview:review];
    
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
