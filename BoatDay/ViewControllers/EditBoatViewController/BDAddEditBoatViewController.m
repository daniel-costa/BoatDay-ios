//
//  BDEditBoatViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDAddEditBoatViewController.h"
#import "UIImage+Resize.h"
#import "SVProgressHUD.h"
#import "SMPageControl.h"
#import "WCActionSheet.h"
#import "ActionSheetStringPicker.h"

#import "BDEditBoatDefaultCell.h"
#import "BDEditBoatFirstRowCell.h"
#import "BDSafetyFeaturesListViewController.h"
#import "BDLocationViewController.h"
#import "BDBoatInsuranceViewController.h"
#import "UIAlertView+Blocks.h"
#import "BDPaymentInfoViewController.h"

static NSInteger const kMaximumNumberOfPictures = 5;
static NSInteger const kMinumumDateYear = 1920;

@interface BDAddEditBoatViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, BDLocationViewControllerDelegate>

@property (strong, nonatomic) NSString *boatName;
@property (strong, nonatomic) NSString *boatType;
@property (strong, nonatomic) NSString *boatLenght;
@property (strong, nonatomic) NSString *boatCapacity;
@property (strong, nonatomic) NSString *boatBuildYear;

@property (strong, nonatomic) PFFile *insuranceFile;
@property (strong, nonatomic) NSDate *insuranceExpirationDate;
@property (strong, nonatomic) NSString *insuranceMinimumCoverage;

// Data
@property (strong, nonatomic) Boat *boat;

@property (strong, nonatomic) PFGeoPoint *boatLocation;

// Old Data (if user cancel the editing, we reset the values to these old values)
@property (strong, nonatomic) Boat *oldBoat;

@property (strong, nonatomic) NSMutableArray *oldSafetyFeatures;
@property (strong, nonatomic) NSMutableArray *safetyFeatures;

// View
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSIndexPath *editingIndexPath;

// Horizontal ScrollView
@property (strong, nonatomic) SMPageControl *pageControl;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UILabel *addPhotoLabel;

@property (strong, nonatomic) NSMutableArray *imagesArray;

@property (strong, nonatomic) NSMutableArray *imageButtonsArray;

@property (strong, nonatomic) NSMutableArray *closeButtonsArray;

@property (strong, nonatomic) NSMutableArray *selectedButtonsArray;

@property (nonatomic) NSInteger selectedPictureIndex;

// Gesture Recognizer (for keyboardy dismiss)
@property (strong, nonatomic) UITapGestureRecognizer *tap;

// Footer View
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteDraftButton;

// Methods
- (IBAction)bottomButtonPressed:(id)sender;
- (IBAction)deleteDraftButtonPressed:(id)sender;

@end

@implementation BDAddEditBoatViewController

