//
//  BDAddEditEventProfileViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDAddEditEventProfileViewController.h"
#import "UIImage+Resize.h"
#import "SVProgressHUD.h"
#import "ActionSheetStringPicker.h"

#import "BDEditBoatDefaultCell.h"
#import "BDEditEventLastRowCell.h"
#import "BDSafetyFeaturesListViewController.h"
#import "BDLocationViewController.h"
#import "BDBoatInsuranceViewController.h"
#import "BDActivitiesListViewController.h"
#import "BDFindABoatFilterFamilyContentViewController.h"
#import "BDSelectBoatViewController.h"
#import "BDEditProfileAboutMeCell.h"
#import "ActionSheetDatePicker.h"
#import "UIAlertView+Blocks.h"

extern const NSString * kChildrenPermitted;
extern const NSString * kSmokingPermitted;
extern const NSString * kAlcoholPermitted;

static NSInteger const kAboutMeMaximumCharacters = 500;
static NSInteger const kMaximumAvailableSeats = 15;

@interface BDAddEditEventProfileViewController () <UITextFieldDelegate, UITextViewDelegate, BDLocationViewControllerDelegate>

// Data
@property (strong, nonatomic) Event *event;

// Edit Data
@property (strong, nonatomic) NSString *eventName;
@property (strong, nonatomic) NSString *eventDescription;
@property (strong, nonatomic) NSString *pricePerSeat;
@property (strong, nonatomic) Boat *selectedBoat;
@property (strong, nonatomic) NSMutableArray *selectedActivities;
@property (strong, nonatomic) PFGeoPoint *pickupLocation;
@property (strong, nonatomic) NSDate *pickUpTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSMutableDictionary *familyContent;
@property (nonatomic) NSInteger availableSeats;

// Date Picker
@property (nonatomic, strong) ActionSheetDatePicker *actionSheetPicker;

// Old Data (if user cancel the editing, we reset the values to these old values)
@property (strong, nonatomic) Event *oldEvent;

// View
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSIndexPath *editingIndexPath;

// Gesture Recognizer (for keyboardy dismiss)
@property (strong, nonatomic) UITapGestureRecognizer *tap;

// Bottom Buttons
@property (weak, nonatomic) IBOutlet UIButton *bigButton;
@property (weak, nonatomic) IBOutlet UIButton *smallRedButton;
@property (weak, nonatomic) IBOutlet UIButton *smallYellowButton;

@property (strong, nonatomic) UIAlertView *deleteAlertView;

- (IBAction)bigButtonPressed:(id)sender;
- (IBAction)smallRedButtonPressed:(id)sender;
- (IBAction)smallYellowButtonPressed:(id)sender;

@end

@implementation BDAddEditEventProfileViewController

