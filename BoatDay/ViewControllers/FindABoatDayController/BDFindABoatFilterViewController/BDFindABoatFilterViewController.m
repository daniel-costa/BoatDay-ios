//
//  BDFindABoatFilterViewController.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindABoatFilterViewController.h"

#import "UIImage+Resize.h"
#import "SVProgressHUD.h"
#import "ActionSheetStringPicker.h"

#import "BDFindABoatFilterFirstRowCell.h"
#import "BDEditProfileActivitiesCell.h"
#import "BDFindABoatFilterDefaultCell.h"
#import "BDLocationViewController.h"
#import "BDActivitiesListViewController.h"
#import "BDFindABoatFilterFamilyContentViewController.h"
#import "BDFindABoatFilterFamilyContentViewCell.h"
extern const NSString * kTimeFrame;
extern const NSString * kAvailableSeats;
extern const NSString * kLocationString;
extern const NSString * kLocationGeoPoint;
extern const NSString * kDistance;
extern const NSString * kSuggestedPrice;
extern const NSString * kActivities;

extern const NSString * kChildrenPermitted;
extern const NSString * kSmokingPermitted;
extern const NSString * kAlcoholPermitted;

extern const CGFloat kMaxDistanceLocation;

@interface BDFindABoatFilterViewController () <UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, BDLocationViewControllerDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSIndexPath *editingIndexPath;

// Data

@property (strong, nonatomic) NSMutableDictionary *filterDictionary;
@property (strong, nonatomic) NSMutableDictionary *oldFilterDictionary;

@end

@implementation BDFindABoatFilterViewController

- (instancetype)initWithFilterDictionary:(NSMutableDictionary*)filterDictionary {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _oldFilterDictionary = filterDictionary;
    
    _filterDictionary = [@{kTimeFrame: filterDictionary[kTimeFrame],
                           kAvailableSeats: filterDictionary[kAvailableSeats],
                           kLocationString: filterDictionary[kLocationString],
                           kLocationGeoPoint: filterDictionary[kLocationGeoPoint],
                           kDistance: filterDictionary[kDistance],
                           kSuggestedPrice: filterDictionary[kSuggestedPrice],
                           kActivities: [filterDictionary[kActivities] mutableCopy],
                           kChildrenPermitted: filterDictionary[kChildrenPermitted],
                           kSmokingPermitted: filterDictionary[kSmokingPermitted],
                           kAlcoholPermitted: filterDictionary[kAlcoholPermitted],
                           } mutableCopy];
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
        self.screenName =@"BDFindABoatFilterViewController";

    // setup view
    [self setupTableView];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // set keyboard observers to be called when textFields and textFields are responders
    //   we will need to scroll the table to show the field that is being editing
    [self addKeyboardObservers];
    
    // need to reload data on view will appear
    //  when we pop a child view controller with modifications
    //  we want them to appear in our tableView
    [self.tableView reloadData];
    
    // setup navigation bar buttons
    [self setupNavigationBar];
    
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

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDFindABoatFilterFirstRowCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDFindABoatFilterFirstRowCell reuseIdentifier]];
    
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDFindABoatFilterDefaultCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDFindABoatFilterDefaultCell reuseIdentifier]];
    
    // Register nib cell class so they can be used in cellForRow
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDFindABoatFilterFamilyContentViewCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDFindABoatFilterFamilyContentViewCell reuseIdentifier]];

    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;

}