- (instancetype)initWithBoat:(Boat *)boat {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _boat = boat;
    
    if (boat) {
        _boatName = boat.name;
        _boatType = boat.type;
        _boatLenght = [boat.length stringValue];
        _boatCapacity = [boat.passengerCapacity stringValue];
        _boatBuildYear = [boat.buildYear stringValue];
        _insuranceExpirationDate = boat.insuranceExpirationDate;
        _insuranceMinimumCoverage = boat.insuranceMinimumCoverage;
        
        _insuranceFile = boat.insurance;
        
        _boatLocation = boat.location;
        _locationString = boat.locationString;
        
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.screenName =@"BDAddEditBoatViewController";

    // set user data
    self.imagesArray = [self.boat.pictures mutableCopy];
    
    // make a new copy in order to reset user if this view is canceled
    self.oldBoat = (Boat*)[self.boat copyShallow];
    if (self.oldBoat.safetyFeatures.count) {
        self.oldSafetyFeatures = [self.oldBoat.safetyFeatures mutableCopy];
        self.safetyFeatures = [self.oldBoat.safetyFeatures mutableCopy];
    }
    
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
    
    self.deleteDraftButton.hidden = YES;
    
    if (self.boat) {
        if (self.boat && [self.boat.status intValue] == BoatStatusNotSubmited) {
            
            self.title = NSLocalizedString(@"addEditBoat.add.title", nil);
            
            [self.bottomButton setTitle:NSLocalizedString(@"addEditBoat.submit", nil) forState:UIControlStateNormal];
            self.bottomButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
            [self.bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [self.bottomButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_off"] forState:UIControlStateNormal];
            [self.bottomButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_on"] forState:UIControlStateHighlighted];
            
            self.deleteDraftButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
            [self.deleteDraftButton setTitleColor:[UIColor lightGrayBoatDay] forState:UIControlStateNormal];
            [self.deleteDraftButton setTitle:NSLocalizedString(@"addEditBoat.deleteDraftBoat", nil) forState:UIControlStateNormal];
            [self.deleteDraftButton setBackgroundImage:[UIImage imageNamed:@"button_lg_red_off"] forState:UIControlStateNormal];
            [self.deleteDraftButton setBackgroundImage:[UIImage imageNamed:@"button_lg_red_on"] forState:UIControlStateHighlighted];
            
            self.deleteDraftButton.hidden = NO;
        } else {
            self.boatLocation = self.boat.location;
            self.selectedPictureIndex = [self.boat.selectedPictureIndex integerValue];
            
            self.title = NSLocalizedString(@"addEditBoat.edit.title", nil);
            [self.bottomButton setTitle:NSLocalizedString(@"addEditBoat.deleteButton", nil) forState:UIControlStateNormal];
            self.bottomButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
            [self.bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [self.bottomButton setBackgroundImage:[UIImage imageNamed:@"button_lg_red_off"] forState:UIControlStateNormal];
            [self.bottomButton setBackgroundImage:[UIImage imageNamed:@"button_lg_red_on"] forState:UIControlStateHighlighted];
            setFrameHeight(self.footerView, 72);
        }
    } else {
        self.title = NSLocalizedString(@"addEditBoat.add.title", nil);
        [self.bottomButton setTitle:NSLocalizedString(@"addEditBoat.submit", nil) forState:UIControlStateNormal];
        self.bottomButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
        [self.bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.bottomButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_off"] forState:UIControlStateNormal];
        [self.bottomButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_on"] forState:UIControlStateHighlighted];
        setFrameHeight(self.footerView, 72);
    }
    
    self.tableView.tableFooterView = self.footerView;
    
    // setup our image gallery
    [self setupPhotosHorizontalScrollView];
    
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
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDEditBoatFirstRowCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDEditBoatFirstRowCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.delaysContentTouches = YES;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}

- (void) setupNavigationBar {
    
    self.title = NSLocalizedString(@"addEditBoat.edit.title", nil);
    
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
    
    // all the modifications must be discarded
    // we reset all simple values, activities and certifications
    [self.boat resetValuesToObject:self.oldBoat];
    self.boat.safetyFeatures = self.oldSafetyFeatures;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) saveButtonPressed {
    
    BoatStatus newBoatStatus = self.boat ? [self.boat.status integerValue] : BoatStatusNotSubmited;
    [self saveWithStatus:newBoatStatus];
    
}

- (void) saveWithStatus:(BoatStatus)boatStatus {
    
    [self dismissKeyboard];
    
    
    if ([NSString isStringEmpty:self.boatName] ||
        [NSString isStringEmpty:self.boatType] ||
        [NSString isStringEmpty:self.boatLenght] ||
        [NSString isStringEmpty:self.boatCapacity] ||
        [NSString isStringEmpty:self.boatBuildYear] ||
        !self.boatLocation) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.alertview.title", nil)
                                                              message:NSLocalizedString(@"addEditBoat.alertview.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
        
    }
    
    if (boatStatus != BoatStatusNotSubmited) {
        
        if (self.imagesArray.count == 0) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.pictureReqlertview.title", nil)
                                                                  message:NSLocalizedString(@"addEditBoat.pictureReqlertview.message", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            return;
            
        }
        
        if (!self.insuranceFile) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.insuranceAlertview.title", nil)
                                                                  message:NSLocalizedString(@"addEditBoat.insuranceAlertview.message", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            return;
            
        }
        
    }
    
    if (self.boatLenght && ![self.boatLenght isNumeric]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.lenghtNumAlertview.title", nil)
                                                              message:NSLocalizedString(@"addEditBoat.lenghtNumAlertview.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
        
    }
    
    if (self.boatCapacity && ![self.boatCapacity isNumeric]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.capacityNumAlertview.title", nil)
                                                              message:NSLocalizedString(@"addEditBoat.capacityNumAlertview.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
        
    }
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];

    // shows some loading view so the user can see that is saving
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    BOOL newBoat = NO;
    
    if (self.boat) {
        
        self.boat.name = self.boatName ?: @"No Name";
        self.boat.type = self.boatType ?: @"No Type";
        self.boat.length = [f numberFromString:self.boatLenght] ?: @(0);
        self.boat.passengerCapacity = [f numberFromString:self.boatCapacity] ?: @(0);
        self.boat.buildYear = [f numberFromString:self.boatBuildYear] ?: @(0);
        self.boat.location = self.boatLocation;
        self.boat.locationString = self.locationString;
        self.boat.pictures = self.imagesArray;
        self.boat.selectedPictureIndex = @(self.selectedPictureIndex);
        self.boat.safetyFeatures = self.safetyFeatures ?: [[NSMutableArray alloc] init];
        self.boat.insurance = self.insuranceFile;
        self.boat.insuranceExpirationDate = self.insuranceExpirationDate;
        self.boat.insuranceMinimumCoverage = self.insuranceMinimumCoverage;
        self.boat.status = @(boatStatus);
        
    } else {
        
        newBoat = YES;
        Boat *newBoat = [Boat object];
        
        newBoat.name = self.boatName ?: @"No Name";
        newBoat.type = self.boatType ?: @"No Type";
        newBoat.length = [f numberFromString:self.boatLenght] ?: @(0);
        newBoat.passengerCapacity = [f numberFromString:self.boatCapacity] ?: @(0);
        newBoat.buildYear = [f numberFromString:self.boatBuildYear] ?: @(0);
        newBoat.owner = [User currentUser];
        newBoat.location = self.boatLocation;
        newBoat.locationString = self.locationString;
        newBoat.status = @(boatStatus);
        newBoat.rejectionMessage = nil;
        newBoat.pictures = self.imagesArray;
        newBoat.selectedPictureIndex = @(self.selectedPictureIndex);
        newBoat.safetyFeatures = self.safetyFeatures ?: [[NSMutableArray alloc] init];
        newBoat.insurance = self.insuranceFile;
        newBoat.insuranceExpirationDate = self.insuranceExpirationDate;
        newBoat.insuranceMinimumCoverage = self.insuranceMinimumCoverage;
        
        self.boat = newBoat;
        
    }
    
    self.boat.deleted = @(NO);
    
    // saving the user in background
    [self.boat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // dismiss loading view
        [SVProgressHUD dismiss];
        
        if (succeeded) {
            
            if (boatStatus == BoatStatusPending) {
                
                // no payment info
                if ([NSString isStringEmpty:[Session sharedSession].hostRegistration.merchantId]) {
                    
                    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.createdAlert.title", nil)
                                                                          message:NSLocalizedString(@"addEditBoat.gotoPaymentInfo.message", nil)
                                                                         delegate:nil
                                                                cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                                otherButtonTitles: nil];
                    
                    [myAlertView show];
                    
                }
                else {
                    
                    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.createdAlert.title", nil)
                                                                          message:NSLocalizedString(@"addEditBoat.createdAlert.message", nil)
                                                                         delegate:nil
                                                                cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                                otherButtonTitles: nil];
                    
                    [myAlertView show];
                    
                }
                
                
            }
            
            if (boatStatus != BoatStatusNotSubmited && [NSString isStringEmpty:[Session sharedSession].hostRegistration.merchantId]) {
                
                BDPaymentInfoViewController *paymentController = [[BDPaymentInfoViewController alloc] initWithRegistrationBoat:self.boat];
                
                [self.navigationController setViewControllers:@[paymentController] animated:YES];
                
            }
            else {
                
                [self dismissViewControllerAnimated:NO completion:nil];
                
            }
            
        } else {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.notCreatedAlert.title", nil)
                                                                  message:NSLocalizedString(@"addEditBoat.notCreatedAlert.message", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
        }
        
        
    }];
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: // first row: first and last name, location and birthday date
            return 234.0;
        default:
            return 60.0;
            break;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([self.boat.status integerValue] == BoatStatusApproved)
        return 1;
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            // first row: first and last name, location and birthday date
            return [self firstRowCellForIndexPath:indexPath];
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
        case 1:
            cell.textLabel.text = NSLocalizedString(@"addEditBoat.safetyFeatures", nil);
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"addEditBoat.proofOfInsurance", nil);
            
            break;
        default:
            break;
    }
    
    return cell;
    
}

- (UITableViewCell *) firstRowCellForIndexPath:(NSIndexPath*)indexPath {
    
    BDEditBoatFirstRowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDEditBoatFirstRowCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.boatNameLabel.text = NSLocalizedString(@"addEditBoat.boatName", nil);
    cell.boatNameTextField.text = self.boatName;
    cell.boatNameTextField.delegate = self;
    cell.boatNameTextField.tag = 1;
    
    cell.locationLabel.text = NSLocalizedString(@"addEditBoat.location", nil);
    [cell.locationButton setTitle:self.locationString forState:UIControlStateNormal];
    [cell.locationButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.locationButton addTarget:self action:@selector(locationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    cell.typeLabel.text = NSLocalizedString(@"addEditBoat.type", nil);
    cell.typeTextField.text = self.boatType;
    cell.typeTextField.delegate = self;
    cell.typeTextField.tag = 2;
    
    cell.lengthLabel.text = NSLocalizedString(@"addEditBoat.length", nil);
    cell.lengthTextField.text = self.boatLenght;
    cell.lengthTextField.delegate = self;
    cell.lengthTextField.tag = 3;
    cell.lengthTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    cell.capacityLabel.text = NSLocalizedString(@"addEditBoat.capacity", nil);
    cell.capacityTextField.text = self.boatCapacity;
    cell.capacityTextField.delegate = self;
    cell.capacityTextField.tag = 4;
    cell.capacityTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    cell.buildYearNameLabel.text = NSLocalizedString(@"addEditBoat.buildYear", nil);
    [cell.buildYearButton setTitle:self.boatBuildYear forState:UIControlStateNormal];
    [cell.buildYearButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.buildYearButton addTarget:self action:@selector(buildYearButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.boat.status integerValue] == BoatStatusApproved) {
        cell.userInteractionEnabled = NO;
        cell.lengthTextField.textColor = [UIColor grayBoatDay];
        cell.capacityTextField.textColor = [UIColor grayBoatDay];
        cell.typeTextField.textColor = [UIColor grayBoatDay];
        cell.boatNameTextField.textColor = [UIColor grayBoatDay];
        cell.locationButton.enabled = NO;
        cell.buildYearButton.enabled = NO;
    }

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
    
    
    switch (indexPath.row) {
        case 1:
        {
            BDSafetyFeaturesListViewController *safetyFeatureViewController = [[BDSafetyFeaturesListViewController alloc] initWithSelectedSafetyFeatures:self.safetyFeatures];
            
            [safetyFeatureViewController setSafetyFeaturesArrayBlock:^(NSMutableArray *safetyFeatures) {
                
                self.safetyFeatures = safetyFeatures;
                
            }];
            
            [self.navigationController pushViewController:safetyFeatureViewController animated:YES];
        }
            break;
        case 2:
        {
            BDBoatInsuranceViewController *insuranceViewController = [[BDBoatInsuranceViewController alloc] initWithBoat:self.boat];
            
            [insuranceViewController setInsuranceBlock:^(PFFile *insurance, NSDate *insuranceExpirationDate, NSString *insuranceMinimumCoverage){
                
                self.insuranceFile = insurance;
                self.insuranceExpirationDate = insuranceExpirationDate;
                self.insuranceMinimumCoverage = insuranceMinimumCoverage;
                
            }];
            
            UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:insuranceViewController];
            
            [self presentViewController:navigationController animated:YES completion:nil];
        }
            break;
            
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == 1) {
        self.boatName = textField.text;
    }
    
    if (textField.tag == 2) {
        self.boatType = textField.text;
    }
    
    if (textField.tag == 3) {
        self.boatLenght = textField.text;
    }
    
    if (textField.tag == 4) {
        self.boatCapacity = textField.text;
    }
    
    if (textField.tag == 5) {
        self.boatBuildYear = textField.text;
    }
    
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

#pragma mark - User Photos ScrollView Methods

- (void) setupPhotosHorizontalScrollView {
    
    self.imageButtonsArray = [[NSMutableArray alloc] init];
    self.closeButtonsArray = [[NSMutableArray alloc] init];
    self.selectedButtonsArray = [[NSMutableArray alloc] init];
    
    // Create Horizontal ScrollView
    CGFloat imageGalleryHeight = 194.0;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.frame), imageGalleryHeight)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.pagingEnabled = NO;
    self.scrollView.delegate = self;
    
    CGFloat ySpace = 36.0; // Top and Bottom Space
    CGFloat xSpace = 50.0; // margins and space between images
    CGFloat x = 60.0;
    CGFloat y = ySpace;
    CGFloat height = 121.0; // Image Height
    CGFloat width = 200.0;  // Image Width
    
    // For each image add to ScrollView
    for (int i = 0; i <  self.imagesArray.count + 1; i++) {
        
        UIButton *imageButton = [[UIButton alloc] init];
        imageButton.tag = i;
        imageButton.backgroundColor = [UIColor clearColor];
        [imageButton addTarget:self action:@selector(imageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [imageButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.scrollView addSubview:imageButton];
        [self.imageButtonsArray addObject:imageButton];
        
        if (i == 0) {
            
            imageButton.frame = CGRectMake(x + 22.5, y + 3, 155.0, 115.0);
            
            
        } else {
            
            imageButton.frame = CGRectMake(x, y, width, height);
            
        }
        
        CGFloat closeButtonSize = 29.0;
        UIButton *closeButton = [[UIButton alloc] init];
        closeButton.tag = i;
        closeButton.backgroundColor = [UIColor clearColor];
        
        closeButton.frame = CGRectMake(x + imageButton.frame.size.width - (closeButtonSize / 2.0),
                                       y - (closeButtonSize / 2.0),
                                       closeButtonSize,
                                       closeButtonSize);
        
        [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"photo_delete"] forState:UIControlStateNormal];
        [self.scrollView addSubview:closeButton];
        [self.closeButtonsArray addObject:closeButton];
        
        CGFloat selectedPhotoButtonSize = 29.0;
        UIButton *selectedPhotoButton = [[UIButton alloc] init];
        selectedPhotoButton.tag = i;
        selectedPhotoButton.backgroundColor = [UIColor clearColor];
        
        selectedPhotoButton.frame = CGRectMake(x - (closeButtonSize / 2.0),
                                               y + imageButton.frame.size.height - (closeButtonSize / 2.0),
                                               selectedPhotoButtonSize,
                                               selectedPhotoButtonSize);
        
        [selectedPhotoButton setBackgroundImage:[UIImage imageNamed:@"photo_selected"] forState:UIControlStateNormal];
        selectedPhotoButton.userInteractionEnabled = NO;
        [self.scrollView addSubview:selectedPhotoButton];
        [self.selectedButtonsArray addObject:selectedPhotoButton];
        
        // next x
        x += width + xSpace;
        
    }
    
    // update content size
    [self.scrollView setContentSize:CGSizeMake(x, self.scrollView.frame.size.height)];
    
    self.addPhotoLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                    CGRectGetMaxY(self.scrollView.frame),
                                                                    self.tableView.frame.size.width,
                                                                    22.0)];
    self.addPhotoLabel.backgroundColor = RGB(4.0, 29.0, 33.0);
    self.addPhotoLabel.textColor = [UIColor whiteColor];
    self.addPhotoLabel.font = [UIFont quattroCentoRegularFontWithSize:12.0];
    self.addPhotoLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                               0.0,
                                                               self.tableView.frame.size.width,
                                                               self.scrollView.frame.size.height + self.addPhotoLabel.frame.size.height)];
    
    
    self.tableView.tableHeaderView = topView;
    
    self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0.0,
                                                                       CGRectGetMaxY(self.scrollView.frame) - 15.0 - 5.0,
                                                                       self.scrollView.frame.size.width,
                                                                       15.0)];
    
    self.pageControl.numberOfPages =  self.imagesArray.count + 1;
    self.pageControl.pageIndicatorImage = [UIImage imageNamed:@"photo_pag_off"];
    self.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"photo_pag_on"];
    [self.pageControl setImage:[UIImage imageNamed:@"photo_pag_add_off"] forPage:0];
    [self.pageControl setCurrentImage:[UIImage imageNamed:@"photo_pag_add_on"] forPage:0];
    self.pageControl.tapBehavior = SMPageControlTapBehaviorJump;
    self.pageControl.userInteractionEnabled = NO;
    
    [topView addSubview:self.scrollView];
    [topView addSubview:self.addPhotoLabel];
    [topView addSubview:self.pageControl];
    
    [self updateImagesInGallery];
    
}