- (instancetype)initWithEvent:(Event *)event {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _event = event;
    
    if (event) {
        
        _eventName = event.name;
        _eventDescription = event.eventDescription;
        _selectedBoat = event.boat;
        _selectedActivities = event.activities;
        _pickupLocation = event.pickupLocation;
        _locationString = event.locationName;
        _pickUpTime = event.startsAt;
        _endTime = event.endDate;
        _familyContent = [@{kAlcoholPermitted: event.alcoholPermitted ?: @(NO),
                            kSmokingPermitted: event.smokingPermitted ?: @(NO),
                            kChildrenPermitted: event.childrenPermitted ?: @(NO)
                            } mutableCopy];
        _availableSeats = [event.availableSeats integerValue];
        _pricePerSeat = [event.price stringValue];
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
        self.screenName =@"BDAddEditEventProfileViewController";

    // make a new copy in order to reset user if this view is canceled
    self.oldEvent = (Event*)[self.event copyShallow];
    
    // setup view
    [self setupTableView];
    
    // Get boats information
    [self getBoatsData];
    
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
    
    [self setupBottomButtons];
    
    if (self.event) {
        
        self.title = NSLocalizedString(@"addEditEvent.edit.title", nil);
        
    } else {
        
        self.title = NSLocalizedString(@"addEditEvent.add.title", nil);
        
    }
    
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

- (void) setupBottomButtons {
    
    if (self.event) {
        
        switch ([self.event.status integerValue]) {
            case EventStatusNotSubmited:
            {
                // delete draft and publish
                self.smallRedButton.hidden = NO;
                self.smallYellowButton.hidden = NO;
                self.bigButton.hidden = YES;
                
                self.smallRedButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
                [self.smallRedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self.smallRedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [self.smallRedButton setTitle:NSLocalizedString(@"addEditEvent.delete", nil) forState:UIControlStateNormal];
                [self.smallRedButton setBackgroundImage:[UIImage imageNamed:@"button_md_red_off"] forState:UIControlStateNormal];
                [self.smallRedButton setBackgroundImage:[UIImage imageNamed:@"button_md_red_on"] forState:UIControlStateHighlighted];
                
                self.smallYellowButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
                [self.smallYellowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self.smallYellowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [self.smallYellowButton setTitle:NSLocalizedString(@"addEditEvent.publish", nil) forState:UIControlStateNormal];
                [self.smallYellowButton setBackgroundImage:[UIImage imageNamed:@"button_sm_yellow_off"] forState:UIControlStateNormal];
                [self.smallYellowButton setBackgroundImage:[UIImage imageNamed:@"button_sm_yellow_on"] forState:UIControlStateHighlighted];
                
            }
                break;
            default:
            {
                // delete event
                self.smallRedButton.hidden = YES;
                self.smallYellowButton.hidden = YES;
                self.bigButton.hidden = NO;
                
                [self.bigButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self.bigButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                
                self.bigButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
                
                [self.bigButton setTitle:NSLocalizedString(@"addEditEvent.delete", nil) forState:UIControlStateNormal];
                [self.bigButton setBackgroundImage:[UIImage imageNamed:@"button_lg_red_off"] forState:UIControlStateNormal];
                [self.bigButton setBackgroundImage:[UIImage imageNamed:@"button_lg_red_on"] forState:UIControlStateHighlighted];
            }
                break;
        }
        
    } else {
        // Publish
        
        self.smallRedButton.hidden = YES;
        self.smallYellowButton.hidden = YES;
        self.bigButton.hidden = NO;
        
        [self.bigButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.bigButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        self.bigButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
        
        [self.bigButton setTitle:NSLocalizedString(@"addEditEvent.publish", nil) forState:UIControlStateNormal];
        [self.bigButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_off"] forState:UIControlStateNormal];
        [self.bigButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_on"] forState:UIControlStateHighlighted];
        
    }
    
}

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDEditEventLastRowCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDEditEventLastRowCell reuseIdentifier]];
    
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDEditProfileAboutMeCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDEditProfileAboutMeCell reuseIdentifier]];
    
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
    
    if (self.event) {
        // create save button to navigatio bar at top of the view
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        saveButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
        [saveButton setImage:[UIImage imageNamed:@"ico-save"] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];

        }
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [cancelButton setImage:[UIImage imageNamed:@"ico-Cancel"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
}

#pragma mark - Navigation Bar Button Actions

- (void) cancelButtonPressed {
    
    // all the modifications must be discarded
    // we reset all simple values, activities and certifications
    [self.event resetValuesToObject:self.oldEvent];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) saveButtonPressed {
    
    if (self.event) {
        
        [self saveEventWithStatus:[self.event.status integerValue]];
        
    } else {
        
        [self saveEventWithStatus:EventStatusNotSubmited];
        
    }
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 3: // first row: first and last name, location and birthday date
            return 275.0;
        case 4:
        {
            BDEditProfileAboutMeCell *cell = (BDEditProfileAboutMeCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
            setFrameHeight(cell, CGRectGetMaxY(cell.charRemainingLabel.frame) + 5.0);
            CGFloat height = CGRectGetHeight(cell.frame);
            return height;
        }
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
        case 3:
            // first row: first and last name, location and birthday date
            return [self lastRowCellForIndexPath:indexPath];
        case 4:
            return [self aboutMeCellRowForIndexPath:indexPath];
        default:
            return [self defaultCellRowForIndexPath:indexPath];
            break;
    }
    
    return nil;
    
}

- (UITableViewCell *) defaultCellRowForIndexPath:(NSIndexPath*)indexPath {
    
    BDEditBoatDefaultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    
    if (cell == nil) {
        
        cell = [[BDEditBoatDefaultCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"defaultCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont abelFontWithSize:14.0];
        cell.textLabel.textColor = [UIColor grayBoatDay];
        
        cell.detailTextLabel.font = [UIFont abelFontWithSize:16.0];
        cell.detailTextLabel.textColor = [UIColor greenBoatDay];
        
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
        case 0:
            cell.textLabel.text = NSLocalizedString(@"addEditEvent.selectBoat", nil);
            if (self.selectedBoat) cell.detailTextLabel.text = self.selectedBoat.name;
            break;
        case 1:
        {
            if (self.selectedActivities.count) {
                
                cell.textLabel.text = NSLocalizedString(@"findABoat.activities", nil);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)self.selectedActivities.count, NSLocalizedString(@"addEditEvent.selected", nil)];
                
            } else {
                
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                       NSLocalizedString(@"findABoat.activities", nil),
                                       NSLocalizedString(@"findABoat.activities.noneSelected", nil)];
                cell.detailTextLabel.text = @"";
                
            }
        }
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"findABoat.familyContent", nil);
            break;
        default:
            break;
    }
    
    return cell;
    
}

- (void)calculateEstimatedIncomes {

    double pricePerSeatWithFee      = [self.pricePerSeat integerValue] + TRUST_SAFETY_FEE;
    double totalPricePerSeatWithFee = self.availableSeats * pricePerSeatWithFee;
    double brainTreeFee             = BRAINTREE_PERCENTAGE * totalPricePerSeatWithFee + BRAINTREE_FIX_FEE * self.availableSeats;
    
    double total = (totalPricePerSeatWithFee - brainTreeFee - (TRUST_SAFETY_FEE * self.availableSeats) ) * (1 - BOATDAY_FEE);
    
//    self.estimatedIncomeTextField.text = [NSString stringWithFormat:@"%.2f $", total];
}

- (UITableViewCell *) lastRowCellForIndexPath:(NSIndexPath*)indexPath {
    
    BDEditEventLastRowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDEditEventLastRowCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.eventNameLabel.text = NSLocalizedString(@"addEditEvent.eventName", nil);
    cell.eventNameTextField.text = self.eventName;
    cell.eventNameTextField.delegate = self;
    cell.eventNameTextField.tag = 1;
    
    cell.locationLabel.text = NSLocalizedString(@"addEditEvent.location", nil);
    [cell.locationButton setTitle:self.locationString forState:UIControlStateNormal];
    [cell.locationButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.locationButton addTarget:self action:@selector(locationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    cell.availableSeatsLabel.text = NSLocalizedString(@"addEditEvent.availableSeats", nil);
    [cell.availableSeatsButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.availableSeats] forState:UIControlStateNormal];
    [cell.availableSeatsButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.availableSeatsButton addTarget:self action:@selector(availableSeatsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    cell.availableSeatsButton.userInteractionEnabled = YES;
    
    if (!self.selectedBoat) {
        cell.availableSeatsButton.userInteractionEnabled = NO;
        [cell.availableSeatsButton setTitle:NSLocalizedString(@"addEditEvent.selectBoatFirst", nil) forState:UIControlStateNormal];
    }
    
    cell.estimatedIncomeLabel.text = NSLocalizedString(@"addEditEvent.estimatedIncome", nil);
    // [cell.estimatedIncomeTextField setTitle:[NSString stringWithFormat:@"%ld", (long)self.availableSeats] forState:UIControlStateNormal];
    [cell.estimatedIncomeButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.estimatedIncomeButton addTarget:self action:@selector(availableSeatsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    cell.estimatedIncomeButton.userInteractionEnabled = YES;
    
    if(!self.selectedBoat) {
        cell.estimatedIncomeButton.userInteractionEnabled = NO;
        [cell.estimatedIncomeButton setTitle:NSLocalizedString(@"addEditEvent.selectBoatFirst", nil) forState:UIControlStateNormal];
    }
    
//    - (void) pricePerSeatEdited:(UITextField *)textField {
//        
//        double amountOfSeats = [self.availableSeatsButton.currentTitle doubleValue];
//        double pricePerSeat = [self.pricePerSeatTextField.text doubleValue];
//        
//        if(amountOfSeats > 0) {
//            [self calculateEstimatedIncomesWithSeats: amountOfSeats AndPrice: pricePerSeat];
//        }
//        
//        NSLog(@"%f %f", amountOfSeats, pricePerSeat);
//    }
    
    cell.pricePerSeatLabel.text = NSLocalizedString(@"addEditEvent.pricePerSeat", nil);
    cell.pricePerSeatTextField.text = self.pricePerSeat;
    cell.pricePerSeatTextField.delegate = self;
    cell.pricePerSeatTextField.tag = 2;
    cell.pricePerSeatTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    cell.pickUpTimeLabel.text = NSLocalizedString(@"addEditEvent.pickUpTime", nil);
    
    NSDateFormatter *dateFormatter = [NSDateFormatter eventProfileDateFormatter];
    NSString *pickUpdate = [dateFormatter stringFromDate:self.pickUpTime];
    
    [cell.pickUpTimeButton setTitle:pickUpdate forState:UIControlStateNormal];
    [cell.pickUpTimeButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.pickUpTimeButton addTarget:self action:@selector(pickUpDateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.pickUpTimeButton.tag = 1;
    
    cell.endTimeLabel.text = NSLocalizedString(@"addEditEvent.endTime", nil);
    
    NSString *endDate = [dateFormatter stringFromDate:self.endTime];
    
    [cell.endTimeButton setTitle:endDate forState:UIControlStateNormal];
    [cell.endTimeButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.endTimeButton addTarget:self action:@selector(endDateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.endTimeButton.tag = 2;
    
    return cell;
    
}

- (UITableViewCell *) aboutMeCellRowForIndexPath:(NSIndexPath*)indexPath {
    
    BDEditProfileAboutMeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDEditProfileAboutMeCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textView.delegate = self;
    
    cell.titleLabel.text = NSLocalizedString(@"addEditEvent.eventDescription", nil);
    cell.textView.text = self.eventDescription;
    cell.textView.tag = 1;
    
    [cell updateCell];
    
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
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"goToselectBoatViewController"
                                                                label:self.screenName
                                                                value:nil] build]];


    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            BDSelectBoatViewController *selectBoatViewController = [[BDSelectBoatViewController alloc] init];
            [selectBoatViewController setBoatSelectedBlock:^(Boat *boat) {
                
                self.selectedBoat = boat;
                self.availableSeats = [boat.passengerCapacity integerValue];
                
            }];
            [self.navigationController pushViewController:selectBoatViewController animated:YES];
        }
            break;
        case 1:
        {
            BDActivitiesListViewController *activitiesViewController = [[BDActivitiesListViewController alloc] initWithActivities:self.selectedActivities];
            [activitiesViewController setActivitiesChangeBlock:^(NSMutableArray *activities) {
                
                self.selectedActivities = activities;
                
            }];
            [self.navigationController pushViewController:activitiesViewController animated:YES];
        }
            break;
        case 2:
        {
            if (!self.familyContent) {
                self.familyContent = [[NSMutableDictionary alloc] init];
            }
            
            BDFindABoatFilterFamilyContentViewController *familyContentViewController = [[BDFindABoatFilterFamilyContentViewController alloc] initWithFilterDictionary:self.familyContent];
            
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
    self.editingIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self dismissKeyboard];
    
    return YES;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == 1) { // Event Name
        self.eventName = textField.text;
    }
    
    if (textField.tag == 2) { // Price Per Set
        self.pricePerSeat = textField.text;
        
        [self calculateEstimatedIncomes];
    }
    
}

#pragma mark - UITextView Delegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    // set editing index path for scroll animation
    self.editingIndexPath = [NSIndexPath indexPathForRow:4 inSection:0];
    
    return YES;
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //maximium chars = 500
    return textView.text.length + (text.length - range.length) <= kAboutMeMaximumCharacters;
    
}

- (void)textViewDidChange:(UITextView *)textView {
    
    switch (textView.tag) {
        case 1:
            self.eventDescription = textView.text;
            break;
        default:
            break;
    }
    
    // prepare height for row for about me label
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    // update the real cell to the new height
    BDEditProfileAboutMeCell *cell = (BDEditProfileAboutMeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    [cell updateCell];
    
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


    BDLocationViewController *editBoatViewController = [[BDLocationViewController alloc] initWithPFGeoPoint:nil];
    editBoatViewController.delegate = self;
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:editBoatViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void) availableSeatsButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"availableSeatsButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    // Create an array of strings you want to show in the picker:
    NSMutableArray *availableSeatsArray = [[NSMutableArray alloc] init];
    
    NSInteger minValue = MIN([self.selectedBoat.passengerCapacity integerValue], kMaximumAvailableSeats);
    
    for (int i = 1; i <= minValue; i++) {
        [availableSeatsArray addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    NSInteger selectedIndex = self.availableSeats-1;
    
    ActionSheetStringPicker *action = [[ActionSheetStringPicker alloc]
                                       initWithTitle:nil
                                       rows:availableSeatsArray
                                       initialSelection:selectedIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           self.availableSeats = selectedIndex+1;
                                           [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:(UITableViewRowAnimationFade)];
                                           
                                       }
                                       cancelBlock:^(ActionSheetStringPicker *picker) {
                                                                                      
                                       }
                                       origin:self.view];
    
    [action showActionSheetPicker];
    [action.toolbar setTintColor:[UIColor greenBoatDay]];
    [action.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
}

- (void) endDateButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"endDateButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self openDatePicker:sender];
    
}

- (void) pickUpDateButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"pickUpDateButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self openDatePicker:sender];
    
}

#pragma mark - BDLocation Delegate Methods

- (void)changedLocation:(PFGeoPoint*)location withLocationString:(NSString*)locationString {
    
    self.locationString = locationString ?: self.locationString;
    self.pickupLocation = location;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:(UITableViewRowAnimationFade)];
    
}

#pragma mark - Date Picker Methods

- (NSDate *) getSelectedDateForTag:(NSInteger)tag {
    
    NSDate *selectedDate = [NSDate date];
    
    // Seconds to Zero
    NSTimeInterval time = floor([selectedDate timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    selectedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    
    switch (tag) {
        case 1: // departure time
            selectedDate = self.pickUpTime ?: selectedDate;
            break;
        case 2: // end time
            selectedDate = self.endTime ?: selectedDate;
            break;
        default:
            break;
    }
    
    return selectedDate;
    
}

-(void)openDatePicker:(id)sender {



    UIButton *selectedButton = (UIButton*)sender;
    
    self.actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                           datePickerMode:UIDatePickerModeDateAndTime
                                                             selectedDate:[self getSelectedDateForTag:selectedButton.tag]
                                                                   target:self
                                                                   action:@selector(dateWasSelected:element:)
                                                                   origin:sender];
    
    switch (selectedButton.tag) {
        case 1: // departure time
            self.actionSheetPicker.maximumDate = self.endTime;
            break;
        case 2: // end time
            self.actionSheetPicker.minimumDate = self.pickUpTime;
            break;
        default:
            break;
    }
    
    self.actionSheetPicker.hideCancel = NO;
    [self.actionSheetPicker showActionSheetPicker];
    [self.actionSheetPicker.toolbar setTintColor:[UIColor greenBoatDay]];
    [self.actionSheetPicker.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    
    // Seconds to Zero
    NSTimeInterval time = floor([selectedDate timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    selectedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    
    UIButton *selectedButton = (UIButton*)element;
    
    switch (selectedButton.tag) {
        case 1: // departure time
            self.pickUpTime = selectedDate;
            break;
        case 2: // end time
            self.endTime = selectedDate;
            break;
        default:
            break;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:(UITableViewRowAnimationFade)];
    
}

#pragma mark - Event Save, Publish & Delete Methods

- (void) deleteEventInParse {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    NSString *rejectionMessage = [[self.deleteAlertView textFieldAtIndex:0] text];
    
    AdminMessage *message = [AdminMessage object];
    message.text = rejectionMessage;
    message.user = [User currentUser];
    message.event = self.event;
    self.event.rejectionMessage = message;
    
    self.event.deleted = @(YES);
    
    [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (self.eventDeletedBlock) {
            self.eventDeletedBlock();
        }
        
        [SVProgressHUD dismiss];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
}

- (void) deleteEvent {
    
    self.deleteAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditEvent.deleteAlert.title", nil)
                                                      message:NSLocalizedString(@"addEditEvent.deleteAlert.message", nil)
                                             cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"errorMessages.ok", nil) action:^{
        
        [self deleteEventInParse];
        
    }]
                                             otherButtonItems:nil];
    
    self.deleteAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [[self.deleteAlertView textFieldAtIndex:0] setPlaceholder:NSLocalizedString(@"addEditEvent.deleteAlert.messageHere", nil)];
    
    [self.deleteAlertView show];
    
}

- (void) publishEvent {
    
    [self saveEventWithStatus:EventStatusApproved];
    
}

- (IBAction)bigButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"bigButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    if (self.event) {
        
        [self deleteEvent];
        
    } else {
        
        [self publishEvent];
        
    }
    
}

- (IBAction)smallRedButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"smallRedButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self deleteEvent];
    
}

- (IBAction)smallYellowButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"smallYellowButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self publishEvent];
    
}

- (void) saveEventWithStatus:(EventStatus)status {
    
    if ([NSString isStringEmpty:self.eventName] ||
        [NSString isStringEmpty:self.pricePerSeat] ||
        [NSString isStringEmpty:self.locationString] ||
        !self.pickupLocation ||
        !self.selectedBoat ||
        !self.pickUpTime||
        !self.endTime) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.alertview.title", nil)
                                                              message:NSLocalizedString(@"addEditBoat.alertview.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
        return;
        
    }
    
    // shows some loading view so the user can see that is saving
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    BOOL newEvent = NO;
    
    if (!self.event) {
        //Create new event
        Event *event = [Event object];
        self.event.deleted = @(NO);
        self.event = event;
        newEvent = YES;
        
    }
    
    
    NSInteger numberOfUsersAttending = 0;
    
    if(!newEvent) {    
        // Check for user seats request
        for (SeatRequest *request in self.event.seatRequests) {
            if(![request isEqual:[NSNull null]]) {
                if ([request.status integerValue] == SeatRequestStatusAccepted) {
                    numberOfUsersAttending += [request.numberOfSeats integerValue];
                }
            }
            
        }
    }
    
    self.event.name = self.eventName;
    self.event.price = [f numberFromString:self.pricePerSeat];
    self.event.boat = self.selectedBoat;
    self.event.activities = self.selectedActivities;
    self.event.pickupLocation = self.pickupLocation;
    self.event.locationName = self.locationString;
    self.event.startsAt = self.pickUpTime;
    self.event.endDate = self.endTime;
    self.event.alcoholPermitted = self.familyContent[kAlcoholPermitted];
    self.event.smokingPermitted = self.familyContent[kSmokingPermitted];
    self.event.childrenPermitted = self.familyContent[kChildrenPermitted];
    self.event.availableSeats = @(self.availableSeats);
    self.event.freeSeats = @(self.availableSeats - numberOfUsersAttending);
    self.event.host = [User currentUser];
    self.event.status = @(status);
    self.event.eventDescription = self.eventDescription;
    
    // saving the user in background
    [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (newEvent) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditEvent.createdAlert.title", nil)
                                                                  message:NSLocalizedString(@"addEditEvent.createdAlert.message", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
        }
        
        // dismiss loading view
        [SVProgressHUD dismiss];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
}

#pragma mark - Get Boats

- (void) getBoatsData {
    
    User *user = [User currentUser];
    
    [self addActivityViewforView:self.contentView];
    
    PFQuery *query = [Boat query];
    [query includeKey:@"safetyFeatures"];
    [query includeKey:@"rejectionMessage"];
    
    [query orderByAscending:@"name"];
    
    [query whereKey:@"owner" equalTo:user];
    [query whereKey:@"deleted" notEqualTo:@(YES)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *boats, NSError *error) {
        
        [self removeActivityViewFromView:self.contentView];
        
        if (!error) {
            
            if(boats.count) {
                
                Boat *approvedBoat = nil;
                
                for (Boat *boat in boats) {
                    if ([boat.status intValue] == BoatStatusApproved) {
                        if (!approvedBoat) {
                            approvedBoat = boat;
                        }
                        else {
                            return;
                        }
                    }
                }
                
                self.selectedBoat = approvedBoat;
                
                [self.tableView reloadData];
                
            }
            
        }
        
    }];
    
}

@end
