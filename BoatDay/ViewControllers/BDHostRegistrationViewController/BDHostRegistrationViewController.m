//
//  BDHostRegistrationViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 03/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDHostRegistrationViewController.h"
#import "WCActionSheet.h"
#import "BDEditBoatDefaultCell.h"
#import "BDHostRegistrationFirstRowCell.h"
#import "BDCertificationListViewController.h"
#import "BDHostRegistrationTermsViewController.h"
#import "ActionSheetStringPicker.h"
#import "NSString+USStateMap.h"
#import "NBAsYouTypeFormatter.h"
#import "ActionSheetDatePicker.h"
#import "UIAlertView+Blocks.h"

typedef NS_ENUM(NSUInteger, HostRegistrationField) {
    
    HostRegistrationFieldFirstName = 1,
    HostRegistrationFieldLastName,
    HostRegistrationFieldFirstAddress,
    HostRegistrationFieldCity,
    HostRegistrationFieldState,
    HostRegistrationFieldZipCode,
    HostRegistrationFieldEmail,
    HostRegistrationFieldPhoneNumber
    
};

static NSInteger const kPhoneMaximumCharacters = 14;
static NSInteger const kZipCodeMaximumCharacters = 5;

@interface BDHostRegistrationViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *pictureView;
@property (weak, nonatomic) IBOutlet UIImageView *driversLicenseImageView;

@property (strong, nonatomic) NSIndexPath *editingIndexPath;

// Gesture Recognizer (for keyboardy dismiss)
@property (strong, nonatomic) UITapGestureRecognizer *tap;

// Date Picker
@property (nonatomic, strong) ActionSheetDatePicker *actionSheetPicker;

@property (strong, nonatomic) NBAsYouTypeFormatter *numberFormatter;

// data
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) PFFile *driversLicenseFile;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSDate *birthdayDate;
@property (strong, nonatomic) NSString *firstAddressLine;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *zipCode;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) UIImage *driversLicenseImage;

- (IBAction)addPictureButtonPressed:(id)sender;

@end

@implementation BDHostRegistrationViewController

- (instancetype)init{
    
    self = [super init];
    
    if( !self ) return nil;
    
    _user = [User currentUser];
    
    if (_user) {
        _firstName = _user.firstName;
        _lastName = _user.lastName;
        _birthdayDate = _user.birthday;
        _firstAddressLine = _user.firstLineAddress;
        _city = _user.city;
        _state = _user.state;
        _zipCode = _user.zipCode;
        _email = _user.email;
        _phoneNumber = _user.phoneNumber;
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"hostRegistration.title", nil);
    
    [self setupNavigationBar];
    
    // setup view
    [self setupTableView];
    
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

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDHostRegistrationFirstRowCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDHostRegistrationFirstRowCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.tableView.tableHeaderView = self.pictureView;
    
    [self setupHostRegistrationImageView];
    
}

- (void) setupHostRegistrationImageView {
    
    self.driversLicenseFile = [Session sharedSession].hostRegistration.driversLicenseImage;
    
    [self.driversLicenseFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            [self setDriversLicenseImageFile:image];
        }
    }];
    
}

- (void) setupNavigationBar {
    
    // create save button to navigatio bar at top of the view
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"hostRegistration.next", nil)
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(nextButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = nextButton;
    
}

#pragma mark - Action Methods