- (void) imageButtonPressed:(id)sender {
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"imageButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    UIButton *imageButton = (UIButton*)sender;
    
    if (imageButton.tag == 0) {
        
        if (self.selectedButtonsArray.count < kMaximumNumberOfPictures + 1) {
            
            [self dismissKeyboard];
            
            WCActionSheet *actionSheet = [[WCActionSheet alloc] init];
            [actionSheet addButtonWithTitle:NSLocalizedString(@"actionSheet.takePhoto", nil) actionBlock:^{
                [self takePhoto];
            }];
            
            [actionSheet addButtonWithTitle:NSLocalizedString(@"actionSheet.chooseFromGallery", nil) actionBlock:^{
                [self choosePhotofromLibrary];
                
            }];
            [actionSheet show];
            
        } else {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.maxPhotosAlert.title", nil)
                                                                  message:NSLocalizedString(@"addEditBoat.maxPhotosAlert.message", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
        }
        
    } else {
        
        NSInteger index = imageButton.tag;
        
        UIButton *oldSelectedButton = self.selectedButtonsArray[self.selectedPictureIndex+1];
        oldSelectedButton.hidden = YES;
        
        UIButton *selectedButton = self.selectedButtonsArray[index];
        selectedButton.hidden = NO;
        
        self.selectedPictureIndex = index-1;
        
    }
    
}

- (void) closeButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"closeButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    UIButton *imageButton = (UIButton*)sender;
    NSInteger index = imageButton.tag-1;
    
    [self.imagesArray removeObjectAtIndex:index];
    
    if (self.selectedPictureIndex == index) {
        self.selectedPictureIndex = 0;
    }
    
    [self setupPhotosHorizontalScrollView];
    
}

