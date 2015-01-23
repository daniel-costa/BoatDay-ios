//
//  BDCertificationDetailViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 27/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDCertificationDetailViewController.h"
#import "HPGrowingTextView.h"
#import "SVProgressHUD.h"
#import "UIAlertView+Blocks.h"
#import "WCActionSheet.h"

static NSInteger const kAboutMeMaximumCharacters = 500;

@interface BDCertificationDetailViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HPGrowingTextViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) Certification *certification;
@property (strong, nonatomic) CertificationType *type;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *addCertificationView;
@property (weak, nonatomic) IBOutlet UILabel *addMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *certificateImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *charRemainingLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *separatorLine;
@property (weak, nonatomic) IBOutlet UIView *messageView;

@property (strong, nonatomic) UITapGestureRecognizer *tap;


- (IBAction)takePhotoButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;

@end

@implementation BDCertificationDetailViewController

- (instancetype)initCertification:(Certification*)certification andCertificatonType:(CertificationType*)type {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _certification = certification;
    _type = type;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    self.title = NSLocalizedString(@"certificationDetail.title", nil);
    self.titleLabel.text = self.type.name;


    // if there is a certification already
    if (self.certification) {
        
        // loading view until we set all
        [self addActivityViewforView:self.contentView];
        
        self.addCertificationView.hidden = YES;
        self.certificateImageView.hidden = NO;
        
        self.textView.editable = NO;
        
        if ([NSString isStringEmpty:self.certification.message]) {
            
            self.textView.text = NSLocalizedString(@"certifications.noMessagePlaceholder", nil);
            
        }
        else {
            
            self.textView.text = self.certification.message;
            
        }
        
        [self.textView.internalTextView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
        
        self.separatorLine.hidden = YES;
        self.charRemainingLabel.hidden = YES;
        PFFile *theImage = self.certification.picture;
        
        // Get image from cache or from server if isnt available (background task)
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            [self.certificateImageView setImage:image];
            
            // We got all the data, we can remove the loading view
            [self removeActivityViewFromView:self.contentView];
            
        }];
        
        switch ([self.certification.status integerValue]) {
            case CertificationStatusPending:

               
                [self.submitButton setTitle:NSLocalizedString(@"certifications.deletePending", nil) forState:UIControlStateNormal];
                [self.submitButton setBackgroundImage:[UIImage imageNamed:@"button_lg_red_off"] forState:UIControlStateNormal];
                [self.submitButton setBackgroundImage:[UIImage imageNamed:@"button_lg_red_on"] forState:UIControlStateHighlighted];
                
                break;
            case CertificationStatusApproved:
                
                [self.submitButton setTitle:NSLocalizedString(@"certifications.approved", nil) forState:UIControlStateNormal];
                [self.submitButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_off"] forState:UIControlStateNormal];
                [self.submitButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_on"] forState:UIControlStateHighlighted];
                
                break;
            default:
                break;
        }
        
    }
    else {
        self.submitButton.enabled = NO;
        
        [self.submitButton setTitle:NSLocalizedString(@"certifications.submit", nil) forState:UIControlStateNormal];
        [self.submitButton setBackgroundImage:[UIImage imageNamed:@"button_lg_blue_off"] forState:UIControlStateNormal];
        [self.submitButton setBackgroundImage:[UIImage imageNamed:@"button_lg_blue_on"] forState:UIControlStateHighlighted];
        
    }
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [self setupView];
    
    // set keyboard observers to be called when textFields and textFields are responders
    //   we will need to scroll the table to show the field that is being editing
    [self addKeyboardObservers];
    
    setFrameY(self.messageView, CGRectGetMaxY(self.addCertificationView.frame) + self.navigationController.navigationBar.frame.size.height + 5.0);
    setFrameHeight(self.messageView, (CGRectGetMinY(self.submitButton.frame) - 5.0) - CGRectGetMinY(self.messageView.frame));
    setFrameY(self.textView, CGRectGetMaxY(self.addMessageLabel.frame) + 5.0);
    
    setFrameHeight(self.separatorLine, 1.0);
    setFrameY(self.separatorLine, CGRectGetMaxY(self.textView.frame) + 13.0);
    setFrameY(self.charRemainingLabel, CGRectGetMaxY(self.separatorLine.frame) + 2.0 );
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.contentView.frame), CGRectGetMaxY(self.submitButton.frame));
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    // remove all observers from notification center to be sure we got no memory leaks
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) setupView {
    
    self.addMessageLabel.text = NSLocalizedString(@"certifications.addMessage", nil);
    self.addMessageLabel.font = [UIFont quattroCentoRegularFontWithSize:12.0];
    self.addMessageLabel.textColor = [UIColor whiteColor];
    
    self.addInfoLabel.text = NSLocalizedString(@"certifications.addInfo", nil);
    self.addInfoLabel.font = [UIFont abelFontWithSize:12.0];
    self.addInfoLabel.textColor = [UIColor grayBoatDay];
    
    self.charRemainingLabel.font = [UIFont abelFontWithSize:12.0];
    self.charRemainingLabel.textColor = [UIColor grayBoatDay];
    
    [self charRemainingUpdate];
    
    self.textView.isScrollable = YES;
    self.textView.contentInset = UIEdgeInsetsMake(0, -4, 0, 0);
    self.textView.minNumberOfLines = 1;
    self.textView.maxNumberOfLines = 3;
    self.textView.returnKeyType = UIReturnKeyDefault; //just as an example
    self.textView.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textColor = [UIColor greenBoatDay];
    self.textView.placeholder = NSLocalizedString(@"certifications.textView.placeholder", @"");
    self.textView.placeholderColor = [UIColor grayBoatDay];
    self.textView.tintColor = [UIColor greenBoatDay];
    
    self.scrollView.delaysContentTouches = NO;
    
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

#pragma mark - IBAction Methods

- (IBAction)takePhotoButtonPressed:(id)sender {
    
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

- (void) saveCertificate {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    NSString *myUniqueName = [NSString stringWithFormat:@"%@%@-%@-%lu", [User currentUser].firstName, [User currentUser].lastName, self.type.name, (unsigned long)([[NSDate date] timeIntervalSince1970]*10.0)];
    
    // Updating user pictures
    NSData *imageData = UIImagePNGRepresentation(self.certificateImageView.image);
    PFFile *imageFile = [PFFile fileWithName:myUniqueName data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        Certification *certification = [Certification object];
        certification.picture = imageFile;
        certification.message = self.textView.text;
        certification.type = self.type;
        certification.user = [User currentUser];
        certification.status = @(CertificationStatusPending);
        certification.deleted = @(NO);
        
        [certification saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            self.certification = certification;
            [[Session sharedSession].myCertifications addObject:certification];
            
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
    }];
    
}

- (void) deleteCertificate {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    [[Session sharedSession].myCertifications removeObject:self.certification];
    
    self.certification.deleted = @(YES);
    
    [self.certification saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            self.certification = nil;
            
            [SVProgressHUD dismiss];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
    }];
    
}


- (IBAction)submitButtonPressed:(id)sender {
    
    [self.textView resignFirstResponder];
    
    if (self.certification) {
        [self deleteCertificate];

//
    }
    else {
        
        [self saveCertificate];
        
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
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [self.certificateImageView setImage:chosenImage];
    self.certificateImageView.hidden = NO;
    self.addCertificationView.hidden = YES;
    self.submitButton.enabled = YES;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - HPGrowingTextView Delegate Methods

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    CGFloat diff = (growingTextView.frame.size.height - height);
    
    setFrameY(self.separatorLine, CGRectGetMaxY(growingTextView.frame) - diff + 5.0);
    
    setFrameY(self.charRemainingLabel, CGRectGetMaxY(self.separatorLine.frame) + 2.0 );
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.contentView.frame), CGRectGetMaxY(self.submitButton.frame));
    
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //maximum textView chars = kAboutMeMaximumCharacters
    return growingTextView.text.length + (text.length - range.length) <= kAboutMeMaximumCharacters;
    
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    
    [self charRemainingUpdate];
    
}

- (void)charRemainingUpdate {
    
    self.charRemainingLabel.text = [NSString stringWithFormat:@"%d %@",
                                    (int)(kAboutMeMaximumCharacters - self.textView.text.length),
                                    NSLocalizedString(@"editProfile.aboutMe.charsRemaining", nil)];
    
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
    
    // Scroll Tableview to selected Cell
    NSTimeInterval duration = [[notification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        setFrameY(self.contentView, - CGRectGetMaxY(self.addCertificationView.frame) - self.navigationController.navigationBar.frame.size.height);
    } completion:nil];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    // Remove gesture recognizer
    [self.navigationController.view removeGestureRecognizer:self.tap];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    self.tap = nil;
    
    // Scroll Tableview to Zero (default)
    NSTimeInterval duration = [[notification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        setFrameY(self.contentView, 0.0)
        
    }];
    
}

@end
