//
//  BDBoatInsuranceViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 27/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDBoatInsuranceViewController.h"
#import "SVProgressHUD.h"
#import "UIAlertView+Blocks.h"
#import "WCActionSheet.h"
#import "ActionSheetDatePicker.h"
#import "TSCurrencyTextField.h"

@interface BDBoatInsuranceViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate>

// Navigation Bar
@property (strong, nonatomic) UIBarButtonItem *saveButton;

// View
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *addPhotoView;
@property (weak, nonatomic) IBOutlet UILabel *addMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *insuranceImageView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIView *imageTopContainerView;

@property (weak, nonatomic) IBOutlet TSCurrencyTextField *minimumCoverageTextField;
@property (weak, nonatomic) IBOutlet UILabel *minimumCoverageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationDateTitleLabel;

// Date Picker
@property (nonatomic, strong) ActionSheetDatePicker *actionSheetPicker;

// Gestures
@property (strong, nonatomic) UITapGestureRecognizer *tap;

// Data
@property (strong, nonatomic) Boat *boat;
@property (strong, nonatomic) NSDate *choosenDate;
@property (nonatomic) BOOL haveImage;

// Methods
- (IBAction)takePhotoButtonPressed:(id)sender;
- (IBAction)dateButtonPressed:(id)sender;

@end

@implementation BDBoatInsuranceViewController

- (instancetype)initWithBoat:(Boat*)boat {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _boat = boat;
    _haveImage = NO;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.screenName =@"BDBoatInsuranceViewController";

    [self setupView];
    
    // if there is a certification already
    if (self.boat.insurance) {
        
        // loading view until we set all
        [self addActivityViewforView:self.contentView];
        
        self.addPhotoView.hidden = YES;
        self.insuranceImageView.hidden = NO;
        
        PFFile *theImage = self.boat.insurance;
        
        // Get image from cache or from server if isnt available (background task)
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            [self.insuranceImageView setImage:image];
            self.haveImage = YES;
            
            // We got all the data, we can remove the loading view
            [self removeActivityViewFromView:self.contentView];
            
        }];
        
    }
    
    NSDate *expirationDate = self.boat.insuranceExpirationDate ?: [NSDate date];
    
    self.choosenDate = expirationDate;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter birthdayDateFormatter];
    NSString *expirationDateString = [dateFormatter stringFromDate:expirationDate];
    [self.dateButton setTitle:expirationDateString forState:UIControlStateNormal];
    
    self.minimumCoverageTextField.text = self.boat.insuranceMinimumCoverage ?: @"";
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // set keyboard observers to be called when textFields and textFields are responders
    //   we will need to scroll the table to show the field that is being editing
    [self addKeyboardObservers];
    
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

