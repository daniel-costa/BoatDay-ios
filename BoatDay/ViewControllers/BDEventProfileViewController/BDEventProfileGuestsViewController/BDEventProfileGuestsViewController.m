//
//  BDEventProfileGuestsViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEventProfileGuestsViewController.h"
#import "BDEventGuestsCell.h"
#import "BDFindUsersViewController.h"
#import "BDSeatRequestViewController.h"
#import "UIAlertView+Blocks.h"
#import "BDFinalizeContributionViewController.h"

@interface BDEventProfileGuestsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;


// Data
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) SeatRequest *userRequest;

@property (nonatomic, strong) NSMutableArray *confirmedRequests;
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (nonatomic, strong) NSMutableArray *pendingInvitations;
@property (nonatomic) NSInteger numberOfUsersAttending;

@end

@implementation BDEventProfileGuestsViewController

- (instancetype)initWithEvent:(Event *)event {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _event = event;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tracker = [[GAI sharedInstance] defaultTracker];
    
    self.screenName =@"BDEventProfileGuestsViewController";

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    [self setupView];
    
    [self.tableView reloadData];
    
    PFQuery *query = [Event query];
    [query includeKey:@"boat"];
    [query includeKey:@"host"];
    [query includeKey:@"host.reviews"];
    [query includeKey:@"host.hostRegistration"];
    [query includeKey:@"activities"];
    [query includeKey:@"seatRequests"];
    [query includeKey:@"seatRequests.user"];
    [query includeKey:@"seatRequests.event"];
    
    [query whereKey:@"objectId" equalTo:self.event.objectId];
    [query whereKey:@"deleted" notEqualTo:@(YES)];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        self.event = (Event*)object;
        [self setupView];
        [self adjustScrollViewHeight];
        [self.tableView reloadData];
        
    }];
    
}

- (void) adjustScrollViewHeight {
    
        setFrameHeight(self.tableView, CGRectGetHeight(self.view.frame));
    
}

#pragma mark - Setup Methods

- (void) setupView {
    
    self.confirmedRequests = [[NSMutableArray alloc] init];
    self.pendingRequests = [[NSMutableArray alloc] init];
    self.pendingInvitations = [[NSMutableArray alloc] init];
    
    // Check for user seats request
    for (SeatRequest *request in self.event.seatRequests) {
        
        if(![request isEqual:[NSNull null]]) {
            
            if ([request.status integerValue] == SeatRequestStatusAccepted) {
                
                [self.confirmedRequests addObject:request];
                
            } else {

                if ([request.pendingInvite boolValue]) {
                    
                    [self.pendingInvitations addObject:request];
                    
                } else {
                    if ([request.status integerValue] == SeatRequestStatusPending) {
                        
                        [self.pendingRequests addObject:request];
                        
                    }
                    
                }
            }
        }
        
    }
    
    [self setupTableView];
    
}

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDEventGuestsCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDEventGuestsCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}

#pragma mark - Bottom View Methods

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

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([self.event.host isEqual:[User currentUser]]) {
        return 3;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfColumns = 3;
    NSInteger numberOfUsers = 0;
    NSInteger numberOfRows = 0;
    
    if ([self.event.host isEqual:[User currentUser]]) {
        
        switch (section) {
            case 0: // PENDING REQUESTS YOU’VE RECEIVED
                
                numberOfUsers = self.pendingRequests.count;
                
                break;
            case 1: // PENDING INVITATIONS YOU’VE SENT
                
                numberOfUsers = self.pendingInvitations.count;
                
                break;
            case 2: // CONFIRMED GUESTS
                
                numberOfUsers = self.confirmedRequests.count;
                
                break;
            default:
                break;
        }
        
    } else {
        
        // CONFIRMED GUESTS
        numberOfUsers = self.confirmedRequests.count;
        
    }
    
    numberOfRows = ceil(numberOfUsers / (CGFloat)numberOfColumns);
    
    return numberOfRows;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 1.0, tableView.frame.size.width, 30.0)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 30.0)];
    label.font = [UIFont abelFontWithSize:14.0];
    label.textAlignment = NSTextAlignmentCenter;
    
    NSString *headerLabelString = nil;
    
    if ([self.event.host isEqual:[User currentUser]]) {
        
        switch (section) {
            case 0:
                headerLabelString = self.pendingRequests.count ? NSLocalizedString(@"eventProfile.guests.pendingRequests", nil) : NSLocalizedString(@"eventProfile.guests.noRequests", nil);
                label.textColor = [UIColor grayBoatDay];
                view.backgroundColor = [UIColor whiteColor];
                break;
            case 1:
                headerLabelString = self.pendingInvitations.count ? NSLocalizedString(@"eventProfile.guests.pendingInvitations", nil) : NSLocalizedString(@"eventProfile.guests.noInvitations", nil);
                label.textColor = [UIColor grayBoatDay];
                view.backgroundColor = [UIColor whiteColor];
                break;
            case 2:
                headerLabelString = self.confirmedRequests.count ? NSLocalizedString(@"eventProfile.guests.confirmedGuests", nil) : NSLocalizedString(@"eventProfile.guests.noGuestConfirmations", nil);
                label.textColor = [UIColor grayBoatDay];
                view.backgroundColor = [UIColor whiteColor];
                break;
            default:
                break;
        }
        
    } else {
        headerLabelString = self.confirmedRequests.count ? NSLocalizedString(@"eventProfile.guests.confirmedGuests", nil) : NSLocalizedString(@"eventProfile.guests.noGuestConfirmations", nil);
        label.textColor = [UIColor whiteColor];
        view.backgroundColor = [UIColor eventsGreenBoatDay];
        
    }
    
    label.text = headerLabelString;
    [view addSubview:label];
    return view;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDEventGuestsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDEventGuestsCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    SeatRequest *firstUser, *secondUser, *thirdUser = nil;
    NSMutableArray *usersArray = nil;
    BOOL confirmed;
    
    if ([self.event.host isEqual:[User currentUser]]) {
        
        confirmed = indexPath.section == 2;
        
        switch (indexPath.section) {
            case 0:
                usersArray = self.pendingRequests;
                break;
            case 1:
                usersArray = self.pendingInvitations;
                break;
            case 2:
                usersArray = self.confirmedRequests;
                break;
            default:
                break;
        }
        
    } else {
        
        confirmed = indexPath.section == 0;
        usersArray = self.confirmedRequests;
    }
    
    NSInteger startPosition = (indexPath.row) * 3;
    
    firstUser = usersArray.count > startPosition ? usersArray[startPosition] : nil;
    secondUser = usersArray.count > startPosition+1 ? usersArray[startPosition+1] : nil;
    thirdUser = usersArray.count > startPosition+2 ? usersArray[startPosition+2] : nil;
    
    [cell updateCellWithFirstUser:firstUser.user
                       secondUser:secondUser.user
                        thirdUser:thirdUser.user
                    withConfirmed:confirmed];
    
    NSMutableDictionary *seatRequestsDict = [[NSMutableDictionary alloc] init];
    if (firstUser) seatRequestsDict[firstUser.user.objectId] = firstUser;
    if (secondUser) seatRequestsDict[secondUser.user.objectId] = secondUser;
    if (thirdUser) seatRequestsDict[thirdUser.user.objectId] = thirdUser;
    
    [cell setUserTapBlock:^(User* user) {
        
        if (self.userTapBlock){
            self.userTapBlock(user, seatRequestsDict[user.objectId]);
        }
        
    }];
    
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

@end