- (void) updateImagesInGallery  {
    
    // Update images
    for (int i = 0; i < self.imageButtonsArray.count; i++) {
        
        UIButton *imageButton = self.imageButtonsArray[i];
        UIButton *closeButton = self.closeButtonsArray[i];
        UIButton *selectedButton = self.selectedButtonsArray[i];
        
        if (i == 0) {
            
            [imageButton setBackgroundImage:[UIImage imageNamed:@"photo_add_profile"] forState:UIControlStateNormal];
            
            closeButton.hidden = YES;
            selectedButton.hidden = YES;
            
        } else {
            
            [imageButton setBackgroundImage:[UIImage imageNamed:@"boatPhotoCoverPlaceholder"] forState:UIControlStateNormal];
            closeButton.hidden = NO;
            
            selectedButton.hidden = self.selectedPictureIndex != i-1;
            
            // Put placeholder if we got no images
            if (self.imagesArray.count > i-1) {
                
                PFFile *theImage = self.imagesArray[i-1];
                
                // Get image from cache or from server if isnt available (background task)
                [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    UIImage *image = [UIImage imageWithData:data];
                    
                    [imageButton setBackgroundImage:image forState:UIControlStateNormal];
                    
                    closeButton.hidden = NO;
                    
                }];
                
            }
            
        }
        
        imageButton.imageView.contentMode = UIViewContentModeScaleAspectFill; //this is needed for some reason, won't work without it.
        for(UIView *view in imageButton.subviews) {
            view.contentMode = UIViewContentModeScaleAspectFill;
        }
        
    }
    
    if (self.imagesArray.count) {
        self.addPhotoLabel.text = NSLocalizedString(@"addEditBoat.swipePhotoMessage", nil);
    }
    else {
        self.addPhotoLabel.text = NSLocalizedString(@"addEditBoat.addPhotoMessage", nil);
    }
    
}

