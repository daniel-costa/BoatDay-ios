//
//  BDHostRegistrationTermsViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 04/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDHostRegistrationTermsViewController.h"
#import "BDTermsOfServiceViewController.h"
#import "BDAddEditBoatViewController.h"
#import "BDMyBoatsViewController.h"

@interface BDHostRegistrationTermsViewController ()

@property (strong, nonatomic) NSDictionary *hostRegistrationDictionary;

@property (nonatomic) BOOL consentBackgroundCheck;
@property (nonatomic) BOOL agreeWithTermsOfService;

@property (weak, nonatomic) IBOutlet UILabel *consentBackgroundLabel;
@property (weak, nonatomic) IBOutlet UIButton *consentBackgroundButton;
@property (weak, nonatomic) IBOutlet UILabel *agreeWithTermsOfServiceLabel;
@property (weak, nonatomic) IBOutlet UIButton *agreeWithTermsOfServiceButton;
@property (weak, nonatomic) IBOutlet UIButton *termsOfServiceButton;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

- (IBAction)submitButtonPressed:(id)sender;
- (IBAction)consentBackgroundButtonPressed:(id)sender;
- (IBAction)termsOfServiceButtonPressed:(id)sender;
- (IBAction)agreeWithTermsOfServiceButtonPressed:(id)sender;

@end

@implementation BDHostRegistrationTermsViewController

- (instancetype)initWithHostRegistrationDictionary:(NSDictionary *)dictionary{
    
    self = [super init];
    
    if( !self ) return nil;
    
    _hostRegistrationDictionary = dictionary;
    _consentBackgroundCheck = NO;
    _agreeWithTermsOfService = NO;
    
    return self;
    
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
        self.screenName =@"BDHostRegistrationTermsViewController";

    self.title = NSLocalizedString(@"hostRegistration.terms.title", nil);
    
    [self updateConsentBackgroundButton];
    [self updateAgreeWithTermsOfServiceButton];
    
    self.consentBackgroundLabel.text = NSLocalizedString(@"hostRegistration.terms.consentBackground", nil);
    self.consentBackgroundLabel.textColor = [UIColor grayBoatDay];
    self.consentBackgroundLabel.font = [UIFont abelFontWithSize:14.0];
    
    self.agreeWithTermsOfServiceLabel.text = NSLocalizedString(@"hostRegistration.terms.agreeWithTerms", nil);
    self.agreeWithTermsOfServiceLabel.textColor = [UIColor grayBoatDay];
    self.agreeWithTermsOfServiceLabel.font = [UIFont abelFontWithSize:14.0];
    
    [self.termsOfServiceButton setTitle:NSLocalizedString(@"hostRegistration.terms.termsOfService", nil) forState:UIControlStateNormal];
    [self.termsOfServiceButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.termsOfServiceButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    self.termsOfServiceButton.titleLabel.font = [UIFont abelFontWithSize:14.0];
    
    [self.submitButton setTitle:NSLocalizedString(@"hostRegistration.terms.submit", nil) forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont abelFontWithSize:24.0];
    
}

#pragma mark - IBAction Methods

- (IBAction)submitButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"submitButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    if (self.consentBackgroundCheck && self.agreeWithTermsOfService) {
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        HostRegistration *host = [Session sharedSession].hostRegistration ?: [HostRegistration object];
        
        host.user = [User currentUser];
        host.status = @(HostRegistrationStatusPending);
        host.driversLicenseImage = self.hostRegistrationDictionary[@"driversLicenseFile"];
        host.deleted = @(NO);
        
        [User currentUser].firstName = self.hostRegistrationDictionary[@"firstName"];
        [User currentUser].lastName = self.hostRegistrationDictionary[@"lastName"];
        [User currentUser].birthday = self.hostRegistrationDictionary[@"birthdayDate"];
        [User currentUser].firstLineAddress = self.hostRegistrationDictionary[@"firstAddressLine"];
        [User currentUser].city = self.hostRegistrationDictionary[@"city"];
        [User currentUser].state = self.hostRegistrationDictionary[@"state"];
        [User currentUser].zipCode = self.hostRegistrationDictionary[@"zipCode"];
        [User currentUser].phoneNumber = self.hostRegistrationDictionary[@"phoneNumber"];
        [User currentUser].ssnCode = self.hostRegistrationDictionary[@"ssnCode"];

        [User currentUser].hostRegistration = host;

        [PFObject saveAllInBackground:@[host, [User currentUser]] block:^(BOOL succeeded, NSError *error) {
            
            
            if (succeeded) {
                
                [Session sharedSession].hostRegistration = host;
                
                PFQuery *query = [Boat query];
                [query includeKey:@"safetyFeatures"];
                [query includeKey:@"rejectionMessage"];
                
                [query whereKey:@"owner" equalTo:[User currentUser]];
                [query whereKey:@"deleted" notEqualTo:@(YES)];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *boats, NSError *error) {
                    
                    [[Session sharedSession] updateUserData];
                    
                    Boat *pendingBoat = boats.count == 1 ? boats[0] : nil;
                    
                    [SVProgressHUD dismiss];
                    
                    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hostRegistration.submitedAlert.title", nil)
                                                                          message:NSLocalizedString(@"hostRegistration.submitedAlert.message", nil)
                                                                         delegate:nil
                                                                cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                                otherButtonTitles: nil];
                    
                    [myAlertView show];
                    
                    BDAddEditBoatViewController *editUBoatViewController = [[BDAddEditBoatViewController alloc] initWithBoat:pendingBoat];
                    
                    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:editUBoatViewController];
                    
                    [self presentViewController:navigationController animated:YES completion:^{
                        
                        UINavigationController * navigationController = [[MMNavigationController alloc] initWithRootViewController:[[BDMyBoatsViewController alloc] init]];
                        
                        [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
                        
                    }];
                    
                }];
                
            } else {
                
                [SVProgressHUD dismiss];
                
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hostRegistration.error.title", nil)
                                                                      message:NSLocalizedString(@"hostRegistration.error.message", nil)
                                                                     delegate:nil
                                                            cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                            otherButtonTitles: nil];
                
                [myAlertView show];
            }
            
        }];
        
    } else {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hostRegistration.checkboxesNotPressed.title", nil)
                                                              message:NSLocalizedString(@"hostRegistration.checkboxesNotPressed.message", nil)
                                                             delegate:nil
                                                    cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    
}

