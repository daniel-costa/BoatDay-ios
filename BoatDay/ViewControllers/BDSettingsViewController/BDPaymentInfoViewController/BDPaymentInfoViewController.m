//
//  BDPaymentInfoViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 08/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDPaymentInfoViewController.h"
#import "BDSelectDestinationPaymentCell.h"
#import "BDBusinessInfoPaymentCell.h"
#import "BDPersonalInfoPaymentCell.h"
#import "BDTermsOfServicePaymentCell.h"
#import "BDTermsOfServiceViewController.h"
#import "BDAddressInfoPaymentCell.h"
#import "ActionSheetStringPicker.h"
#import "NSString+USStateMap.h"
#import "BDPaymentStatusViewController.h"

static NSInteger const kSSNMaximumCharacters = 9;
static NSInteger const kTaxIDMaximumCharacters = 9;

typedef NS_ENUM(NSUInteger, BDPaymentInfoTextFieldTag) {
    
    BDPaymentInfoTextFieldTagAccountNumber = 1,
    BDPaymentInfoTextFieldTagRoutingNumber,
    BDPaymentInfoTextFieldTagEmail,
    BDPaymentInfoTextFieldTagPhoneNumber,
    BDPaymentInfoTextFieldTagBusinessName,
    BDPaymentInfoTextFieldTagTaxId,
    BDPaymentInfoTextFieldTagSSN,
    BDPaymentInfoTextFieldTagAddress,
    BDPaymentInfoTextFieldTagZipCode
    
};

@interface BDPaymentInfoViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (strong, nonatomic) NSIndexPath *editingIndexPath;

// Data
@property (strong, nonatomic) NSString *accountName;
@property (strong, nonatomic) NSString *routingNumber;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *businessName;
@property (strong, nonatomic) NSString *taxId;
@property (strong, nonatomic) NSString *ssn;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *zipCode;

@property (nonatomic) BOOL useBusinessInfo;
@property (nonatomic) BOOL acceptedTermsOfService;
@property (nonatomic) NSInteger segmentedControlIndex;

@property (strong, nonatomic) NSString *merchantID;

@property (strong, nonatomic) Boat *registrationBoat;

- (IBAction)submitButtonPressed:(id)sender;

@end

@implementation BDPaymentInfoViewController

- (instancetype)initWithMerchantId:(NSString *)merchantID {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _merchantID = merchantID;
    
    return self;
    
}

- (instancetype)initWithRegistrationBoat:(Boat *)boat {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _registrationBoat = boat;
    
    return self;
    
}

- (void)viewDidLoad {
    
    self.title = NSLocalizedString(@"paymentInfo.title", nil);
    
    [super viewDidLoad];
    self.screenName =@"BDPaymentInfoViewController";

    // setup view
    [self setupTableView];
    
    self.useBusinessInfo = NO;
    self.acceptedTermsOfService = NO;
    self.address = [User currentUser].firstLineAddress;
    self.state = [User currentUser].state;
    self.zipCode = [User currentUser].zipCode;
    
    [self addTableHeaderView];
    
}

- (void) addTableHeaderView {
    
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.frame), 50.0)];
    headerView.backgroundColor = [UIColor clearColor];
    headerView.textColor = [UIColor greenBoatDay];
    headerView.font = [UIFont abelFontWithSize:15.00];
    headerView.text = NSLocalizedString(@"paymentInfo.inputsMustMatch", nil);
    headerView.textAlignment = NSTextAlignmentCenter;
    
    self.tableView.tableHeaderView = headerView;
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // set keyboard observers to be called when textFields and textFields are responders
    //   we will need to scroll the table to show the field that is being editing
    [self addKeyboardObservers];
    
    if (self.registrationBoat) {
        
        // setup navigation bar buttons
        [self setupNavigationBar];
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self dismissKeyboard];
    
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
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDSelectDestinationPaymentCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDSelectDestinationPaymentCell reuseIdentifier]];
    
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDBusinessInfoPaymentCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDBusinessInfoPaymentCell reuseIdentifier]];
    
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDPersonalInfoPaymentCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDPersonalInfoPaymentCell reuseIdentifier]];
    
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDTermsOfServicePaymentCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDTermsOfServicePaymentCell reuseIdentifier]];
    
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDAddressInfoPaymentCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDAddressInfoPaymentCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delaysContentTouches = YES;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [self.submitButton setTitle:NSLocalizedString(@"paymentInfo.submitButton", nil) forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
    
    self.tableView.tableFooterView = self.bottomView;
    
}