#pragma mark - PPChooseOptionsViewController Delegate Methods

- (void)choosePhotofromLibrary {
    
    // Open Picker from Photo Library
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)takePhoto {
    
    // If the device has camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        // Open Picker from Camera
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }
    else {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorMessages.noCamera.title", nil)
                                                              message:NSLocalizedString(@"errorMessages.noCamera.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    
}

#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    // Resizing image
    [chosenImage imageByScalingToSize:CGSizeMake(180, 180)];
    
    // Updating user pictures
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    NSString *myUniqueName = [NSString stringWithFormat:@"BoatImage_%@%@-%lu", [User currentUser].firstName, [User currentUser].lastName, (unsigned long)([[NSDate date] timeIntervalSince1970]*10.0)];
    
    PFFile *imageFile = [PFFile fileWithName:myUniqueName data:imageData];
    
    [imageFile saveInBackground];
    
    if (!self.imagesArray) {
        self.imagesArray = [[NSMutableArray alloc] init];
    }
    
    // add image to array
    [self.imagesArray addObject:imageFile];
    
    // update images
    [self setupPhotosHorizontalScrollView];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - ScrollView Delegate Methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSInteger pageWidth = 240.0; //self.scrollView.contentSize.width / self.pageControl.numberOfPages;
    
    NSInteger currentPage = self.scrollView.contentOffset.x / pageWidth;
    
    self.pageControl.currentPage = currentPage;
    
}