- (IBAction)consentBackgroundButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"consentBackgroundButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self.consentBackgroundButton.layer removeAllAnimations];
    self.consentBackgroundButton.transform = CGAffineTransformIdentity;
    
    self.consentBackgroundCheck = !self.consentBackgroundCheck;
    
    [self updateConsentBackgroundButton];
    
}

- (void) updateConsentBackgroundButton {
    
    if (self.consentBackgroundCheck) {
        [self.consentBackgroundButton setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
        [self.consentBackgroundButton setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateHighlighted];
        
    }
    else {
        [self.consentBackgroundButton setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        [self.consentBackgroundButton setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateHighlighted];
    }
    
}

- (IBAction)agreeWithTermsOfServiceButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"agreeWithTermsOfServiceButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self.agreeWithTermsOfServiceButton.layer removeAllAnimations];
    self.agreeWithTermsOfServiceButton.transform = CGAffineTransformIdentity;
    
    self.agreeWithTermsOfService = !self.agreeWithTermsOfService;
    
    [self updateAgreeWithTermsOfServiceButton];
    
}

- (void) updateAgreeWithTermsOfServiceButton {
    
    if (self.agreeWithTermsOfService) {
        [self.agreeWithTermsOfServiceButton setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateNormal];
        [self.agreeWithTermsOfServiceButton setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateHighlighted];
    }
    else {
        [self.agreeWithTermsOfServiceButton setImage:[UIImage imageNamed:@"check_off"] forState:UIControlStateNormal];
        [self.agreeWithTermsOfServiceButton setImage:[UIImage imageNamed:@"check_on"] forState:UIControlStateHighlighted];
    }
    
}

- (IBAction)termsOfServiceButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"termsOfServiceButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    BDTermsOfServiceViewController *termsViewController = [[BDTermsOfServiceViewController alloc] init];
    [self.navigationController pushViewController:termsViewController animated:YES];
    
}

@end