- (void) setupNavigationBar {
    
    self.title = NSLocalizedString(@"boatInsurance.title", nil);
    UIButton *saveButtons = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButtons.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [saveButtons setImage:[UIImage imageNamed:@"ico-save"] forState:UIControlStateNormal];
    [saveButtons addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton = [[UIBarButtonItem alloc] initWithCustomView:saveButtons];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [cancelButton setImage:[UIImage imageNamed:@"ico-Cancel"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    
    

    /*
    // create save button to navigatio bar at top of the view
    self.saveButton = [[UIBarButtonItem alloc]
                       initWithTitle:NSLocalizedString(@"boatInsurance.save", nil)
                       style:UIBarButtonItemStyleDone
                       target:self
                       action:@selector(saveButtonPressed)];
    
    NSDictionary* textAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                     NSFontAttributeName:[UIFont abelFontWithSize:16.0],
                                     NSKernAttributeName:@(-0.6f)
                                     };
    
    NSDictionary* textAttributesDisabled = @{NSForegroundColorAttributeName:[UIColor greenBoatDay],
                                             NSFontAttributeName:[UIFont abelFontWithSize:16.0],
                                             NSKernAttributeName:@(-0.6f)
                                             };
    
    [self.saveButton setTitleTextAttributes:textAttributes forState: UIControlStateNormal];
    [self.saveButton setTitleTextAttributes:textAttributesDisabled forState: UIControlStateDisabled];
    
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    
    // create cancel button to navigatio bar at top of the view
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"boatInsurance.cancel", nil)
                                     style:UIBarButtonItemStyleDone
                                     target:self
                                     action:@selector(cancelButtonPressed)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    */
}

- (void) setupView {
    
    self.scrollView.delaysContentTouches = NO;
    
    self.addMessageLabel.text = NSLocalizedString(@"boatInsurance.tapToAddPhoto", nil);
    self.addMessageLabel.font = [UIFont quattroCentoRegularFontWithSize:12.0];
    self.addMessageLabel.textColor = [UIColor whiteColor];
    
    self.minimumCoverageTitleLabel.text = NSLocalizedString(@"boatInsurance.minimumCoverage", nil);
    self.minimumCoverageTitleLabel.font = [UIFont abelFontWithSize:14.0];
    self.minimumCoverageTitleLabel.textColor = [UIColor grayBoatDay];
    
    self.minimumCoverageTextField.font = [UIFont abelFontWithSize:17.0];
    self.minimumCoverageTextField.textColor = [UIColor greenBoatDay];
    self.minimumCoverageTextField.placeholder = NSLocalizedString(@"boatInsurance.minimumCoverage.placeholder", nil);
    self.minimumCoverageTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.minimumCoverageTextField.delegate = self;
    
    self.minimumCoverageTextField.currencyNumberFormatter = [[NSNumberFormatter alloc] init];
    self.minimumCoverageTextField.currencyNumberFormatter.locale = [NSLocale currentLocale];
    self.minimumCoverageTextField.currencyNumberFormatter.numberStyle = kCFNumberFormatterCurrencyStyle;
    self.minimumCoverageTextField.currencyNumberFormatter.usesGroupingSeparator = YES;
    self.minimumCoverageTextField.currencyNumberFormatter.minimumIntegerDigits = 1;
    self.minimumCoverageTextField.currencyNumberFormatter.minimumFractionDigits = 0;
    
    self.expirationDateTitleLabel.text = NSLocalizedString(@"boatInsurance.expirationDate", nil);
    self.expirationDateTitleLabel.font = [UIFont abelFontWithSize:14.0];
    self.expirationDateTitleLabel.textColor = [UIColor grayBoatDay];
    
    self.dateButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.dateButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.dateButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateHighlighted];
    
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


    if ([self.minimumCoverageTextField.amount floatValue] < 300000) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"boatInsurance.minCoverageAlert.title", nil)
                                                              message:NSLocalizedString(@"boatInsurance.minCoverageAlert.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
    }
    
    if ([self.choosenDate compare:[NSDate date]] != NSOrderedDescending) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"boatInsurance.dateTime.title", nil)
                                                              message:NSLocalizedString(@"boatInsurance.dateTime.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
    }
    
    if (!self.haveImage) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"boatInsurance.pictureAlert.title", nil)
                                                              message:NSLocalizedString(@"boatInsurance.pictureAlert.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    NSString *myUniqueName = [NSString stringWithFormat:@"Boat%@%@-%lu", [User currentUser].firstName, [User currentUser].lastName, (unsigned long)([[NSDate date] timeIntervalSince1970]*10.0)];
    
    // Updating user pictures
    NSData *imageData = UIImagePNGRepresentation(self.insuranceImageView.image);
    PFFile *imageFile = [PFFile fileWithName:myUniqueName data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (!error) {
            
            if (self.insuranceBlock) {
                self.insuranceBlock(imageFile, self.choosenDate, self.minimumCoverageTextField.text);
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        
    }];
    
}

#pragma mark - IBAction Methods

- (IBAction)takePhotoButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"takePhotoButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];

    [self dismissKeyboard];
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"boatInsurance.warning.title", nil)
                                message:NSLocalizedString(@"boatInsurance.warning.message", nil)
                       cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"errorMessages.ok", nil) action:^{
        
        [self openPhotoActionSheet];
        
    }]
                       otherButtonItems:nil] show];
    
}

- (IBAction)dateButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"dateButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self openDatePicker:sender];
    
}

#pragma mark - PPChooseOptionsViewController Delegate Methods

- (void)openPhotoActionSheet {
    

    WCActionSheet *actionSheet = [[WCActionSheet alloc] init];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"actionSheet.takePhoto", nil) actionBlock:^{
        [self takePhoto];
    }];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"actionSheet.chooseFromGallery", nil) actionBlock:^{
        [self choosePhotofromLibrary];
        
    }];
    [actionSheet show];
    
}

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
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [self.insuranceImageView setImage:chosenImage];
    self.insuranceImageView.hidden = NO;
    self.addPhotoView.hidden = YES;
    self.haveImage = YES;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Date Picker Methods

-(void)openDatePicker:(id)sender {
    
    self.actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                           datePickerMode:UIDatePickerModeDate
                                                             selectedDate:self.choosenDate
                                                                   target:self
                                                                   action:@selector(dateWasSelected:element:)
                                                                   origin:sender];
    
    
    self.actionSheetPicker.hideCancel = NO;
    [self.actionSheetPicker showActionSheetPicker];
    [self.actionSheetPicker.toolbar setTintColor:[UIColor greenBoatDay]];
    [self.actionSheetPicker.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    
    self.choosenDate = selectedDate;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter birthdayDateFormatter];
    NSString *expirationDate = [dateFormatter stringFromDate:self.choosenDate];
    
    [self.dateButton setTitle:expirationDate forState:UIControlStateNormal];
    
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
    
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        setFrameY(self.contentView, -CGRectGetMaxY(self.imageTopContainerView.frame));
        
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    // Remove gesture recognizer
    [self.navigationController.view removeGestureRecognizer:self.tap];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    self.tap = nil;
    
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        setFrameY(self.contentView, 0.0);
        
    }];
    
}

#pragma mark - UITextfield Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(TSCurrencyTextField *)textField {
    
    if ([textField.amount floatValue] < 300000) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"boatInsurance.minCoverageAlert.title", nil)
                                                              message:NSLocalizedString(@"boatInsurance.minCoverageAlert.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
    
}

@end
