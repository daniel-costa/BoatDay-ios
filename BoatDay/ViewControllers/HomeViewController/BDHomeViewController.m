//
//  BDHomeViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 19/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDHomeViewController.h"
#import "BDEditProfileViewController.h"
#import "BDProfileViewController.h"
#import "BDFindUsersViewController.h"
#import "BDFindABoatDayViewController.h"
#import "BDAddEditEventProfileViewController.h"
#import "BDHostRegistrationViewController.h"
#import "BDLoginViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface BDHomeViewController ()

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *findABoatButton;
@property (weak, nonatomic) IBOutlet UIButton *createBoatDayButton;
@property (weak, nonatomic) IBOutlet UIButton *findPassengersButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityMonitor;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

- (IBAction)findABoatButtonPressed:(id)sender;
- (IBAction)createBoatDayButtonPressed:(id)sender;
- (IBAction)findPassengersButtonPressed:(id)sender;

@end

@implementation BDHomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self setupVideo];
    
    self.findABoatButton.alpha = 0.0;
    self.createBoatDayButton.alpha = 0.0;
    self.findPassengersButton.alpha = 0.0;
    self.activityMonitor.alpha = 1.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedInNotification:)
                                                 name:@"loginFailed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedInNotification:)
                                                 name:@"userLoggedIn"
                                               object:nil];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (![[Session sharedSession] dataWasFechted]) {
        
        [[Session sharedSession] getUserRelationshipsData];
        
    }
    else {
        //show
        [self makeViewAvailable];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // DC Desactive the Back text when comming from HomeScreen
    self.navigationItem.title = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

#pragma mark - Setup View Methods

- (void) makeViewAvailable {
    
    [self setupView];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.findABoatButton.alpha = 1.0;
                         self.createBoatDayButton.alpha = 1.0;
                         self.findPassengersButton.alpha = 1.0;
                         self.activityMonitor.alpha = 0.0;
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
}

- (void) setupView {
    
    self.findABoatButton.titleLabel.font = [UIFont abelFontWithSize:20.0];
    [self.findABoatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.findABoatButton setTitle:NSLocalizedString(@"home.findABoatButton.title", nil) forState:UIControlStateNormal];
    
    self.createBoatDayButton.titleLabel.font = [UIFont abelFontWithSize:20.0];
    [self.createBoatDayButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    
    if ([Session sharedSession].hostRegistration &&
        [[Session sharedSession].hostRegistration.status integerValue] == HostRegistrationStatusAccepted) {
        [self.createBoatDayButton setTitle:NSLocalizedString(@"home.createBoatDayButton.title", nil) forState:UIControlStateNormal];
    }
    else {
        [self.createBoatDayButton setTitle:NSLocalizedString(@"home.becomeAHost.title", nil) forState:UIControlStateNormal];
        
    }
    
    self.findPassengersButton.titleLabel.font = [UIFont abelFontWithSize:20.0];
    [self.findPassengersButton setTitleColor:[UIColor greenBoatDay] forState:UIControlStateNormal];
    
    if ([Session sharedSession].hostRegistration &&
        [[Session sharedSession].hostRegistration.status integerValue] == HostRegistrationStatusAccepted) {
        [self.findPassengersButton setTitle:NSLocalizedString(@"home.browseGuests.title", nil) forState:UIControlStateNormal];
    }
    else {
        [self.findPassengersButton setTitle:NSLocalizedString(@"home.browseUsers.title", nil) forState:UIControlStateNormal];
    }
    
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

#pragma mark - IBAction Methods

- (IBAction)findABoatButtonPressed:(id)sender {
    
    BDFindABoatDayViewController *viewController = [[BDFindABoatDayViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (IBAction)createBoatDayButtonPressed:(id)sender {
    
    if ([Session sharedSession].hostRegistration &&
        [[Session sharedSession].hostRegistration.status integerValue] == HostRegistrationStatusAccepted) {
        
        if (![Session sharedSession].hostRegistration.merchantId) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"myEvents.merchantIdAlertView.title", nil)
                                                                  message:NSLocalizedString(@"myEvents.merchantIdAlertView.message", nil)
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            return;
            
        }
        
        BDAddEditEventProfileViewController *viewController = [[BDAddEditEventProfileViewController alloc] init];
        UINavigationController *navViewController = [[MMNavigationController alloc] initWithRootViewController:viewController];
        
        [self.navigationController presentViewController:navViewController animated:YES completion:nil];
        
    } else {
        
        BDHostRegistrationViewController *viewController = [[BDHostRegistrationViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    
}

- (IBAction)findPassengersButtonPressed:(id)sender {
    
    BDFindUsersViewController *viewController = [[BDFindUsersViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

#pragma mark - Notification Methods

- (void) userLoggedInNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"userLoggedIn"]) {
        
        [self makeViewAvailable];
        
    }
    
    if ([[notification name] isEqualToString:@"loginFailed"]) {
        
        UIViewController *viewController = [[MMNavigationController alloc] initWithRootViewController:[[BDLoginViewController alloc] init]];
        [self.mm_drawerController setCenterViewController:viewController withCloseAnimation:YES completion:nil];
    }
    
}

#pragma mark - IBAction Methods

- (IBAction)sideMenuButtonPressed:(id)sender {
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}

@end
