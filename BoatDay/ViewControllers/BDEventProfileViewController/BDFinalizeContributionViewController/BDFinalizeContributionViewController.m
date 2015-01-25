//
//  BDFinalizeContributionViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 05/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFinalizeContributionViewController.h"
#import "HPGrowingTextView.h"
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CoreText.h>
#import "UIAlertView+Blocks.h"

static NSInteger const kMessageMaximumCharacters = 500;

@interface BDFinalizeContributionViewController () <UITextViewDelegate, HPGrowingTextViewDelegate>

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) SeatRequest *seatRequest;
@property (strong, nonatomic) Notification *notification;

@property (weak, nonatomic) IBOutlet UIView *eventInformationView;
@property (weak, nonatomic) IBOutlet UIImageView *eventPicture;
@property (weak, nonatomic) IBOutlet UILabel *hostLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalContributionLabel;

@property (weak, nonatomic) IBOutlet UIView *addSeatsView;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *textView;
@property (weak, nonatomic) IBOutlet UIView *separatorLine;
@property (weak, nonatomic) IBOutlet UILabel *charCount;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *sendRequestButton;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (nonatomic) NSInteger contribution;

- (IBAction)minusButtonPressed:(id)sender;
- (IBAction)plusButtonPressed:(id)sender;
- (IBAction)sendRequestPressedButton:(id)sender;

@end

@implementation BDFinalizeContributionViewController

- (instancetype)initWithEvent:(Event *)event andSeatRequest:(SeatRequest*)seatRequest{
    
    self = [super init];
    
    if( !self ) return nil;
    
    _event = event;
    _seatRequest = seatRequest;
    _contribution = [seatRequest.numberOfSeats integerValue] * [event.price floatValue];
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.screenName =@"BDFinalizeContributionViewController";

    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // set keyboard observers to be called when textFields and textFields are responders
    //   we will need to scroll the table to show the field that is being editing
    [self addKeyboardObservers];
    
    // setup navigation bar button
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

- (void) setupView {
    
    if (self.event.boat.pictures.count) {
        
        self.eventPicture.alpha = 0;
        
        // the first picture is the one that is used in user profile (change this to the selected one)
        PFFile *file = self.event.boat.pictures[[self.event.boat.selectedPictureIndex integerValue]];
        
        // Get image from cache or from server if isnt available (background task)
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            self.eventPicture.image = image;
            
            self.eventPicture.layer.masksToBounds = YES;
            self.eventPicture.layer.borderColor = [UIColor blackColor].CGColor;
            self.eventPicture.layer.borderWidth = 1;
            
            [UIView setRoundedView:self.eventPicture
                        toDiameter:CGRectGetHeight(self.eventPicture.frame)];
            
            [UIView showViewAnimated:self.eventPicture
                           withAlpha:YES
                            duration:0.2
                            andDelay:0.0
                            andScale:NO];
            
        }];
        
    }
    
    self.hostLabel.text = self.event.name;
    self.hostLabel.textColor = [UIColor whiteColor];
    self.hostLabel.font = [UIFont quattroCentoBoldFontWithSize:16.0];
    
    self.dateLabel.text = self.event.name;
    self.dateLabel.textColor = [UIColor eventsDarkGreenBoatDay];
    self.dateLabel.font = [UIFont quattroCentoRegularFontWithSize:11.0];
    
    NSString *coinSymbol = NSLocalizedString(@"coinSymbol", nil);
    self.priceLabel.attributedText = [self createPriceStringWithPrice:@(self.contribution) andCoinSymbol:coinSymbol];
    
    NSInteger numberOfUsersAttending = 0;
    
    // Check for user seats request
    for (SeatRequest *request in self.event.seatRequests) {
        
        if(![request isEqual:[NSNull null]]) {
            
            if ([request.status integerValue] == SeatRequestStatusAccepted) {
                numberOfUsersAttending += [request.numberOfSeats integerValue];
            }
            
        }
        
    }
    
    self.totalContributionLabel.text = NSLocalizedString(@"seatRequests.totalContribution", nil);
    self.totalContributionLabel.backgroundColor = [UIColor greenBoatDay];
    self.totalContributionLabel.textColor = [UIColor whiteColor];
    self.totalContributionLabel.font = [UIFont abelFontWithSize:12.0];
    
    self.charCount.font = [UIFont abelFontWithSize:12.0];
    self.charCount.textColor = [UIColor grayBoatDay];
    
    [self charRemainingUpdate];
    
    self.textView.isScrollable = YES;
    self.textView.contentInset = UIEdgeInsetsMake(0, -4, 0, 0);
    self.textView.minNumberOfLines = 1;
    self.textView.maxNumberOfLines = 4;
    self.textView.returnKeyType = UIReturnKeyDefault; //just as an example
    self.textView.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textColor = [UIColor greenBoatDay];
    self.textView.placeholder = NSLocalizedString(@"seatsRequest.textView.placeholder", @"");
    self.textView.placeholderColor = [UIColor grayBoatDay];
    self.textView.tintColor = [UIColor greenBoatDay];
    
    self.sendRequestButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
    
    [self.sendRequestButton setTitle:NSLocalizedString(@"seatRequest.submit", nil) forState:UIControlStateNormal];
    [self.sendRequestButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_off"] forState:UIControlStateNormal];
    [self.sendRequestButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_on"] forState:UIControlStateHighlighted];
    
}

- (void) setupNavigationBar {
    
    self.title = NSLocalizedString(@"finalizeContribution.title", nil);
    
    // create cancel button to navigatio bar at top of the view
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"editProfile.cancel", nil)
                                     style:UIBarButtonItemStyleDone
                                     target:self
                                     action:@selector(cancelButtonPressed)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    
}