#pragma mark - Action Methods

- (void) buildYearButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"buildYearButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    int thisYear  = [[formatter stringFromDate:[NSDate date]] intValue];
    
    // Create an array of strings we want to show in the picker:
    NSMutableArray *years = [[NSMutableArray alloc] init];
    for (int year = thisYear; year <=thisYear & year >= kMinumumDateYear; year--) {
        [years addObject:[NSString stringWithFormat:@"%d",year]];
    }
    
    NSInteger selectedIndex = self.boatBuildYear ? [years indexOfObject:self.boatBuildYear] : 0;
    
    ActionSheetStringPicker *action = [[ActionSheetStringPicker alloc]
                                       initWithTitle:nil
                                       rows:years
                                       initialSelection:selectedIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           self.boatBuildYear = (NSString*)selectedValue;
                                           [self.tableView reloadData];
                                           //[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:(UITableViewRowAnimationFade)];
                                           
                                       }
                                       cancelBlock:^(ActionSheetStringPicker *picker) {
                                                                                      
                                       }
                                       origin:self.view];
    
    [action showActionSheetPicker];
    [action.toolbar setTintColor:[UIColor greenBoatDay]];
    [action.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
}

- (void) locationButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"locationButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    BDLocationViewController *editBoatViewController = [[BDLocationViewController alloc] initWithPFGeoPoint:self.boatLocation];
    editBoatViewController.delegate = self;
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:editBoatViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (IBAction)bottomButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"bottomButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    if (self.boat) {
        
        if ([self.boat.status intValue] == BoatStatusNotSubmited) {
            
            // to submit
            [self saveWithStatus:BoatStatusPending];
            
        } else {
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.deleteVerification", nil)
                                        message:NSLocalizedString(@"addEditBoat.deleteMessage", nil)
                               cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.noButton", nil) action:nil]
                               otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.yesButton", nil) action:^{
                
                [self deleteBoatWithEventsVerification];
                
            }], nil] show];
            
        }
        
    } else {
        
        [self saveWithStatus:BoatStatusPending];
        
    }
    
}