- (void) nextButtonPressed {
    
    if ([NSString isStringEmpty:self.firstName] ||
        [NSString isStringEmpty:self.lastName] ||
        !self.birthdayDate ||
        [NSString isStringEmpty:self.firstAddressLine] ||
        [NSString isStringEmpty:self.city] ||
        [NSString isStringEmpty:self.state] ||
        [NSString isStringEmpty:self.zipCode] ||
        [NSString isStringEmpty:self.email] ||
        [NSString isStringEmpty:self.phoneNumber]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.alertview.title", nil)
                                                              message:NSLocalizedString(@"addEditBoat.alertview.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
        
    }
    
    if (!self.driversLicenseImage) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hostRegistration.alertview.title", nil)
                                                              message:NSLocalizedString(@"hostRegistration.alertview.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
        
    }
    
    
    if (self.phoneNumber.length != kPhoneMaximumCharacters) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hostRegistration.phoneNumberAlertView.title", nil)
                                                              message:NSLocalizedString(@"hostRegistration.phoneNumberAlertView.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
        
    }
    
    if (self.zipCode.length != kZipCodeMaximumCharacters || ![self.zipCode isNumeric]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hostRegistration.zipCodeAlertView.title", nil)
                                                              message:NSLocalizedString(@"hostRegistration.zipCodeAlertView.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
        
    }
    
    
    if (![self.email isValidEmail]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hostRegistration.emailAlertView.title", nil)
                                                              message:NSLocalizedString(@"hostRegistration.emailAlertView.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
        
    }
    
    NSDictionary *hostRegistrationDictionary = @{@"firstName": self.firstName ?: @"",
                                                 @"lastName": self.lastName ?: @"",
                                                 @"birthdayDate": self.birthdayDate ?: @"",
                                                 @"firstAddressLine": self.firstAddressLine ?: @"",
                                                 @"city": self.city ?: @"",
                                                 @"state": self.state ?: @"",
                                                 @"zipCode": self.zipCode ?: @"",
                                                 @"email": self.email ?: @"",
                                                 @"phoneNumber": self.phoneNumber ?: @"",
                                                 @"driversLicenseFile": self.driversLicenseFile
                                                 };
    
    BDHostRegistrationTermsViewController *hostRegistrationTermsViewController = [[BDHostRegistrationTermsViewController alloc] initWithHostRegistrationDictionary:hostRegistrationDictionary];
    [self.navigationController pushViewController:hostRegistrationTermsViewController animated:YES];
    
}

#pragma mark - UITableView Datasource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            return 400.0;
        default:
            return 60.0;
            break;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
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
    
}

- (UITableViewCell *) defaultCellRowForIndexPath:(NSIndexPath*)indexPath {
    
    BDEditBoatDefaultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    
    if (cell == nil) {
        
        cell = [[BDEditBoatDefaultCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"defaultCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor = [UIColor lightGrayBoatDay];
        cell.contentView.backgroundColor = [UIColor lightGrayBoatDay];
        cell.accessoryView.backgroundColor = [UIColor lightGrayBoatDay];
        
        cell.textLabel.font = [UIFont abelFontWithSize:14.0];
        cell.textLabel.textColor = [UIColor grayBoatDay];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        cell.detailTextLabel.font = [UIFont abelFontWithSize:16.0];
        cell.detailTextLabel.textColor = [UIColor greenBoatDay];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        // arrow as cell accessory view
        UIImage *arrowImage = [UIImage imageNamed:@"cell_arrow_green"];
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        CGRect frame = CGRectMake(0.0, 0.0, arrowImage.size.width, arrowImage.size.height);
        arrowImageView.frame = frame;
        arrowImageView.image = arrowImage;
        arrowImageView.backgroundColor = [UIColor clearColor];
        cell.accessoryView = arrowImageView;
        
    }
    
    cell.textLabel.text = NSLocalizedString(@"editProfile.boatingCertifications", nil);
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[[Session sharedSession] getCertificationsApproved], NSLocalizedString(@"editProfile.certifications", nil)];
    
    return cell;
    
}

- (UITableViewCell *) firstRowCellForIndexPath:(NSIndexPath*)indexPath {
    
    BDHostRegistrationFirstRowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDHostRegistrationFirstRowCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.firstNameLabel.text = NSLocalizedString(@"hostRegistration.firstName", nil);
    cell.firstNameTextField.text = self.firstName;
    cell.firstNameTextField.placeholder = NSLocalizedString(@"hostRegistration.firstName.placeholder", nil);
    cell.firstNameTextField.delegate = self;
    cell.firstNameTextField.tag = HostRegistrationFieldFirstName;
    
    cell.lastNameLabel.text = NSLocalizedString(@"hostRegistration.lastName", nil);
    cell.lastNameTextField.text = self.lastName;
    cell.lastNameTextField.placeholder = NSLocalizedString(@"hostRegistration.lastName.placeholder", nil);
    cell.lastNameTextField.delegate = self;
    cell.lastNameTextField.tag = HostRegistrationFieldLastName;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter birthdayDateFormatter];
    NSString *birthday = [dateFormatter stringFromDate:self.birthdayDate] ?: NSLocalizedString(@"hostRegistration.birthday.placeholder", nil);
    
    cell.birthdayLabel.text = NSLocalizedString(@"hostRegistration.birthday", nil);
    [cell.birthdayButton setTitle:birthday forState:UIControlStateNormal];
    [cell.birthdayButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.birthdayButton addTarget:self action:@selector(openDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.firstAddressLineLabel.text = NSLocalizedString(@"hostRegistration.firstAddressLine", nil);
    cell.firstAddressLineTextField.text = self.firstAddressLine;
    cell.firstAddressLineTextField.placeholder = NSLocalizedString(@"hostRegistration.firstAddressLine.placeholder", nil);
    cell.firstAddressLineTextField.delegate = self;
    cell.firstAddressLineTextField.tag = HostRegistrationFieldFirstAddress;
    
    cell.cityLabel.text = NSLocalizedString(@"hostRegistration.city", nil);
    cell.cityTextField.text = self.city;
    cell.cityTextField.placeholder = NSLocalizedString(@"hostRegistration.city.placeholder", nil);
    cell.cityTextField.delegate = self;
    cell.cityTextField.tag = HostRegistrationFieldCity;
    
    cell.stateLabel.text = NSLocalizedString(@"hostRegistration.state", nil);
    [cell.stateButton setTitle:self.state forState:UIControlStateNormal];
    [cell.stateButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.stateButton addTarget:self action:@selector(stateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    cell.zipCodeLabel.text = NSLocalizedString(@"hostRegistration.zipCode", nil);
    cell.zipCodeTextField.text = self.zipCode;
    cell.zipCodeTextField.placeholder = NSLocalizedString(@"hostRegistration.zipCode.placeholder", nil);
    cell.zipCodeTextField.delegate = self;
    cell.zipCodeTextField.tag = HostRegistrationFieldZipCode;
    cell.zipCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    cell.emailLabel.text = NSLocalizedString(@"hostRegistration.email", nil);
    cell.emailTextField.text = self.email;
    NSLog(@"ma jalap ni %@",self.email);
    [cell.emailTextField setText:@"hali"];
    cell.emailTextField.placeholder = NSLocalizedString(@"hostRegistration.email.placeholder", nil);
    cell.emailTextField.delegate = self;
    cell.emailTextField.tag = HostRegistrationFieldEmail;
    cell.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    cell.phoneNumberLabel.text = NSLocalizedString(@"hostRegistration.phoneNumber", nil);
    cell.phoneNumberTextField.text = self.phoneNumber;
    cell.phoneNumberTextField.placeholder = NSLocalizedString(@"hostRegistration.phoneNumber.placeholder", nil);
    cell.phoneNumberTextField.delegate = self;
    cell.phoneNumberTextField.tag = HostRegistrationFieldPhoneNumber;
    cell.phoneNumberTextField.keyboardType = UIKeyboardTypePhonePad;
    
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
    
    if (indexPath.row == 1) {
        BDCertificationListViewController *certificationsViewController = [[BDCertificationListViewController alloc] init];
        [self.navigationController pushViewController:certificationsViewController animated:YES];
    }
    
}

#pragma mark - UITextfield Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField.tag == HostRegistrationFieldPhoneNumber) {
        
        if(textField.text.length + (string.length - range.length) > kPhoneMaximumCharacters ) {
            return NO;
        }
        
        if (!self.numberFormatter) {
            
            self.numberFormatter = [[NBAsYouTypeFormatter alloc] initWithRegionCode:@"US"];
            
        }
        
        if (![NSString isStringEmpty:string]) {
            
            textField.text = [self.numberFormatter inputDigitAndRememberPosition:string];
            
        } else {
            
            if ([self.numberFormatter getRememberedPosition]) {
                
                textField.text = [self.numberFormatter removeLastDigitAndRememberPosition];
                
            }
            else {
                
                textField.text = [self.numberFormatter inputDigitAndRememberPosition:@"1"];
                
            }
            
        }
        
        self.phoneNumber = textField.text;
        
        return NO;
        
    }
    
    return YES;
    
}


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
    
    switch (textField.tag) {
        case HostRegistrationFieldFirstName:
            self.firstName = textField.text;
            break;
        case HostRegistrationFieldLastName:
            self.lastName = textField.text;
            break;
        case HostRegistrationFieldFirstAddress:
            self.firstAddressLine = textField.text;
            break;
        case HostRegistrationFieldCity:
            self.city = textField.text;
            break;
        case HostRegistrationFieldState:
            self.state = textField.text;
            break;
        case HostRegistrationFieldZipCode:
        {
            if ([self checkZipCode:textField.text]) {
                self.zipCode = textField.text;
            }
            else {
                
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hostRegistration.zipCodeOutOfArea.title", nil)
                                            message:NSLocalizedString(@"hostRegistration.zipCodeOutOfArea.message", nil)
                                   cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"errorMessages.ok", nil) action:^{
                    
                    textField.text = @"";
                    self.zipCode = @"";
                    
                    
                }]
                                   otherButtonItems:nil] show];
                
            }
        }
            break;
        case HostRegistrationFieldEmail:
            self.email = textField.text;
            break;
        default:
            break;
    }
    
}

