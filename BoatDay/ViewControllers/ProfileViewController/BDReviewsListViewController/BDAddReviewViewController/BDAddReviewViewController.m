//
//  BDAddReviewViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 27/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDAddReviewViewController.h"

#import "EDStarRating.h"
#import "SVProgressHUD.h"
#import "HPGrowingTextView.h"

static NSInteger const kReviewMaximumCharacters = 500;

@interface BDAddReviewViewController () <UITextViewDelegate, EDStarRatingProtocol, HPGrowingTextViewDelegate>

@property (strong, nonatomic) User *reviewedUser;

@property (weak, nonatomic) IBOutlet UIView *bottomHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userLittleImageView;
@property (weak, nonatomic) IBOutlet UIView *imageAndNameView;
@property (weak, nonatomic) IBOutlet UILabel *lastActiveLabel;

@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;
@property (weak, nonatomic) IBOutlet UILabel *yourRatingLabel;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *textView;
@property (weak, nonatomic) IBOutlet UIView *separatorLine;
@property (weak, nonatomic) IBOutlet UILabel *charCount;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@end

@implementation BDAddReviewViewController

- (instancetype)initWithUserToReview:(User *)reviewedUser {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _reviewedUser = reviewedUser;
    
    return self;

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.screenName =@"BDAddReviewViewController";

    self.title = NSLocalizedString(@"addReview.title", nil);
    
    [self setupView];
      
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

- (void)setupView {
    
    self.starRating.backgroundColor = [UIColor clearColor];
    self.starRating.starHighlightedImage = [UIImage imageNamed:@"addReviewStarYellow"];
    self.starRating.starImage = [UIImage imageNamed:@"addReviewStarGray"];
    self.starRating.maxRating = 5.0;
    self.starRating.horizontalMargin = 2;
    self.starRating.editable = YES;
    self.starRating.displayMode = EDStarRatingDisplayFull;
    self.starRating.rating = 3;
    
    self.ratingView.backgroundColor = [UIColor lightGrayBoatDay];
    
    self.nameLabel.font = [UIFont quattroCentoRegularFontWithSize:21.0];
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.lastActiveLabel.font = [UIFont quattroCentoRegularFontWithSize:11.0];
    self.lastActiveLabel.textColor = [UIColor whiteColor];
    
    self.locationLabel.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.locationLabel.textColor = [UIColor yellowBoatDay];

    self.yourRatingLabel.font = [UIFont abelFontWithSize:12.0];
    self.yourRatingLabel.textColor = [UIColor grayBoatDay];
    
    [self getUserImage];
    
    // name example: "Diogo N."
    self.nameLabel.text = self.reviewedUser.shortName;
    
    self.locationLabel.text = [self.reviewedUser fullLocation];
    
    // If this is the current user profile, he is always "Active Now"
    if ([self.reviewedUser isEqual:[User currentUser]]) {
        
        // if current user, is active now!
        self.lastActiveLabel.text = NSLocalizedString(@"addReview.activeNow", nil);
        
    }
    else {
        
        self.lastActiveLabel.text = [NSString stringWithFormat:@"Last Active: %@", @"MISSING DATE"];
        
    }
    
    self.lastActiveLabel.hidden = YES;
    
    self.yourRatingLabel.text = NSLocalizedString(@"addReview.yourRating", nil);
    
    self.textView.isScrollable = YES;
    self.textView.contentInset = UIEdgeInsetsMake(0, -4, 0, 0);
    self.textView.minNumberOfLines = 1;
    self.textView.maxNumberOfLines = 5;
    self.textView.returnKeyType = UIReturnKeyDefault; //just as an example
    self.textView.font = [UIFont abelFontWithSize:15.0];
    self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textColor = [UIColor greenBoatDay];
    self.textView.placeholder = NSLocalizedString(@"addReview.textView.placeholder", @"");
    self.textView.placeholderColor = [UIColor grayBoatDay];
    self.textView.tintColor = [UIColor greenBoatDay];

}

- (void) setupNavigationBar {
    
    // create save button to navigatio bar at top of the view
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [saveButton setImage:[UIImage imageNamed:@"ico-save"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
}

- (void) getUserImage {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"getUserImage"
                                                                label:self.screenName
                                                                value:nil] build]];
    // user image is "hidden" while is getting its data on background
    self.userLittleImageView.alpha = 0.0;
    
    if (self.reviewedUser.pictures.count) {
        
        // the first picture is the one that is used in user profile (change this to the selected one)
        PFFile *file = self.reviewedUser.pictures[0];
        
        // Get image from cache or from server if isnt available (background task)
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            self.userLittleImageView.image = image;
            self.userLittleImageView.layer.cornerRadius = self.userLittleImageView.frame.size.height / 2.0;
            self.userLittleImageView.clipsToBounds = YES;
            
            // show imageView with nice effect
            [UIView showViewAnimated:self.userLittleImageView withAlpha:YES andDuration:0.3];
            
        }];
        
    }
    
}

#pragma mark - Navigation Bar Button Actions

- (void) saveButtonPressed {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"saveButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];

    [self.textView resignFirstResponder];
    
    // shows some loading view so the user can see that is saving
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    Review *review = [Review object];
    review.text = self.textView.text;
    review.stars = @(self.starRating.rating);
    review.from = [User currentUser];
    review.to = self.reviewedUser;
    review.deleted = @(NO);
    
    [PFObject saveAllInBackground:@[review] block:^(BOOL succeeded, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        [self.navigationController popViewControllerAnimated:YES];

    }];
    
}

#pragma mark - HPGrowingTextView Delegate Methods

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    CGFloat diff = (growingTextView.frame.size.height - height);
    
    setFrameY(self.separatorLine, CGRectGetMaxY(growingTextView.frame) - diff + 5.0);
    
    setFrameY(self.charCount, CGRectGetMaxY(self.separatorLine.frame) + 2.0 );
    
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //maximum textView chars = kAboutMeMaximumCharacters
    return growingTextView.text.length + (text.length - range.length) <= kReviewMaximumCharacters;
    
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    
    [self charRemainingUpdate];
    
}

- (void)charRemainingUpdate {
    
    self.charCount.text = [NSString stringWithFormat:@"%d %@",
                           (int)(kReviewMaximumCharacters - self.textView.text.length),
                           NSLocalizedString(@"editProfile.aboutMe.charsRemaining", nil)];
    
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
    
    // Scroll Tableview to selected Cell
    NSTimeInterval duration = [[notification userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        setFrameY(self.contentView, - CGRectGetMaxY(self.textView.frame) - self.navigationController.navigationBar.frame.size.height);
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