- (void) setupNavigationBar {
    
    // create cancel button to navigatio bar at top of the view
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"addEditBoat.cancel", nil)
                                     style:UIBarButtonItemStyleDone
                                     target:self
                                     action:@selector(cancelButtonPressed)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
}

#pragma mark - UITableView Datasource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return 185.0;
            break;
        case 1:
            return 115.0;
            break;
        case 2:
            return 155.0;
            break;
        case 3:
            return 65.0;
            break;
        case 4:
            return 44.0;
            break;
        default:
            break;
    }
    
    return 44.0;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 25.0)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, -2.0, tableView.frame.size.width, 25.0)];
    label.font = [UIFont abelFontWithSize:12.0];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    view.backgroundColor = [UIColor greenBoatDay];
    
    NSString *headerLabelString = nil;
    
    switch (section) {
        case 0:
            headerLabelString = NSLocalizedString(@"paymentInfo.sectionTitle.selectDestination", nil);
            break;
        case 1:
            headerLabelString = NSLocalizedString(@"paymentInfo.sectionTitle.addressInformation", nil);
            break;
        case 2:
            headerLabelString = NSLocalizedString(@"paymentInfo.sectionTitle.businessInformation", nil);
            break;
        case 3:
            headerLabelString = NSLocalizedString(@"paymentInfo.sectionTitle.personalInformation", nil);
            break;
        case 4:
            headerLabelString = NSLocalizedString(@"paymentInfo.sectionTitle.termsOfService", nil);
            break;
        default:
            break;
    }
    
    
    label.text = headerLabelString;
    [view addSubview:label];
    return view;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return [self selectDestinationCellForIndexPath:indexPath];
            break;
        case 1:
            return [self addressInfoCellForIndexPath:indexPath];
            break;
        case 2:
            return [self businessInfoCellForIndexPath:indexPath];
            break;
        case 3:
            return [self personalInfoCellForIndexPath:indexPath];
            break;
        case 4:
            return [self termsOfServiceCellForIndexPath:indexPath];
            break;
        default:
            return nil;
            break;
    }
    
    
    return nil;
}

#pragma mark - Custom Cells

- (UITableViewCell *)selectDestinationCellForIndexPath:(NSIndexPath*)indexPath {
    
    BDSelectDestinationPaymentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDSelectDestinationPaymentCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.bAIndicateLabel.text = NSLocalizedString(@"paymentInfo.bank.indicateLabel", nil);
    
    cell.bAAccountNumberLabel.text = NSLocalizedString(@"paymentInfo.accountNumber", nil);
    cell.bAAccountNumberTextField.text = self.accountName;
    cell.bAAccountNumberTextField.placeholder = NSLocalizedString(@"paymentInfo.accountNumber.placeholder", nil);
    cell.bAAccountNumberTextField.delegate = self;
    cell.bAAccountNumberTextField.tag = BDPaymentInfoTextFieldTagAccountNumber;
    cell.bAAccountNumberTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    cell.bARoutingNumberLabel.text = NSLocalizedString(@"paymentInfo.routingNumber", nil);
    cell.bARoutingNumberTextField.text = self.routingNumber;
    cell.bARoutingNumberTextField.placeholder = NSLocalizedString(@"paymentInfo.routingNumber.placeholder", nil);
    cell.bARoutingNumberTextField.delegate = self;
    cell.bARoutingNumberTextField.tag = BDPaymentInfoTextFieldTagRoutingNumber;
    cell.bARoutingNumberTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    cell.venmoIndicateLabel.text = NSLocalizedString(@"paymentInfo.notBank.indicateLabel", nil);
    
    cell.venmoEmailLabel.text = NSLocalizedString(@"paymentInfo.emailField", nil);
    cell.venmoEmailTextField.text = self.email;
    cell.venmoEmailTextField.placeholder = NSLocalizedString(@"paymentInfo.emailField.placeholder", nil);
    cell.venmoEmailTextField.delegate = self;
    cell.venmoEmailTextField.tag = BDPaymentInfoTextFieldTagEmail;
    cell.venmoEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    cell.venmoPhoneNumberLabel.text = NSLocalizedString(@"paymentInfo.phoneNumberField", nil);
    cell.venmoPhoneNumberTextField.text = self.phoneNumber;
    cell.venmoPhoneNumberTextField.placeholder = NSLocalizedString(@"paymentInfo.phoneNumberField.placeholder", nil);
    cell.venmoPhoneNumberTextField.delegate = self;
    cell.venmoPhoneNumberTextField.tag = BDPaymentInfoTextFieldTagPhoneNumber;
    cell.venmoPhoneNumberTextField.keyboardType = UIKeyboardTypePhonePad;
    
    cell.segmentedControl.selectedSegmentIndex = self.segmentedControlIndex;
    [cell segmentedValueChanged:nil];
    
    [cell setSegmentedControlChangeBlock:^(NSInteger index) {
        self.segmentedControlIndex = index;
    }];
    
    return cell;
}