- (BOOL)checkZipCode:(NSString*)zipCode {
    
    NSString *plist = [[NSBundle mainBundle] pathForResource:@"zipcodes" ofType:@"plist"];
    NSArray *counties = [[NSArray alloc] initWithContentsOfFile:plist];
    
    for (NSDictionary *element in counties) {
        
        NSString *zipCodesString = element[@"ZIP Codes"];
        NSArray *zipCodesArray = [zipCodesString componentsSeparatedByString:@" "];
        
        for (NSString *code in zipCodesArray) {
            
            if ([zipCode isEqualToString:code]) {
                return YES;
            }
            
        }
        
    }
    
    return NO;
    
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
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"hostRegistration.uploadingPicture", nil) maskType:SVProgressHUDMaskTypeClear];
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    // Updating user pictures
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    NSString *myUniqueName = [NSString stringWithFormat:@"DriversLicense_%@%@-%lu", [User currentUser].firstName, [User currentUser].lastName, (unsigned long)([[NSDate date] timeIntervalSince1970]*10.0)];
    
    PFFile *imageFile = [PFFile fileWithName:myUniqueName data:imageData];
    
    [self setDriversLicenseImageFile:chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.driversLicenseFile = imageFile;
        
        [SVProgressHUD dismiss];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void) setDriversLicenseImageFile:(UIImage*)theImage {
    
    self.driversLicenseImage = theImage;
    
    [self.driversLicenseImageView setImage:theImage];

    [UIView showViewAnimated:self.driversLicenseImageView withAlpha:YES andDuration:0.3];
    
}

