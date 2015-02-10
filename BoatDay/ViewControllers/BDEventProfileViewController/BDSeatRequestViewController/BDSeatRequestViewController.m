//
//  BDSeatRequestViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 05/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDSeatRequestViewController.h"
#import "HPGrowingTextView.h"
#import <CoreText/CTStringAttributes.h>
#import <CoreText/CoreText.h>
#import <Braintree/Braintree.h>

static NSInteger const kMessageMaximumCharacters = 500;

@interface BDSeatRequestViewController () <UITextViewDelegate, HPGrowingTextViewDelegate, BTDropInViewControllerDelegate>

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) SeatRequest *seatRequest;
@property (strong, nonatomic) Notification *notification;
@property (weak, nonatomic) IBOutlet UILabel *paymentInformationLabel;

@property (weak, nonatomic) IBOutlet UIView *eventInformationView;
@property (weak, nonatomic) IBOutlet UIImageView *eventPicture;
@property (weak, nonatomic) IBOutlet UILabel *hostLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableSeatsLabel;

@property (weak, nonatomic) IBOutlet UIView *addSeatsView;
@property (weak, nonatomic) IBOutlet UILabel *requestedSeatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatsLabel;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *textView;
@property (weak, nonatomic) IBOutlet UIView *separatorLine;
@property (weak, nonatomic) IBOutlet UILabel *charCount;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *sendRequestButton;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@property (nonatomic) NSInteger requestedSeats;
@property (nonatomic) NSInteger availableSeats;

@property (nonatomic) BOOL creditCardAdded;

- (IBAction)minusButtonPressed:(id)sender;
- (IBAction)plusButtonPressed:(id)sender;
- (IBAction)sendRequestPressedButton:(id)sender;

@end

@implementation BDSeatRequestViewController

- (instancetype)initWithEvent:(Event *)event {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _event = event;
    _requestedSeats = 1;
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.screenName =@"BDSeatRequestViewController";

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
    
    if (self.event.boat.pictures.count && [self.event.boat.selectedPictureIndex integerValue] >= 0) {
        
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
    
    self.paymentInformationLabel.text = NSLocalizedString(@"seatRequests.providePaymentInfoLabel", nil);
    self.paymentInformationLabel.textColor = [UIColor greenBoatDay];
    self.paymentInformationLabel.font = [UIFont abelFontWithSize:12.0];
    
    self.hostLabel.text = self.event.name;
    self.hostLabel.textColor = [UIColor whiteColor];
    self.hostLabel.font = [UIFont quattroCentoBoldFontWithSize:16.0];
    
    self.dateLabel.text = self.event.name;
    self.dateLabel.textColor = [UIColor eventsDarkGreenBoatDay];
    self.dateLabel.font = [UIFont quattroCentoRegularFontWithSize:11.0];
    
    NSString *coinSymbol = NSLocalizedString(@"coinSymbol", nil);
    ;
    [self formatLabelWithPriceStringWithPrice:@([GetSeatPrice(self.event.price) integerValue]) andCoinSymbol:coinSymbol withSize:39.0 forLabel:self.priceLabel];
    [self formatLabelWithPriceStringWithPrice:@([GetSeatPrice([NSNumber numberWithInteger:0]) integerValue]) andCoinSymbol:coinSymbol withSize:12.0 forLabel:self.priceFeeLabel];
    
    NSInteger numberOfUsersAttending = 0;
    
    // Check for user seats request
    for (SeatRequest *request in self.event.seatRequests) {
        if(![request isEqual:[NSNull null]]) {
            
            if ([request.status integerValue] == SeatRequestStatusAccepted) {
                numberOfUsersAttending += [request.numberOfSeats integerValue];
            }
        }
    }
    
    self.availableSeats = [self.event.availableSeats integerValue] - numberOfUsersAttending;
    
    self.availableSeatsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"seatRequests.avaialableSeats", nil), (long)self.availableSeats, (long)[self.event.availableSeats integerValue]];
    self.availableSeatsLabel.backgroundColor = [UIColor greenBoatDay];
    self.availableSeatsLabel.textColor = [UIColor whiteColor];
    self.availableSeatsLabel.font = [UIFont abelFontWithSize:12.0];
    
    self.requestedSeatsLabel.backgroundColor = [UIColor clearColor];
    self.requestedSeatsLabel.textColor = [UIColor whiteColor];
    self.requestedSeatsLabel.font = [UIFont abelFontWithSize:30.0];
    self.requestedSeatsLabel.text = [@(self.requestedSeats) stringValue];
    self.requestedSeatsLabel.minimumScaleFactor = 0.7;
    self.requestedSeatsLabel.adjustsFontSizeToFitWidth = YES;
    
    self.seatsLabel.backgroundColor = [UIColor clearColor];
    self.seatsLabel.textColor = [UIColor whiteColor];
    self.seatsLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.seatsLabel.text = self.requestedSeats == 1 ?  NSLocalizedString(@"eventProfile.seat", nil): NSLocalizedString(@"eventProfile.seatsRequest", nil);
    
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
    
    [self.sendRequestButton setTitle:NSLocalizedString(@"seatRequest.sendRequest", nil) forState:UIControlStateNormal];
    [self.sendRequestButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_off"] forState:UIControlStateNormal];
    [self.sendRequestButton setBackgroundImage:[UIImage imageNamed:@"button_lg_yellow_on"] forState:UIControlStateHighlighted];
    
}