- (void) setupNavigationBar {
    
    self.title = NSLocalizedString(@"findABoat.filter", nil);
    
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [saveButton setImage:[UIImage imageNamed:@"ico-save"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [cancelButton setImage:[UIImage imageNamed:@"ico-Cancel"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
}

#pragma mark - Navigation Bar Button Actions

- (void) cancelButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"cancelButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) saveButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"saveButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    if (self.filterDictionaryChangeBlock) {
        
        self.filterDictionaryChangeBlock(self.filterDictionary);
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: // first row
            return 170.0;
        case 1:
            return 60.0;
        default:
            return 60.0;
            break;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            // first row: first and last name, location and birthday date
            return [self firstRowCellForIndexPath:indexPath];
        case 1:
            return [self defaultCellRowForIndexPath:indexPath];
        default:
            // default cell
            return [self familyCellForIndexPath:indexPath];
            break;
    }
    
    
    return nil;
}

- (UITableViewCell *) defaultCellRowForIndexPath:(NSIndexPath*)indexPath {
    
    BDFindABoatFilterDefaultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    
    if (cell == nil) {
        
        cell = [[BDFindABoatFilterDefaultCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"defaultCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont abelFontWithSize:14.0];
        cell.textLabel.textColor = [UIColor grayBoatDay];
        
        // arrow as cell accessory view
        UIImage *arrowImage = [UIImage imageNamed:@"cell_arrow_grey"];
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        CGRect frame = CGRectMake(0.0, 0.0, arrowImage.size.width, arrowImage.size.height);
        arrowImageView.frame = frame;
        arrowImageView.image = arrowImage;
        arrowImageView.backgroundColor = [UIColor clearColor];
        cell.accessoryView = arrowImageView;
        
    }
    
    switch (indexPath.row) {
        case 1: {
            
            NSString *selectedActivitiesString;
            NSMutableArray *selectedActivities = self.filterDictionary[kActivities];
            if (selectedActivities.count) {
                
                selectedActivitiesString = [NSString stringWithFormat:@"%lu %@", (unsigned long)selectedActivities.count, NSLocalizedString(@"findABoat.activities.selected", nil)];
                
            } else {
                
                selectedActivitiesString = NSLocalizedString(@"findABoat.activities.noneSelected", nil);
                
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                   NSLocalizedString(@"findABoat.activities", nil),
                                   selectedActivitiesString];
            break;
            
        }
//        case 2: // FAMILY CONTENT
//            cell.textLabel.text = NSLocalizedString(@"findABoat.familyContent", nil);
//            
//            break;
        default:
            break;
    }
    
    return cell;
}
- (UITableViewCell *) familyCellForIndexPath:(NSIndexPath *)indexPath{
    BDFindABoatFilterFamilyContentViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDFindABoatFilterFamilyContentViewCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 2: // children permitted
        {
            cell.titleLabel.text = [NSLocalizedString(@"findABoat.familyContent.childrenPermitted", nil) uppercaseString];
            
            if ([self.filterDictionary[kChildrenPermitted] integerValue] == -1) {
                [cell.MBSwitch setOn:NO];
            }
            else {
                [cell.MBSwitch setOn:[self.filterDictionary[kChildrenPermitted] boolValue]];
            }
            
            [cell setMbSwitchChangeBlock:^(BOOL isON) {
                
                self.filterDictionary[kChildrenPermitted] = @(isON);
                
            }];
        }
            break;
        case 3: // alcohol permitted
        {
            cell.titleLabel.text = [NSLocalizedString(@"findABoat.familyContent.alcoholPermitted", nil) uppercaseString];
            
            if ([self.filterDictionary[kChildrenPermitted] integerValue] == -1) {
                [cell.MBSwitch setOn:NO];
            }
            else {
                [cell.MBSwitch setOn:[self.filterDictionary[kAlcoholPermitted] boolValue]];
            }
            
            [cell setMbSwitchChangeBlock:^(BOOL isON) {
                
                self.filterDictionary[kAlcoholPermitted] = @(isON);
                
            }];
        }
            break;
        case 4: // smoking permitted
        {
            cell.titleLabel.text = [NSLocalizedString(@"findABoat.familyContent.smokingPermitted", nil) uppercaseString];
            
            if ([self.filterDictionary[kChildrenPermitted] integerValue] == -1) {
                [cell.MBSwitch setOn:NO];
            }
            else {
                [cell.MBSwitch setOn:[self.filterDictionary[kSmokingPermitted] boolValue]];
            }
            
            [cell setMbSwitchChangeBlock:^(BOOL isON) {
                
                self.filterDictionary[kSmokingPermitted] = @(isON);
                
            }];
        }
            break;

    }
    return cell;
}
- (UITableViewCell *) firstRowCellForIndexPath:(NSIndexPath*)indexPath {
    
    BDFindABoatFilterFirstRowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDFindABoatFilterFirstRowCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.locationTitleLabel.text = NSLocalizedString(@"findABoat.location.title", nil);
    [cell.locationButton setTitle:self.filterDictionary[kLocationString] forState:UIControlStateNormal];
    [cell.locationButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.locationButton addTarget:self action:@selector(locationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    cell.timeframeTitleLabel.text = NSLocalizedString(@"findABoat.timeframe", nil);
    [cell.timeframeButton setTitle:self.filterDictionary[kTimeFrame] forState:UIControlStateNormal];
    [cell.timeframeButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.timeframeButton addTarget:self action:@selector(timeFrameButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    cell.availableSeatsTitleLabel.text = NSLocalizedString(@"findABoat.availableSeats", nil);
    [cell.availableSeatsButton setTitle:self.filterDictionary[kAvailableSeats] forState:UIControlStateNormal];
    [cell.availableSeatsButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.availableSeatsButton addTarget:self action:@selector(availableSeatButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    cell.distanceTitleLabel.text = NSLocalizedString(@"findABoat.distance", nil);
    [cell setSliderToMiles:[self.filterDictionary[kDistance] floatValue]];
    [cell setDistanceChangeBlock:^(CGFloat distance) {
        
        self.filterDictionary[kDistance] = @(distance);
        
    }];
    
    cell.suggestedPriceTitleLabel.text = NSLocalizedString(@"findABoat.suggestedPrice", nil);
    [cell.suggestedPriceButton setTitle:self.filterDictionary[kSuggestedPrice] forState:UIControlStateNormal];
    [cell.suggestedPriceButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.suggestedPriceButton addTarget:self action:@selector(suggestedDonationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    cell.keywordsTitleLabel.text = NSLocalizedString(@"findABoat.keywords", nil);
    cell.keywordsTextField.text = @"";
    cell.keywordsTextField.placeholder = NSLocalizedString(@"findABoat.keywordsPlaceholder", nil);
    cell.keywordsTextField.delegate = self;
    cell.keywordsTextField.tag = 3;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    cell.backgroundColor = [UIColor lightGrayBoatDay];
    
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
    
    switch (indexPath.row) {
        case 1:
        {
            BDActivitiesListViewController *activitiesViewController = [[BDActivitiesListViewController alloc] initWithActivities:self.filterDictionary[kActivities]];
            [activitiesViewController setActivitiesChangeBlock:^(NSMutableArray *activities) {
                
                self.filterDictionary[kActivities] = activities;
                
            }];
            [self.navigationController pushViewController:activitiesViewController animated:YES];
        }
            break;
        case 2:
        {
            BDFindABoatFilterFamilyContentViewController *familyContentViewController = [[BDFindABoatFilterFamilyContentViewController alloc] initWithFilterDictionary:self.filterDictionary];
            
            [self.navigationController pushViewController:familyContentViewController animated:YES];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - UITextfield Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    // set editing index path for scroll animation
    self.editingIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    return YES;
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
    
    if(self.tap) {
        [self dismissKeyboard];
        [self.navigationController.view removeGestureRecognizer:self.tap];
        [self.navigationController.navigationBar setUserInteractionEnabled:YES];
        self.tap = nil;
    }
    
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
    // Add tap gesture to dismiss keyboard
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(dismissKeyboard)];
    [self.tap setNumberOfTapsRequired:1];
    [self.navigationController.view addGestureRecognizer:self.tap];
    
    // scroll to indexPath of the cell that is editing
    CGSize keyboardSize = [[notification userInfo][UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    
    
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }];
    
    [self.tableView scrollToRowAtIndexPath:self.editingIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    // Remove gesture recognizer
    [self.navigationController.view removeGestureRecognizer:self.tap];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    self.tap = nil;
    
    // scroll to default
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
    
}

#pragma mark - Action Methods

- (void) locationButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"locationButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    BDLocationViewController *editBoatViewController = [[BDLocationViewController alloc] initWithPFGeoPoint:self.filterDictionary[kLocationGeoPoint]];
    editBoatViewController.delegate = self;
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:editBoatViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void) timeFrameButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"timeFrameButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    // Create an array of strings you want to show in the picker:
    NSArray *timeframeArray = @[NSLocalizedString(@"findABoat.timeframe.any", nil),
                                NSLocalizedString(@"findABoat.timeframe.today", nil),
                                NSLocalizedString(@"findABoat.timeframe.thisWeek", nil),
                                NSLocalizedString(@"findABoat.timeframe.thisMonth", nil),
                                NSLocalizedString(@"findABoat.timeframe.thisYear", nil)];
    
    NSInteger selectedIndex = [timeframeArray indexOfObject:self.filterDictionary[kTimeFrame]];
    if (selectedIndex == NSNotFound) selectedIndex = 0;
    
    ActionSheetStringPicker *action = [[ActionSheetStringPicker alloc]
                                       initWithTitle:nil
                                       rows:timeframeArray
                                       initialSelection:selectedIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           self.filterDictionary[kTimeFrame] = timeframeArray[selectedIndex];
                                           [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:(UITableViewRowAnimationFade)];
                                           
                                       }
                                       cancelBlock:^(ActionSheetStringPicker *picker) {
                                       }
                                       
                                       origin:self.view];
    
    [action showActionSheetPicker];
    [action.toolbar setTintColor:[UIColor greenBoatDay]];
    [action.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
}

- (void) availableSeatButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"availableSeatButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    // Create an array of strings you want to show in the picker:
    NSArray *availableSeatsArray = @[NSLocalizedString(@"findABoat.availableSeats.noLimit", nil),
                                     @"1",
                                     @"2",
                                     @"3",
                                     @"4",
                                     @"5",
                                     @"6",
                                     @"7",
                                     @"8",
                                     @"9",
                                     @"10",
                                     @"11",
                                     @"12",
                                     @"13",
                                     @"14",
                                     @"15"];
    
    NSInteger selectedIndex = [availableSeatsArray indexOfObject:self.filterDictionary[kAvailableSeats]];
    if (selectedIndex == NSNotFound) selectedIndex = 0;
    
    ActionSheetStringPicker *action = [[ActionSheetStringPicker alloc]
                                       initWithTitle:nil
                                       rows:availableSeatsArray
                                       initialSelection:selectedIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           self.filterDictionary[kAvailableSeats] = availableSeatsArray[selectedIndex];
                                           
                                           [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:(UITableViewRowAnimationFade)];
                                           
                                       }
                                       cancelBlock:^(ActionSheetStringPicker *picker) {
                                       }
                                       
                                       origin:self.view];
    
    [action showActionSheetPicker];
    [action.toolbar setTintColor:[UIColor greenBoatDay]];
    [action.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
}

- (void) suggestedDonationButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"suggestedDonationButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    // Create an array of strings you want to show in the picker:
    NSArray * suggestedDonationsArray = @[NSLocalizedString(@"findABoat.suggestedDonation.noLimit", nil),
                                          NSLocalizedString(@"findABoat.suggestedDonation.under25", nil),
                                          NSLocalizedString(@"findABoat.suggestedDonation.under50", nil),
                                          NSLocalizedString(@"findABoat.suggestedDonation.under100", nil),
                                          NSLocalizedString(@"findABoat.suggestedDonation.under250", nil),
                                          NSLocalizedString(@"findABoat.suggestedDonation.under500", nil)];
    
    NSInteger selectedIndex = [suggestedDonationsArray indexOfObject:self.filterDictionary[kSuggestedPrice]];
    if (selectedIndex == NSNotFound) selectedIndex = 0;
    
    ActionSheetStringPicker *action = [[ActionSheetStringPicker alloc]
                                       initWithTitle:nil
                                       rows:suggestedDonationsArray
                                       initialSelection:selectedIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           self.filterDictionary[kSuggestedPrice] = suggestedDonationsArray[selectedIndex];
                                           
                                           [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:(UITableViewRowAnimationFade)];
                                           
                                       }
                                       cancelBlock:^(ActionSheetStringPicker *picker) {
                                       }
                                       
                                       origin:self.view];
    
    [action showActionSheetPicker];
    [action.toolbar setTintColor:[UIColor greenBoatDay]];
    [action.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
    
}

#pragma mark - BDLocation Delegate Methods

- (void)changedLocation:(PFGeoPoint*)location withLocationString:(NSString*)locationString {
    
    if (location) {
        
        locationString = locationString ?: self.filterDictionary[kLocationString];
        
        self.filterDictionary[kLocationString] = locationString;
        self.filterDictionary[kLocationGeoPoint] = location;
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:(UITableViewRowAnimationFade)];
        
    }
    
}

@end