#pragma mark - IBAction Methods

- (IBAction)addPictureButtonPressed:(id)sender {
    
    [self dismissKeyboard];
    
    WCActionSheet *actionSheet = [[WCActionSheet alloc] init];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"actionSheet.takePhoto", nil) actionBlock:^{
        [self takePhoto];
    }];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"actionSheet.chooseFromGallery", nil) actionBlock:^{
        [self choosePhotofromLibrary];
        
    }];
    [actionSheet show];
    
}

#pragma mark - Date Picker Methods

-(void)openDatePicker:(id)sender {
    
    self.actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                           datePickerMode:UIDatePickerModeDate
                                                             selectedDate:self.birthdayDate ?: [NSDate date]
                                                                   target:self
                                                                   action:@selector(dateWasSelected:element:)
                                                                   origin:sender];
    
    
    self.actionSheetPicker.hideCancel = NO;
    [self.actionSheetPicker showActionSheetPicker];
    [self.actionSheetPicker.toolbar setTintColor:[UIColor greenBoatDay]];
    [self.actionSheetPicker.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    
    self.birthdayDate = selectedDate;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter birthdayDateFormatter];
    NSString *birthday = [dateFormatter stringFromDate:[[User currentUser] birthday]];
    
    BDHostRegistrationFirstRowCell *firstRow = (BDHostRegistrationFirstRowCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [firstRow.birthdayButton setTitle:birthday forState:UIControlStateNormal];
    
}

#pragma mark - Address State Methods

- (void) stateButtonPressed {
    
    NSArray *statesArrayDict = [NSString states];
    
    NSMutableArray *statesArray = [[NSMutableArray alloc] init];
    
    for (NSString *state in statesArrayDict) {
        [statesArray addObject:[state capitalizedString]];
    }
    
    NSArray *statesArraySorted = [statesArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSInteger selectedIndex = [statesArraySorted indexOfObject:self.state];
    if (selectedIndex == NSNotFound) selectedIndex = 0;
    
    ActionSheetStringPicker *action = [[ActionSheetStringPicker alloc]
                                       initWithTitle:nil
                                       rows:statesArraySorted
                                       initialSelection:selectedIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           
                                           self.state = statesArraySorted[selectedIndex];
                                           [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:(UITableViewRowAnimationFade)];
                                           
                                       }
                                       cancelBlock:^(ActionSheetStringPicker *picker) {
                                           
                                       }
                                       origin:self.view];
    
    [action showActionSheetPicker];
    [action.toolbar setTintColor:[UIColor greenBoatDay]];
    [action.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
}


@end
