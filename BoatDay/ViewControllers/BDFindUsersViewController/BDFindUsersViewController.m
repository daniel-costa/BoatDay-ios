//
//  BDBrowserUsersViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 19/08/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindUsersViewController.h"
#import "BDEventGuestsCell.h"
#import "BDFindUsersTextField.h"
#import "BDProfileViewController.h"

@interface BDFindUsersViewController ()

@property (weak, nonatomic) IBOutlet BDFindUsersTextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIBarButtonItem *filterButton;
// Data
@property (strong, nonatomic) NSMutableArray *usersByNameTotalSearch;
@property (strong, nonatomic) NSMutableArray *usersByLocationTotalSearch;

@property (strong, nonatomic) NSMutableArray *usersByName;
@property (strong, nonatomic) NSMutableArray *usersByLocation;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (strong, nonatomic) NSString *storedLastTextSearchedFromParse;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)textFieldTextChanged:(id)sender;

@end

@implementation BDFindUsersViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"findUsers.title", nil);
    
    [self setupView];
    
    [self getUserWithText:@""];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // set keyboard observers to be called when textFields and textFields are responders
    //   we will need to scroll the table to show the field that is being editing
    [self addKeyboardObservers];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    // remove all observers from notification center to be sure we got no memory leaks
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) addKeyboardObservers {
    
    // add will hide and show keyboard observers from notification center
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

#pragma mark - Setup Methods

- (void) setupView {
    
    [self setupTableView];
    [self setupNavigationBar];
    self.textField.font = [UIFont quattroCentoRegularFontWithSize:17.0];
    self.textField.textColor = [UIColor greenBoatDay];
    
    self.textField.placeholder = NSLocalizedString(@"findUsers.placeholderText", nil);
}

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDEventGuestsCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDEventGuestsCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor lightGrayBoatDay];
    self.tableView.backgroundView.backgroundColor = [UIColor lightGrayBoatDay];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}