- (void) setupNavigationBar {
    
    self.title = NSLocalizedString(@"seatRequests.title", nil);
    
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
    
    [self playSound:@"minus-button"];
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"minusButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    self.requestedSeats--;
    
    if (self.requestedSeats < 1) {
        self.requestedSeats = 1;
    }
    
    self.requestedSeatsLabel.text = [@(self.requestedSeats) stringValue];
    self.seatsLabel.text = self.requestedSeats == 1 ?  NSLocalizedString(@"eventProfile.seat", nil): NSLocalizedString(@"eventProfile.seatsRequest", nil);
    
    NSString *coinSymbol = NSLocalizedString(@"coinSymbol", nil);
    
    double pricePerSeat = [GetSeatPrice(self.event.price) doubleValue];
    [self formatLabelWithPriceStringWithPrice:@(pricePerSeat * self.requestedSeats)
                                andCoinSymbol:coinSymbol withSize:39.0 forLabel:self.priceLabel];
    [self formatLabelWithPriceStringWithPrice:@([GetSeatPrice([NSNumber numberWithInteger:0]) integerValue] * self.requestedSeats)
                                andCoinSymbol:coinSymbol withSize:12.0 forLabel:self.priceFeeLabel];
    
}

- (IBAction)plusButtonPressed:(id)sender {
    
    [self playSound:@"plus-button"];
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"plusButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    self.requestedSeats++;
    
    if (self.requestedSeats > self.availableSeats) {
        self.requestedSeats = self.availableSeats;
    }
    
    self.requestedSeatsLabel.text = [@(self.requestedSeats) stringValue];
    self.seatsLabel.text = self.requestedSeats == 1 ?  NSLocalizedString(@"eventProfile.seat", nil): NSLocalizedString(@"eventProfile.seatsRequest", nil);
    
    NSString *coinSymbol = NSLocalizedString(@"coinSymbol", nil);
    
    double pricePerSeat = [GetSeatPrice(self.event.price) doubleValue];
    [self formatLabelWithPriceStringWithPrice:@(pricePerSeat * self.requestedSeats)
                                andCoinSymbol:coinSymbol withSize:39.0 forLabel:self.priceLabel];
    [self formatLabelWithPriceStringWithPrice:@([GetSeatPrice([NSNumber numberWithInteger:0]) integerValue] * self.requestedSeats)
                                andCoinSymbol:coinSymbol withSize:12.0 forLabel:self.priceFeeLabel];

}

- (IBAction)sendRequestPressedButton:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"sendRequestPressedButton"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self.textView resignFirstResponder];
    
    [self createSeatRequest];
    
}


- (void)formatLabelWithPriceStringWithPrice:(NSNumber *)price andCoinSymbol:(NSString *)coinSymbol withSize: (double) fontSize forLabel: (UILabel *) label {
    
    NSString *string = [NSString stringWithFormat:@"%@%@", coinSymbol, price];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];
    UIFont *font = [UIFont fontWithName:label.font.fontName size: fontSize];
    UIFont *smallFont = [UIFont fontWithName:label.font.fontName size: fontSize * 0.6];

    [attString beginEditing];
    [attString addAttribute:NSFontAttributeName value:(font) range:NSMakeRange(1, string.length - 1)];
    [attString addAttribute:NSFontAttributeName value:(smallFont) range:NSMakeRange(0, 1)];
    [attString addAttribute:(NSString*)kCTSuperscriptAttributeName value:@"1" range:NSMakeRange(0, 1)];
    
    [attString addAttribute:(NSString*)kCTForegroundColorAttributeName value:label.textColor range:NSMakeRange(0, string.length - 1)];
    [attString endEditing];
    
    label.attributedText = attString;
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
    
    self.minusButton.userInteractionEnabled = NO;
    self.plusButton.userInteractionEnabled = NO;
    
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
    
    self.minusButton.userInteractionEnabled = YES;
    self.plusButton.userInteractionEnabled = YES;
    
}

#pragma mark - Seat Request Methods

- (void) createSeatRequest {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    [[BDPaymentServiceManager sharedManager] getClientTokenWithCustomerID:[User currentUser].braintreeCustomerId withBlock:^(NSString *clientToken, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (clientToken) {
            
            [self openBraintreeDropInUIWithClientToken:clientToken];
            
        } else {
            
            [self seatRequestFlowFailed];
            
        }
        
    }];
    
}