#pragma mark - Navigation Bar Button Actions

- (void) cancelButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"cancelButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self.textView resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)minusButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"minusButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    self.contribution--;
    
    if (self.contribution < 0) {
        self.contribution = 0;
    }
    
    NSString *coinSymbol = NSLocalizedString(@"coinSymbol", nil);
    self.priceLabel.attributedText = [self createPriceStringWithPrice:@(self.contribution) andCoinSymbol:coinSymbol];
    
}

- (IBAction)plusButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"plusButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    self.contribution++;
    
    NSString *coinSymbol = NSLocalizedString(@"coinSymbol", nil);
    self.priceLabel.attributedText = [self createPriceStringWithPrice:@(self.contribution) andCoinSymbol:coinSymbol];
    
}

- (IBAction)sendRequestPressedButton:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"sendRequestPressedButton"
                                                                label:self.screenName
                                                                value:nil] build]];

    
    [self.textView resignFirstResponder];
    
    [self finalizePayment];
    
}

#pragma mark - String Methods

- (NSMutableAttributedString *)createPriceStringWithPrice:(NSNumber *)price andCoinSymbol:(NSString *)coinSymbol {
    
    NSString *string = [NSString stringWithFormat:@"%@%@", coinSymbol, price];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *font = [UIFont abelFontWithSize:39.0];
    UIFont *smallFont = [UIFont abelFontWithSize:24.0];
    
    [attString beginEditing];
    [attString addAttribute:NSFontAttributeName value:(font) range:NSMakeRange(1, string.length - 1)];
    [attString addAttribute:NSFontAttributeName value:(smallFont) range:NSMakeRange(0, 1)];
    [attString addAttribute:(NSString*)kCTSuperscriptAttributeName value:@"1" range:NSMakeRange(0, 1)];
    
    [attString addAttribute:(NSString*)kCTForegroundColorAttributeName value:self.priceLabel.textColor range:NSMakeRange(0, string.length - 1)];
    [attString endEditing];
    
    return attString;
    
}

#pragma mark - HPGrowingTextView Delegate Methods

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    CGFloat diff = (growingTextView.frame.size.height - height);
    
    setFrameY(self.separatorLine, CGRectGetMaxY(growingTextView.frame) - diff + 5.0);
    
    setFrameY(self.charCount, CGRectGetMaxY(self.separatorLine.frame) + 2.0 );
    
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //maximum textView chars = kAboutMeMaximumCharacters
    return growingTextView.text.length + (text.length - range.length) <= kMessageMaximumCharacters;
    
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    
    [self charRemainingUpdate];
    
}

- (void)charRemainingUpdate {
    
    self.charCount.text = [NSString stringWithFormat:@"%d %@",
                           (int)(kMessageMaximumCharacters - self.textView.text.length),
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

#pragma mark - Payment Methods

- (void) finalizePayment {
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"finalizeContribution.confirmation.title", nil)
                                message:NSLocalizedString(@"finalizeContribution.message", nil)
                       cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.noButton", nil) action:nil]
                       otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"certifications.delete.yesButton", nil) action:^{
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        User *user = [User currentUser];
        
        [[BDPaymentServiceManager sharedManager] chargeContributionWithRequestID:self.seatRequest.objectId sessionToken:user.sessionToken paymentToken:user.braintreePaymentToken merchantID:self.event.host.hostRegistration.merchantId amount:[@(self.contribution) stringValue] withBlock:^(BOOL success, NSString *error) {
            
            if (success) {
                self.seatRequest.userDidPayFromTheApp = @(YES);
                [self.seatRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        [SVProgressHUD dismiss];
                        [self cancelButtonPressed];
                        
                    } else {
                        
                        [self showPaymentErrorAlertViewWithMessage:NSLocalizedString(@"finalizeContribution.error.message", nil)];
                        
                    }
                    
                }];
                
            } else {
                
                [self showPaymentErrorAlertViewWithMessage:error];
                
            }
            
        }];
        
    }], nil] show];
    
}

- (void) showPaymentErrorAlertViewWithMessage:(NSString*)errorMessage {
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"finalizeContribution.error.title", nil)
                                                          message:errorMessage ?: NSLocalizedString(@"finalizeContributions.error.defaultMessage", nil)
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                otherButtonTitles: nil];
    
    [myAlertView show];
    
    [SVProgressHUD dismiss];
    
}

@end
