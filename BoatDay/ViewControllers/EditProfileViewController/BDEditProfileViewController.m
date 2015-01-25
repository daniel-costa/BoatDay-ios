//
//  BDAddEditProfileViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 20/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEditProfileViewController.h"
#import "UIImage+Resize.h"
#import "SVProgressHUD.h"
#import "SMPageControl.h"
#import "WCActionSheet.h"

#import "BDEditProfileFirstRowCell.h"
#import "BDEditProfileAboutMeCell.h"
#import "BDEditProfileActivitiesCell.h"
#import "BDActivitiesListViewController.h"
#import "BDCertificationListViewController.h"
#import "BDLocationViewController.h"
#import "ActionSheetDatePicker.h"

static NSInteger const kAboutMeMaximumCharacters = 500;
static NSInteger const kMaximumNumberOfPictures = 5;

@interface BDEditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UITextViewDelegate, BDLocationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) SMPageControl *pageControl;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableArray *imagesArray;

@property (strong, nonatomic) NSMutableArray *imageButtonsArray;

@property (strong, nonatomic) NSMutableArray *closeButtonsArray;

@property (strong, nonatomic) NSMutableArray *selectedButtonsArray;

@property (nonatomic, strong) ActionSheetDatePicker *actionSheetPicker;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (strong, nonatomic) User *oldUser;

@property (strong, nonatomic) NSMutableArray *oldActivities;

@property (strong, nonatomic) NSIndexPath *editingIndexPath;

@property (strong, nonatomic) NSMutableArray *activities;

@end

@implementation BDEditProfileViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.screenName =@"BDEditProfileViewController";

    // set user data
    self.imagesArray = [[User currentUser].pictures mutableCopy];
    
    // make a new copy in order to reset user if this view is canceled
    self.oldUser = (User*)[[User currentUser] copyShallow];
    
    // need to copy activities and certifications separately, because they are other objects
    self.oldActivities = [NSMutableArray arrayWithArray:[User currentUser].activities];
    
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
    
    //get full activities object
    
    NSMutableArray *activitiesTemp = [User currentUser].activities;
    
    self.activities = [[NSMutableArray alloc] init];
    
    [[Session sharedSession].allActivities enumerateObjectsUsingBlock:^(Activity *activity, NSUInteger idx, BOOL *stop) {
        
        if ([activitiesTemp containsObject:activity]) {
            [self.activities addObject:activity];
        }
        
    }];
    
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
    
    // setup our image gallery
    [self setupPhotosHorizontalScrollView];
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDEditProfileFirstRowCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDEditProfileFirstRowCell reuseIdentifier]];
    
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDEditProfileAboutMeCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDEditProfileAboutMeCell reuseIdentifier]];
    
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDEditProfileActivitiesCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDEditProfileActivitiesCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delaysContentTouches = YES;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}