#pragma mark - Braintree Methods

- (void)openBraintreeDropInUIWithClientToken:(NSString*)clientToken {
    
    // Create a Braintree with the client token
    Braintree *braintree = [Braintree braintreeWithClientToken:clientToken];
    
    // Create a BTDropInViewController
    BTDropInViewController *dropInViewController = [braintree dropInViewControllerWithDelegate:self];
    
    // This is where you might want to customize your Drop in. (See below.)
    
    dropInViewController.callToActionText = NSLocalizedString(@"seatRequest.addCreditCard", nil);
    
    // Or, upon initialization
    dropInViewController.view.tintColor = [UIColor colorWithRed:255/255.0f green:136/255.0f blue:51/255.0f alpha:1.0f];
    
    // The way you present your BTDropInViewController instance is up to you.
    // In this example, we wrap it in a new, modally presented navigation controller:
    dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                             target:self
                                                             action:@selector(userDidCancelPayment)];
    
    [self.navigationController pushViewController:dropInViewController animated:YES];
    
}

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    
    if (!self.creditCardAdded) {
        
        self.creditCardAdded = YES;
        
        User *user = [User currentUser];
        
        NSString *nonce = paymentMethod.nonce;
        
        [[BDPaymentServiceManager sharedManager] addCreditCardWithUserId:user.objectId
                                                                   nonce:nonce
                                                            sessionToken:user.sessionToken
                                                               withBlock:^(BOOL success, NSError *error) {
                                                                   
                                                                   if (success) {
                                                                       
                                                                       [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                                                                           
                                                                           [self saveSeatRequest];
                                                                           
                                                                       }];
                                                                       
                                                                   } else {
                                                                       
                                                                       [self userDidCancelPayment];
                                                                       
                                                                   }
                                                               }];
    }
    
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    
    [self userDidCancelPayment];
    
}

- (void)userDidCancelPayment {
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self performBlock:^{
        self.creditCardAdded = NO;
    } afterDelay:1.0];
    
}

- (void) saveSeatRequest {
    
    SeatRequest *userRequest = nil;
    
    for (SeatRequest *request in self.event.seatRequests) {
        if(![request isEqual:[NSNull null]]) {
            if ([request.user isEqual:[User currentUser]]) {
                userRequest = request;
            }
        }
    }
    
    if(userRequest) {
        userRequest.numberOfSeats = @(self.requestedSeats);
        userRequest.status = @(SeatRequestStatusPending);
        userRequest.pendingInvite = @(NO);
        userRequest.message = self.textView.text;
        userRequest.deleted = @(NO);
        self.seatRequest = userRequest;
    } else {
        SeatRequest *seatRequest = [SeatRequest object];
        seatRequest.user = [User currentUser];
        seatRequest.event = self.event;
        seatRequest.numberOfSeats = @(self.requestedSeats);
        seatRequest.status = @(SeatRequestStatusPending);
        seatRequest.pendingInvite = @(NO);
        seatRequest.message = self.textView.text;
        seatRequest.deleted = @(NO);
        self.seatRequest = seatRequest;
        
        if(!self.event.seatRequests) {
            self.event.seatRequests = [[NSMutableArray alloc] init];
        }
        
        [self.event.seatRequests addObject:seatRequest];
    }
    
    Notification *notification = [Notification object];
    notification.user = self.event.host;
    notification.seatRequest = self.seatRequest;
    notification.read = @(NO);
    notification.notificationType = @(NotificationTypeSeatRequest);
    notification.deleted = @(NO);
    
    NSString *message = @"";
    NSInteger numberOfSeats = [notification.seatRequest.numberOfSeats integerValue];
    
    if (numberOfSeats == 1) {
        message = [NSString stringWithFormat:NSLocalizedString(@"notifications.type.seatRequestSingle", nil), notification.seatRequest.numberOfSeats];
    }
    else {
        message = [NSString stringWithFormat:NSLocalizedString(@"notifications.type.seatRequest", nil), notification.seatRequest.numberOfSeats];
    }
    
    notification.text = [NSString stringWithFormat:@"%@ for \"%@\" event.", message, self.event.name];
    
    self.notification = notification;
    
    [PFObject saveAllInBackground:@[self.seatRequest, self.event, self.notification] block:^(BOOL succeeded, NSError *error) {
        
        if(succeeded){
            
            [self.navigationController popViewControllerAnimated:YES];
            
            [self performBlock:^{
                self.creditCardAdded = NO;
            } afterDelay:1.0];
            
            [self cancelButtonPressed];
            
        } else {
            
            [self seatRequestFlowFailed];
        }
        
    }];
    
}

- (void) seatRequestFlowFailed {
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"errorMessages.seatRequest.title", nil)
                                                          message:NSLocalizedString(@"errorMessages.seatRequest.message", nil)
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                otherButtonTitles: nil];
    
    [myAlertView show];

}

@end