- (UITableViewCell *)addressInfoCellForIndexPath:(NSIndexPath*)indexPath {
    
    BDAddressInfoPaymentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDAddressInfoPaymentCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.addressLabel.text = NSLocalizedString(@"paymentInfo.address", nil);
    cell.addressTextField.text = self.address;
    cell.addressTextField.placeholder = NSLocalizedString(@"paymentInfo.address.placeholder", nil);
    cell.addressTextField.delegate = self;
    cell.addressTextField.tag = BDPaymentInfoTextFieldTagAddress;
    
    cell.zipCodeLabel.text = NSLocalizedString(@"paymentInfo.zipCode", nil);
    cell.zipCodeTextField.text = self.zipCode;
    cell.zipCodeTextField.placeholder = NSLocalizedString(@"paymentInfo.zipCode.placeholder", nil);
    cell.zipCodeTextField.delegate = self;
    cell.zipCodeTextField.tag = BDPaymentInfoTextFieldTagZipCode;
    cell.zipCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    cell.stateLabel.text = NSLocalizedString(@"paymentInfo.state", nil);
    [cell.stateButton setTitle:self.state forState:UIControlStateNormal];
    [cell.stateButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.stateButton addTarget:self action:@selector(stateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (UITableViewCell *)businessInfoCellForIndexPath:(NSIndexPath*)indexPath {
    
    BDBusinessInfoPaymentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDBusinessInfoPaymentCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.businessNameLabel.text = NSLocalizedString(@"paymentInfo.businessName", nil);
    cell.businessNameTextField.text = self.businessName;
    cell.businessNameTextField.placeholder = NSLocalizedString(@"paymentInfo.businessName.placeholder", nil);
    cell.businessNameTextField.delegate = self;
    cell.businessNameTextField.tag = BDPaymentInfoTextFieldTagBusinessName;
    
    cell.taxIdLabel.text = NSLocalizedString(@"paymentInfo.taxID", nil);
    cell.taxIdTextField.text = self.taxId;
    cell.taxIdTextField.placeholder = NSLocalizedString(@"paymentInfo.taxID.placeholder", nil);
    cell.taxIdTextField.delegate = self;
    cell.taxIdTextField.tag = BDPaymentInfoTextFieldTagTaxId;
    cell.taxIdTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    [cell.confirmButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.confirmButton addTarget:self action:@selector(businessInfoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell setEnabled:self.useBusinessInfo];
    
    return cell;
}

- (UITableViewCell *)personalInfoCellForIndexPath:(NSIndexPath*)indexPath {
    
    BDPersonalInfoPaymentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDPersonalInfoPaymentCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.ssnLabel.text = NSLocalizedString(@"paymentInfo.ssn", nil);
    cell.ssnTextField.text = self.ssn;
    cell.ssnTextField.placeholder = NSLocalizedString(@"paymentInfo.ssn.placeholder", nil);
    cell.ssnTextField.delegate = self;
    cell.ssnTextField.tag = BDPaymentInfoTextFieldTagSSN;
    cell.ssnTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    return cell;
}

- (UITableViewCell *)termsOfServiceCellForIndexPath:(NSIndexPath*)indexPath {
    
    BDTermsOfServicePaymentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDTermsOfServicePaymentCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.termsOfService setTitle:NSLocalizedString(@"paymentInfo.termsOfService", nil) forState:UIControlStateNormal];
    [cell.termsOfService removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.termsOfService addTarget:self action:@selector(termsOfServiceLinkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.confirmLabel.text = NSLocalizedString(@"paymentInfo.agree", nil);
    
    [cell.confirmButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.confirmButton addTarget:self action:@selector(termsOfServiceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.acceptedTermsOfService) {
        
        [cell.confirmButton setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
        [cell.confirmButton setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateHighlighted];
        
    }
    else {
        
        [cell.confirmButton setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        [cell.confirmButton setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateHighlighted];
        
    }
    
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
    
}

#pragma mark - UITextfield Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == BDPaymentInfoTextFieldTagSSN) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > kSSNMaximumCharacters) ? NO : YES;
    }
    
    if (textField.tag == BDPaymentInfoTextFieldTagTaxId) {
        
        NSString *taxId = [textField.text stringByReplacingCharactersInRange:range withString:string];
        taxId = [taxId stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSUInteger newLength = taxId.length;
        if (newLength > kTaxIDMaximumCharacters) {
            return NO;
        }
        
        NSString *formatted = taxId;
        
        if (formatted.length > 2) {
            formatted = [NSString stringWithFormat: @"%@-%@", [taxId substringWithRange:NSMakeRange(0,2)],
                         [taxId substringWithRange:NSMakeRange(2,taxId.length - 2)]];
        }
        
        textField.text = formatted;
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
        case BDPaymentInfoTextFieldTagAccountNumber:
            self.accountName = textField.text;
            break;
        case BDPaymentInfoTextFieldTagRoutingNumber:
            self.routingNumber = textField.text;
            break;
        case BDPaymentInfoTextFieldTagEmail:
            self.email = textField.text;
            break;
        case BDPaymentInfoTextFieldTagPhoneNumber:
            self.phoneNumber = textField.text;
            break;
        case BDPaymentInfoTextFieldTagBusinessName:
            self.businessName = textField.text;
            break;
        case BDPaymentInfoTextFieldTagTaxId:
            self.taxId = textField.text;
            break;
        case BDPaymentInfoTextFieldTagSSN:
            self.ssn = textField.text;
            break;
        case BDPaymentInfoTextFieldTagAddress:
            self.address = textField.text;
            break;
        case BDPaymentInfoTextFieldTagZipCode:
            self.zipCode = textField.text;
            break;
        default:
            break;
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

- (void) cancelButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"cancelButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [SVProgressHUD show];
    
    self.registrationBoat.status = @(BoatStatusNotSubmited);
    
    [self.registrationBoat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        
    }];
    
    
}

- (void) businessInfoButtonPressed:(UIButton*)button {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"businessInfoButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    self.useBusinessInfo = !self.useBusinessInfo;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void) termsOfServiceButtonPressed:(UIButton*)button {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"termsOfServiceButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    self.acceptedTermsOfService = !self.acceptedTermsOfService;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:4]] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void) termsOfServiceLinkButtonPressed:(UIButton*)button {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"termsOfServiceLinkButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    //BDTermsOfServiceViewController *termsViewController = [[BDTermsOfServiceViewController alloc] init];
    //[self.navigationController pushViewController:termsViewController animated:YES];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.braintreepayments.com/landing/gateway-terms-of-service"]];
    
}

- (IBAction)submitButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"submitButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self dismissKeyboard];
    
    PaymentInfoDestination destination;
    
    if (self.segmentedControlIndex == 0) { // bank
        
        destination = PaymentInfoDestinationBank;
        
    }
    else {
        
        if (![NSString isStringEmpty:self.email]) { // email
            
            destination = PaymentInfoDestinationEmail;
            
            
        }
        else { // phone
            
            destination = PaymentInfoDestinationPhoneNumber;
            
        }
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    [User currentUser].firstLineAddress = self.address;
    [User currentUser].zipCode = self.zipCode;
    [User currentUser].state = self.state;
    [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (self.merchantID) {
            [self editMerchantWithDestination:destination];
        }
        else {
            [self createMerchantWithDestination:destination];
        }
    }];
    
}

#pragma mark - Payment Methods

- (void) createMerchantWithDestination:(PaymentInfoDestination)destination {
    
    [[BDPaymentServiceManager sharedManager] createMerchantWithUser:[User currentUser]
                                             paymentInfoDestination:destination
                                                 hostRegistrationID:[Session sharedSession].hostRegistration.objectId
                                                      accountNumber:self.accountName
                                                      routingNumber:self.routingNumber
                                                              email:self.email
                                                        phoneNumber:self.phoneNumber
                                                       businessName:self.businessName
                                                              taxID:self.taxId
                                                  lastFourSSNDigits:self.ssn
                                                            address:self.address
                                                             region:[self.state stateAbbreviationFromFullName]
                                                         postalCode:self.zipCode
                                            termsOfServiceAgreement:self.acceptedTermsOfService
                                                          withBlock:^(BOOL success, NSString *errorMessage) {
                                                              
                                                              [SVProgressHUD dismiss];
                                                              
                                                              if (success) {
                                                                  
                                                                  UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"paymentInfo.hostRegistration.title", nil)
                                                                                                                        message:NSLocalizedString(@"paymentInfo.hostRegistration.message", nil)
                                                                                              
                                                                                                                       delegate:nil
                                                                                                              cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                                                                              otherButtonTitles: nil];
                                                                  
                                                                  [myAlertView show];
                                                                  
                                                                  [self dismissViewControllerAnimated:YES completion:^{
                                                                      [[Session sharedSession] updateUserData];
                                                                  }];
                                                                  
                                                              }
                                                              else {
                                                                  
                                                                  [self showBraintreeErrorAlerViewWithMessage:errorMessage];
                                                                  
                                                              }
                                                              
                                                          }];
    
    
}

- (void) editMerchantWithDestination:(PaymentInfoDestination)destination {
    
    [[BDPaymentServiceManager sharedManager] updateMerchantWithUser:[User currentUser]
                                                         merchantId:self.merchantID
                                             paymentInfoDestination:destination
                                                 hostRegistrationID:[Session sharedSession].hostRegistration.objectId
                                                      accountNumber:self.accountName
                                                      routingNumber:self.routingNumber
                                                              email:self.email
                                                        phoneNumber:self.phoneNumber
                                                       businessName:self.businessName
                                                              taxID:self.taxId
                                                  lastFourSSNDigits:self.ssn
                                                            address:self.address
                                                             region:[self.state stateAbbreviationFromFullName]
                                                         postalCode:self.zipCode
                                            termsOfServiceAgreement:self.acceptedTermsOfService
                                                          withBlock:^(BOOL success, NSString *errorMessage) {
                                                              
                                                              [SVProgressHUD dismiss];
                                                              
                                                              if (success) {
                                                                  
                                                                  [[Session sharedSession] updateUserData];

                                                                  BDPaymentStatusViewController *paymentStatusView = [[BDPaymentStatusViewController alloc] init];
                                                                  [self.navigationController pushViewController:paymentStatusView animated:YES];
                                                                  
                                                              }
                                                              else {
                                                                  
                                                                  [self showBraintreeErrorAlerViewWithMessage:errorMessage];
                                                                  
                                                              }
                                                              
                                                          }];
    
    
}

#pragma mark - Error Methods

- (void) showBraintreeErrorAlerViewWithMessage:(NSString*)message {
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addEditBoat.alertview.title", nil)
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                otherButtonTitles: nil];
    
    [myAlertView show];
    
}

#pragma mark - Address State Methods

- (void) stateButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"stateButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self dismissKeyboard];
    
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
                                           [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:(UITableViewRowAnimationFade)];
                                           
                                       }
                                       cancelBlock:^(ActionSheetStringPicker *picker) {
                                       }
                                       origin:self.view];
    
    [action showActionSheetPicker];
    [action.toolbar setTintColor:[UIColor greenBoatDay]];
    [action.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
}

@end
