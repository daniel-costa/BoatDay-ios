//
//  BDPaymentStatusViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 09/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDPaymentStatusViewController.h"
#import "BDPaymentInfoViewController.h"

@interface BDPaymentStatusViewController ()

@property (strong, nonatomic) HostRegistration *hostRegistration;

@property (weak, nonatomic) IBOutlet UILabel *successLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end

@implementation BDPaymentStatusViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"paymentStatus.title", nil);
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(merchantApprovedNotification:)
                                                 name:@"merchantApproved"
                                               object:nil];

    
    [self addActivityViewforView:self.contentView];
    
    [self getData];
    
    if ([((MMNavigationController *)self.parentViewController).viewControllers[0] isKindOfClass:[BDPaymentStatusViewController class]]) {
        
        // create cancel button to navigatio bar at top of the view
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                         initWithTitle:NSLocalizedString(@"paymentStatus.done", nil)
                                         style:UIBarButtonItemStyleDone
                                         target:self
                                         action:@selector(cancelButtonPressed)];
        
        self.navigationItem.rightBarButtonItem = cancelButton;
        self.navigationItem.leftBarButtonItem = nil;
        
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
 
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark - Setup Methods

- (void) setupView {
    
    self.successLabel.text = NSLocalizedString(@"paymentStatus.success", nil);
    self.successLabel.font = [UIFont quattroCentoBoldFontWithSize:16.0];
    self.successLabel.textColor = [UIColor mediumGreenBoatDay];
    
    self.messageLabel.text = NSLocalizedString(@"paymentStatus.message", nil);
    self.messageLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.messageLabel.textColor = [UIColor grayBoatDay];
    
    self.statusTitleLabel.text = NSLocalizedString(@"paymentStatus.statusTitle", nil);
    self.statusTitleLabel.font = [UIFont quattroCentoBoldFontWithSize:16.0];
    self.statusTitleLabel.textColor = [UIColor mediumGreenBoatDay];
    
    self.statusLabel.font = [UIFont quattroCentoRegularFontWithSize:16.0];
    self.statusLabel.textColor = [UIColor grayBoatDay];

    [self updateStatus];
    
}

- (void) updateStatus {

    self.hostRegistration = [Session sharedSession].hostRegistration;
    
    self.statusLabel.text = [self.hostRegistration.merchantStatus capitalizedString];
    
    if ([NSString isStringEmpty:self.statusLabel.text]) {
        self.statusLabel.text = NSLocalizedString(@"paymentStatus.pending", nil);
    }
    
    if ([self.hostRegistration.merchantStatus isEqualToString:@"active"]) {
        
        self.statusImageView.image = [UIImage imageNamed:@"cert_approved"];
        
    } else if ([self.hostRegistration.merchantStatus isEqualToString:@"pending"]) {
        
        self.statusImageView.image = [UIImage imageNamed:@"cert_pending"];
        
    } else if ([self.hostRegistration.merchantStatus isEqualToString:@"suspended"]) {
        
        self.statusImageView.image = [UIImage imageNamed:@"cert_denied"];
        
    }

}

- (void) setupNavigationBar {
    
    // create save button to navigatio bar at top of the view
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [editButton setImage:[UIImage imageNamed:@"ico-Edit"] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
}

#pragma mark - Data Methods

- (void) getData {
    
    [[Session sharedSession].hostRegistration fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        self.hostRegistration = [Session sharedSession].hostRegistration;
        
        [self setupView];
        
        if (![self.hostRegistration.merchantStatus isEqualToString:@"pending"]) {
            
            if (![((MMNavigationController *)self.parentViewController).viewControllers[0] isKindOfClass:[BDPaymentStatusViewController class]]) {
                // setup navigation bar buttons
                [self setupNavigationBar];
            }

        }
        
        [self removeActivityViewFromView:self.contentView];
        
    }];
    
}

#pragma mark - Action Methods

-(void) editButtonPressed:(id)sender {
    
    BDPaymentInfoViewController *paymentInfoViewController = [[BDPaymentInfoViewController alloc] initWithMerchantId:self.hostRegistration.merchantId];
    [self.navigationController pushViewController:paymentInfoViewController animated:YES];
    
}

- (void) cancelButtonPressed {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - Notification Methods

- (void) merchantApprovedNotification:(NSNotification *) notification {
    
    [self updateStatus];
    
}

@end