- (void) setupNavigationBar {
    
    self.title = NSLocalizedString(@"editProfile.title", nil);
    
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
    // all the modifications must be discarded
    // we reset all simple values, activities and certifications
    [[User currentUser] resetValuesToObject:self.oldUser];
    [User currentUser].activities = self.oldActivities;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) saveButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"saveButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    // shows some loading view so the user can see that is saving
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    // add gallery pictures to current user
    [User currentUser].pictures = self.imagesArray;
    
    [User currentUser].fullName = [NSString stringWithFormat:@"%@ %@", [User currentUser].firstName, [User currentUser].lastName];
    
    // saving the user in background
    [[User currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        // dismiss loading view
        [SVProgressHUD dismiss];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: // first row: first and last name, location and birthday date
            return 136.0;
        case 1: // about Me cell, textview + char remaining
        {
            BDEditProfileAboutMeCell *cell = (BDEditProfileAboutMeCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
            setFrameHeight(cell, CGRectGetMaxY(cell.charRemainingLabel.frame) + 5.0);
            return CGRectGetHeight(cell.frame);
        }
        case 2: // activities row
            return 90.0;
        case 3: // certifications row
            return 72.0;
        default:
            return 44.0;
            break;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            // first row: first and last name, location and birthday date
            return [self firstRowCellForIndexPath:indexPath];
        case 1:
            // about Me cell, textview + char remaining
            return [self aboutMeCellRowForIndexPath:indexPath];
        case 2:
            // about Me cell, textview + char remaining
            return [self activitiesCellRowForIndexPath:indexPath];
        case 3:
            // certifictions cell
            return [self certificationsCellRowForIndexPath:indexPath];
        default:
            return nil;
            break;
    }
    
    
    return nil;
}

- (UITableViewCell *) certificationsCellRowForIndexPath:(NSIndexPath*)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"certificationsCell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"certificationsCell"];
        
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

- (UITableViewCell *) activitiesCellRowForIndexPath:(NSIndexPath*)indexPath {
    
    BDEditProfileActivitiesCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDEditProfileActivitiesCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.titleLabel.text = NSLocalizedString(@"editProfile.myActivities", nil);
    [cell updateCellWithActivities:self.activities];
    
    return cell;
}

- (UITableViewCell *) aboutMeCellRowForIndexPath:(NSIndexPath*)indexPath {
    
    BDEditProfileAboutMeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDEditProfileAboutMeCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textView.delegate = self;
    
    cell.titleLabel.text = NSLocalizedString(@"editProfile.aboutMe", nil);
    cell.textView.text = [User currentUser].aboutMe;
    cell.textView.tag = 1;
    
    [cell updateCell];
    
    return cell;
}

- (UITableViewCell *) firstRowCellForIndexPath:(NSIndexPath*)indexPath {
    
    BDEditProfileFirstRowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDEditProfileFirstRowCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.firstNameLabel.text = NSLocalizedString(@"editProfile.firstName", nil);
    cell.firstNameTextField.text = [User currentUser].firstName;
    cell.firstNameTextField.delegate = self;
    cell.firstNameTextField.tag = 1;
    
    cell.lastNameLabel.text = NSLocalizedString(@"editProfile.lastName", nil);
    cell.lastNameTextField.text = [User currentUser].lastName;
    cell.lastNameTextField.delegate = self;
    cell.lastNameTextField.tag = 2;
    
    cell.locationNameLabel.text = NSLocalizedString(@"findABoat.location.title", nil);
    [cell.locationButton setTitle:[[User currentUser] fullLocation] forState:UIControlStateNormal];
    [cell.locationButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.locationButton addTarget:self action:@selector(locationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSDateFormatter *dateFormatter = [NSDateFormatter birthdayDateFormatter];
    NSString *birthday = [dateFormatter stringFromDate:[[User currentUser] birthday]];
    
    cell.birthdayNameLabel.text = NSLocalizedString(@"editProfile.birthday", nil);
    [cell.birthdayButton setTitle:birthday forState:UIControlStateNormal];
    [cell.birthdayButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.birthdayButton addTarget:self action:@selector(openDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    
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
        case 2:
        {
            BDActivitiesListViewController *activitiesViewController = [[BDActivitiesListViewController alloc] initWithActivities:[User currentUser].activities];
            [activitiesViewController setActivitiesChangeBlock:^(NSMutableArray *activities) {
                
                [User currentUser].activities = activities;
                
            }];
            [self.navigationController pushViewController:activitiesViewController animated:YES];
        }
            break;
        case 3:
        {
            BDCertificationListViewController *certificationsViewController = [[BDCertificationListViewController alloc] init];
            [self.navigationController pushViewController:certificationsViewController animated:YES];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - Date Picker Methods

-(void)openDatePicker:(id)sender {
    
    self.actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@""
                                                           datePickerMode:UIDatePickerModeDate
                                                             selectedDate:[[User currentUser] birthday] ?: [NSDate date]
                                                                   target:self
                                                                   action:@selector(dateWasSelected:element:)
                                                                   origin:sender];
    
    
    self.actionSheetPicker.hideCancel = NO;
    [self.actionSheetPicker showActionSheetPicker];
    [self.actionSheetPicker.toolbar setTintColor:[UIColor greenBoatDay]];
    [self.actionSheetPicker.toolbar setBarTintColor:[UIColor greenBoatDay]];
    
}

- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    
    [User currentUser].birthday = selectedDate;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter birthdayDateFormatter];
    NSString *birthday = [dateFormatter stringFromDate:[[User currentUser] birthday]];
    
    BDEditProfileFirstRowCell *firstRow = (BDEditProfileFirstRowCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [firstRow.birthdayButton setTitle:birthday forState:UIControlStateNormal];
    
}


#pragma mark - UITextView Delegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    // set editing index path for scroll animation
    self.editingIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //maximium chars = 500
    return textView.text.length + (text.length - range.length) <= kAboutMeMaximumCharacters;
    
}

- (void)textViewDidChange:(UITextView *)textView {
    
    switch (textView.tag) {
        case 1:
            [User currentUser].aboutMe = textView.text;
            break;
        default:
            break;
    }
    
    // prepare height for row for about me label
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    // update the real cell to the new height
    BDEditProfileAboutMeCell *cell = (BDEditProfileAboutMeCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [cell updateCell];
    
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
    
    switch (textField.tag) {
        case 1:
            [User currentUser].firstName = textField.text;
            break;
        case 2:
            [User currentUser].lastName = textField.text;
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
    for (int i = 0; i < self.imagesArray.count + 1; i++) {
        
        UIButton *imageButton = [[UIButton alloc] init];
        imageButton.tag = i;
        imageButton.backgroundColor = [UIColor clearColor];
        [imageButton addTarget:self action:@selector(imageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
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
    
    UILabel *addPhotoLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
                                                                        CGRectGetMaxY(self.scrollView.frame),
                                                                        self.tableView.frame.size.width,
                                                                        22.0)];
    addPhotoLabel.backgroundColor = RGB(4.0, 29.0, 33.0);
    addPhotoLabel.text = NSLocalizedString(@"editProfile.photosMessage", nil);
    addPhotoLabel.textColor = [UIColor whiteColor];
    addPhotoLabel.font = [UIFont quattroCentoRegularFontWithSize:12.0];
    addPhotoLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                               0.0,
                                                               self.tableView.frame.size.width,
                                                               self.scrollView.frame.size.height + addPhotoLabel.frame.size.height)];
    
    
    self.tableView.tableHeaderView = topView;
    
    self.pageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0.0,
                                                                       CGRectGetMaxY(self.scrollView.frame) - 15.0 - 5.0,
                                                                       self.scrollView.frame.size.width,
                                                                       15.0)];
    
    self.pageControl.numberOfPages = self.imagesArray.count + 1;
    self.pageControl.pageIndicatorImage = [UIImage imageNamed:@"photo_pag_off"];
    self.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"photo_pag_on"];
    [self.pageControl setImage:[UIImage imageNamed:@"photo_pag_add_off"] forPage:0];
    [self.pageControl setCurrentImage:[UIImage imageNamed:@"photo_pag_add_on"] forPage:0];
    self.pageControl.tapBehavior = SMPageControlTapBehaviorJump;
    self.pageControl.userInteractionEnabled = NO;
    
    [topView addSubview:self.scrollView];
    [topView addSubview:addPhotoLabel];
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
        
    }
    else {
        
        UIButton *oldSelectedButton = self.selectedButtonsArray[[[User currentUser].selectedPictureIndex integerValue]+1];
        oldSelectedButton.hidden = YES;
        
        NSInteger index = imageButton.tag;
        
        UIButton *selectedButton = self.selectedButtonsArray[index];
        selectedButton.hidden = NO;
        
        [User currentUser].selectedPictureIndex = @(index-1);
        
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
    
    if ([[User currentUser].selectedPictureIndex integerValue] == index) {
        [User currentUser].selectedPictureIndex = @(0);
    }
    else {
        [User currentUser].selectedPictureIndex = @([[User currentUser].selectedPictureIndex integerValue]-1);
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
            
            [imageButton setBackgroundImage:[UIImage imageNamed:@"userPhotoCoverPlaceholder"] forState:UIControlStateNormal];
            closeButton.hidden = NO;
            
            selectedButton.hidden = [[User currentUser].selectedPictureIndex integerValue] != i-1;
            
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
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"Image_%ld.png", (long)self.imagesArray.count+1] data:imageData];
    
    [imageFile saveInBackground];
    
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

- (void) locationButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"locationButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    BDLocationViewController *editBoatViewController = [[BDLocationViewController alloc] initWithStringLocation:[User currentUser].fullLocation];
    editBoatViewController.delegate = self;
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:editBoatViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

#pragma mark - BDLocation Delegate Methods

- (void)changedLocation:(PFGeoPoint*)location withCity:(NSString *)city andCountry:(NSString*)country {
    
    if (city && country) {
        [User currentUser].city = city;
        [User currentUser].country = country;
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:(UITableViewRowAnimationFade)];
    
}


@end