- (void) deleteBoatWithEventsVerification {
    
    PFQuery *query = [Event query];
    [query whereKey:@"boat" equalTo:self.boat];
    [query whereKey:@"status" equalTo:@(EventStatusApproved)];
    [query whereKey:@"deleted" notEqualTo:@(YES)];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!object) {
            
            // to delete
            self.boat.deleted = @(YES);
            
            [self.boat saveEventually:^(BOOL succeeded, NSError *error) {
                
                if (self.boatDeletedBlock) {
                    self.boatDeletedBlock();
                }
                
                // dismiss loading view
                [SVProgressHUD dismiss];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }];
            
        }
        else {
            
            [SVProgressHUD dismiss];
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorMessages.noCamera.title", nil)
                                                                  message:NSLocalizedString(@"addEditBoat.deleteError.gotEvent.message", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
        }
        
    }];
    
}

- (IBAction)deleteDraftButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"deleteDraftButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.deleteVerification", nil)
                                message:NSLocalizedString(@"addEditBoat.deleteMessage", nil)
                       cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.noButton", nil) action:nil]
                       otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.yesButton", nil) action:^{
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        // to delete
        self.boat.deleted = @(YES);
        
        [self.boat saveEventually:^(BOOL succeeded, NSError *error) {
            
            if (self.boatDeletedBlock) {
                self.boatDeletedBlock();
            }
            
            // dismiss loading view
            [SVProgressHUD dismiss];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
    }], nil] show];
    
}

#pragma mark - BDLocation Delegate Methods

- (void)changedLocation:(PFGeoPoint*)location withLocationString:(NSString*)locationString {
    
    self.locationString = locationString ?: self.locationString;
    self.boat.location = location;
    self.boatLocation = location;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:(UITableViewRowAnimationFade)];
    
}

@end