- (void) setupNavigationBar {
    
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.frame = CGRectMake(0.0, 0.0, 20.0, 22.0);
    [filterButton setImage:[UIImage imageNamed:@"nav_filter"] forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.filterButton = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    [self.navigationItem setRightBarButtonItem:self.filterButton animated:YES];
    
}
#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfColumns = 3;
    NSInteger numberOfUsers = 0;
    NSInteger numberOfRows = 0;
    
    switch (section) {
            case 0:
                numberOfUsers = self.usersByName.count;
                break;
            case 1:
                numberOfUsers = self.usersByLocation.count;
            default:
                break;
    }
        
    numberOfRows = ceil(numberOfUsers / (CGFloat)numberOfColumns);
    
    return numberOfRows;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 25.0)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, -2.0, tableView.frame.size.width, 25.0)];
    label.font = [UIFont abelFontWithSize:14.0];
    
    NSString *headerLabelString = nil;

    switch (section) {
        case 0:
            headerLabelString = self.usersByName.count ? NSLocalizedString(@"findUser.usersByName", nil) : NSLocalizedString(@"findUser.NoUsersByName", nil);
            label.textColor = [UIColor grayBoatDay];
            view.backgroundColor = [UIColor lightGrayBoatDay];
            break;
        case 1:
            headerLabelString = self.usersByLocation.count ? NSLocalizedString(@"findUser.usersByLocation", nil) : NSLocalizedString(@"findUser.NoUsersByLocation", nil);
            label.textColor = [UIColor grayBoatDay];
            view.backgroundColor = [UIColor lightGrayBoatDay];
            break;
            
        default:
            break;
    }
    
    label.text = headerLabelString;
    [view addSubview:label];
    return view;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDEventGuestsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDEventGuestsCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    User *firstUser, *secondUser, *thirdUser = nil;
    NSArray *usersArray = nil;
    
    switch (indexPath.section) {
        case 0:
            usersArray = self.usersByName;
            break;
        case 1:
            usersArray = self.usersByLocation;
            break;
        default:
            break;
    }
    
    NSInteger startPosition = (indexPath.row) * 3;
    
    firstUser = usersArray.count > startPosition ? usersArray[startPosition] : nil;
    secondUser = usersArray.count > startPosition+1 ? usersArray[startPosition+1] : nil;
    thirdUser = usersArray.count > startPosition+2 ? usersArray[startPosition+2] : nil;
    
    [cell updateCellWithFirstUser:firstUser
                       secondUser:secondUser
                        thirdUser:thirdUser
                    withConfirmed:NO];
    
    [cell setCellColor:[UIColor clearColor]];
    
    [cell setUserTapBlock:^(User *user) {
        
        ProfileType type = ProfileTypeOther;
        
        if ([user isEqual:[User currentUser]]) {
            type = ProfileTypeSelf;
            
        }
        BDProfileViewController *profileViewController = [[BDProfileViewController alloc] initWithUser:user andProfileType:type];
        [self.navigationController pushViewController:profileViewController animated:YES];

        
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

#pragma mark - UITextfield Delegate Methods

- (IBAction)textFieldTextChanged:(id)sender {
    
    if ([self.textField.text length] > 1) {
       
        if ([self.textField.text length] == 2 && ![self.storedLastTextSearchedFromParse isEqualToString:self.textField.text]) {
            
            self.storedLastTextSearchedFromParse = self.textField.text;
            [self getUserWithText:self.textField.text];
        }
        else {
            [self doLocalSearchWithText:self.textField.text];
        }
    }
    else {
        self.storedLastTextSearchedFromParse = @"";
        [self getUserWithText:@""];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self dismissKeyboard];
    
    return YES;
    
}

#pragma mark - Keyboard Methods

- (void)dismissKeyboard {
    
    [self.view endEditing:YES];
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
    // Add tap gesture to dismiss keyboard
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(dismissKeyboard)];
    [self.tap setNumberOfTapsRequired:1];
    [self.navigationController.view addGestureRecognizer:self.tap];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    // Remove gesture recognizer
    [self.navigationController.view removeGestureRecognizer:self.tap];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    self.tap = nil;
    
}

#pragma mark - Get Search Data Methods

- (void) getUserWithText:(NSString *)text {

    self.activityIndicator.hidden = NO;
    
    // Name Query
    PFQuery *nameQuery = [User query];
    nameQuery.limit = 1000;

    [nameQuery whereKey:@"fullName" matchesRegex:[NSString stringWithFormat:@".*%@", text] modifiers:@"i"];
    [nameQuery whereKey:@"deleted" notEqualTo:@(YES)];

    [nameQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        self.usersByNameTotalSearch = [NSMutableArray arrayWithArray:objects];
        [self.usersByNameTotalSearch removeObject:[User currentUser]];

        self.usersByName = [NSMutableArray arrayWithArray:self.usersByNameTotalSearch];
        [self.usersByName removeObject:[User currentUser]];
        // Location Query
        
        PFQuery *cityQuery = [User query];
        [cityQuery whereKey:@"city" matchesRegex:[NSString stringWithFormat:@".*%@", text] modifiers:@"i"];
        [cityQuery whereKey:@"deleted" notEqualTo:@(YES)];

        PFQuery *countryQuery = [User query];
        [countryQuery whereKey:@"country" matchesRegex:[NSString stringWithFormat:@".*%@", text] modifiers:@"i"];
        [countryQuery whereKey:@"deleted" notEqualTo:@(YES)];

        PFQuery *locationQuery = [PFQuery orQueryWithSubqueries:@[cityQuery,countryQuery]];
        locationQuery.limit = 1000;
        [locationQuery whereKey:@"deleted" notEqualTo:@(YES)];

        [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            self.usersByLocationTotalSearch = [NSMutableArray arrayWithArray:objects];
            [self.usersByLocationTotalSearch removeObject:[User currentUser]];

            self.usersByLocation = [NSMutableArray arrayWithArray:self.usersByLocationTotalSearch];

            [self.tableView reloadData];
            self.activityIndicator.hidden = YES;

            
        }];
        
    }];
    
}

- (void) doLocalSearchWithText:(NSString *)text {
    
    // By name

    NSString* filter = @"%K CONTAINS[cd] %@";
    
    NSArray* args = @[@"fullName", text];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:filter argumentArray:args];
    
    NSArray* filteredDataLocation = [self.usersByNameTotalSearch filteredArrayUsingPredicate:predicate];
    
    self.usersByName = [NSMutableArray arrayWithArray:filteredDataLocation];

   // By Location
    
    filter = @"%K CONTAINS[cd] %@ || %K CONTAINS[cd] %@";
   
    args = @[@"city", text, @"country", text];
   
    predicate = [NSPredicate predicateWithFormat:filter argumentArray:args];
    
    filteredDataLocation = [self.usersByLocationTotalSearch filteredArrayUsingPredicate:predicate];
    
    self.usersByLocation = [NSMutableArray arrayWithArray:filteredDataLocation];

    [self.tableView reloadData];

}

#pragma mark - Action Methods

- (void) filterButtonPressed:(id)sender {
/*
    BDFindABoatFilterViewController *filterViewController = [[BDFindABoatFilterViewController alloc] initWithFilterDictionary:self.filterDictionary];
    
    [filterViewController setFilterDictionaryChangeBlock:^(NSMutableDictionary *filterDictionary) {
        
        self.filterDictionary = filterDictionary;
        self.events = nil;
        
    }];
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:filterViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    */
}




@end
