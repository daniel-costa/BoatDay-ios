//
//  BDLoginViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 19/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDLoginViewController.h"
#import "BDHomeViewController.h"
#import "BDFindABoatDayViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface BDLoginViewController ()
- (IBAction)sideMenuButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *signInLaterButton;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (weak, nonatomic) IBOutlet UIButton *findABoatButton;
@property (weak, nonatomic) IBOutlet UILabel *mustLoginLabel;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

- (IBAction)loginFacebookButtonPressed:(id)sender;
- (IBAction)findABoatButtonPressed:(id)sender;

@end

@implementation BDLoginViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.screenName =@"BDLoginViewController";

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedInNotification:)
                                                 name:@"loginFailed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedInNotification:)
                                                 name:@"userLoggedIn"
                                               object:nil];
    
    self.navigationItem.leftBarButtonItem = nil;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self setupView];
    
    [self setupVideo];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

#pragma mark - Setup View Methods

- (void) setupView {
    
    [self setupVideo];
    
    self.facebookButton.titleLabel.font = [UIFont abelFontWithSize:18.0];
    [self.facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.facebookButton setTitle:NSLocalizedString(@"login.facebookButton.title", nil) forState:UIControlStateNormal];
    
    self.signInLaterButton.titleLabel.font = [UIFont abelFontWithSize:20.0];
    [self.signInLaterButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    [self.signInLaterButton setTitle:NSLocalizedString(@"login.signInLaterButton.title", nil) forState:UIControlStateNormal];
    
    self.mustLoginLabel.text = NSLocalizedString(@"home.mustBeLoggedIn.text", nil);
    self.mustLoginLabel.font = [UIFont abelFontWithSize:11.0];
    self.mustLoginLabel.textColor = [UIColor whiteColor];
    
    self.findABoatButton.titleLabel.font = [UIFont abelFontWithSize:20.0];
    [self.findABoatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.findABoatButton setTitle:NSLocalizedString(@"home.findABoatButton.title", nil) forState:UIControlStateNormal];
    
}

- (void) setupVideo {
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    
    NSURL *movieUrl = [[NSBundle mainBundle] URLForResource:@"background"  withExtension:@"mp4"];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieUrl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidStateChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.moviePlayer];
    
    self.moviePlayer.backgroundView.backgroundColor = [UIColor clearColor];
    self.moviePlayer.view.backgroundColor = [UIColor clearColor];
    
    for(UIView *aSubView in self.moviePlayer.view.subviews) {
        aSubView.backgroundColor = [UIColor clearColor];
    }
    
    self.moviePlayer.view.frame = screen;
    self.moviePlayer.scalingMode = MPMovieScalingModeFill;
    [self.moviePlayer setControlStyle:MPMovieControlStyleNone];
    
    [[self.videoView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.videoView addSubview:self.moviePlayer.view];
    
    [self.moviePlayer prepareToPlay];
    
}

- (void)moviePlayerDidStateChange:(NSNotification *)note {
    
    MPMoviePlayerController* playerController = note.object;
    
    if ([playerController loadState] & MPMovieLoadStatePlayable) {
        
        if (self.moviePlayer) {
            
            [self.moviePlayer play];
            
        }
        
    }
    
}

- (void)moviePlayerDidFinish:(NSNotification *)note
{
    if (note.object == self.moviePlayer) {
        
        NSInteger reason = [note.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
        
        if (reason == MPMovieFinishReasonPlaybackEnded) {
            
            [self.moviePlayer play];
            
        }
        
    }
    
}


- (void) goToHome {
    
    // Enable side menu
    // [self.navigationController.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    // [self.navigationController.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    UIViewController *viewController = [[MMNavigationController alloc] initWithRootViewController:[[BDHomeViewController alloc] init]];
    
    [self.mm_drawerController setCenterViewController:viewController withCloseAnimation:NO completion:nil];
    
}


#pragma mark - IBAction Methods

- (IBAction)loginFacebookButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"loginFacebookButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    self.activityIndicator.hidden = NO;
    self.facebookButton.enabled = NO;
    
    // Ask for all the permissions so we can access all the data we want
    NSArray *permissionsArray = @[@"user_about_me",@"user_birthday",@"user_location", @"email", @"user_friends"];

    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (user) {
            
            // Store the deviceToken in the current Installation and save it to Parse.
            [PFInstallation currentInstallation][@"user"] = [PFUser currentUser];
            [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                [self fetchFriends:^(NSMutableArray *friends) {
                    
                    [User currentUser].friendsFacebookID = friends;
                    [[User currentUser] saveEventually];
                    
                }];
                
                [[NSUserDefaults standardUserDefaults] setValue:PFFacebookUtils.session.accessTokenData.accessToken forKey:@"fb_access_token"];
                [[NSUserDefaults standardUserDefaults] setObject:PFFacebookUtils.session.accessTokenData.expirationDate forKey:@"fb_expiration_date"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (![NSString isStringEmpty:user[@"firstName"]]) {
                    
                    // get user certifications and reviews relation
                    [[Session sharedSession] getUserRelationshipsData];
                    
                    
                } else {
                    
                    [self getFacebookUserDataWithblock:^(BOOL response) {
                        
                        if (response) {
                            
                            // get user certifications relation
                            [[Session sharedSession] getUserRelationshipsData];
                            
                        }
                        else {
                            
                            [self showFacebookLoginFailedAlertView];
                            
                        }
                        
                    }];
                }
                
            }];
            
            
        } else {
            
            [self showFacebookLoginFailedAlertView];
            
        }
        
    }];
    
}

- (IBAction)findABoatButtonPressed:(id)sender {
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"findABoatButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];
    BDFindABoatDayViewController *viewController = [[BDFindABoatDayViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

#pragma mark - Facebook & Parse Methods

- (void)getFacebookUserDataWithblock:(SimpleBooleanBlock)block {
    
    // When we login, it stores the login data on parse (and create user if needed)
    // But the information about the user is not filled
    // We need to do that manually
    NSString *requestPath = @"me/?fields=name,location,gender,birthday,picture,email";
    
    FBRequest *request = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:requestPath];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSDictionary *userData = (NSDictionary *)result; // The result is a dictionary
        
        [self setUserDataOnParseWithFacebookResponseDictionary:userData];
        
        block(!error);
        
    }];
    
}

- (void) setUserDataOnParseWithFacebookResponseDictionary:(NSDictionary *)userData {
    
    NSString *userID = userData[@"id"];
    NSString *name = userData[@"name"];
    NSString *email = userData[@"email"];
    
    NSString *location = userData[@"location"][@"name"];
    NSArray *locationSplit = [location componentsSeparatedByString:@", "];
    
    NSString *city = locationSplit[0];
    NSString *country = locationSplit.count > 1 ? locationSplit[1] : @"";
    
    NSString *birthday = userData[@"birthday"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *birthDayDate = [formatter dateFromString:birthday];
    
    // get the FB user's profile image
    NSString *picture = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userID];
    NSURL *url = [NSURL URLWithString:picture];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    PFFile *imageFile = [PFFile fileWithName:@"Image_0.png" data:imageData];
    
    [User currentUser].facebookID = userID;
    [User currentUser].email = email;
    [User currentUser].city = city;
    [User currentUser].country = country;
    [User currentUser].birthday = birthDayDate;
    [User currentUser].pictures = [NSMutableArray arrayWithArray:@[imageFile]];
    [User currentUser].selectedPictureIndex = @(0);
    [User currentUser].fullName = name;
    [User currentUser].deleted = @(NO);
    
    // Get first and last name
    NSArray *separatedNameArray = [name componentsSeparatedByString: @" "];
    if (separatedNameArray.count) [User currentUser].firstName = separatedNameArray[0];
    if (separatedNameArray.count > 1) [User currentUser].lastName = separatedNameArray[separatedNameArray.count-1];
    
    [[User currentUser] save];
    
}

- (void)fetchFriends:(void(^)(NSMutableArray *friends))callback {
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id response, NSError *error) {
        
        NSMutableArray *friends = [NSMutableArray new];
        
        if (!error) {
            
            NSArray *responseArray = (NSArray*)[response data];
            
            for (NSDictionary *userDict in responseArray) {
                [friends addObject:userDict[@"id"]];
            }
        }
        
        callback(friends);
        
    }];
    
}

#pragma mark - AlertView Methods

- (void) showFacebookLoginFailedAlertView {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login.facebookFailedAlert.title", nil)
                                                    message:NSLocalizedString(@"login.facebookFailedAlert.message", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                          otherButtonTitles:nil];
    [alert show];
    self.facebookButton.enabled = YES;
    self.activityIndicator.hidden = YES;
    
}

#pragma mark - Notification Methods

- (void) userLoggedInNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"userLoggedIn"]) {
        
        [self goToHome];
        
    }
    
    if ([[notification name] isEqualToString:@"loginFailed"]) {
        
        [self showFacebookLoginFailedAlertView];
    }
    
}

#pragma mark - IBAction Methods

- (IBAction)sideMenuButtonPressed:(id)sender {
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}

@end
