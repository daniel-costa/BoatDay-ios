//
//  BDAppDelegate.m
//  BoatDay
//
//  Created by Diogo Nunes on 19/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDAppDelegate.h"

#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"

#import "BDHomeViewController.h"
#import "BDLeftViewController.h"
#import "BDLoginViewController.h"
#import <Crashlytics/Crashlytics.h>
#import <AVFoundation/AVFoundation.h>
#import "GAI.h"
#import "BoatdayNotificationMessage.h"
#import "BoatdayNotificationMessageView.h"
@interface BDAppDelegate ()

@property (nonatomic,strong) MMDrawerController * drawerController;

@end

@implementation BDAppDelegate
- (void)launch {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Crashlytics
        [Crashlytics startWithAPIKey:@"92ac8ecdcc1700f12f2f856b7facbb06db49b649"];
        
        // Google Analytics
        // Optional: automatically send uncaught exceptions to Google Analytics.
        [GAI sharedInstance].trackUncaughtExceptions = YES;
        
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
        [GAI sharedInstance].dispatchInterval = 20;
        
        // Optional: set Logger to VERBOSE for debug information.
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
        
        // Initialize tracker. Replace with your tracking ID.
        [[GAI sharedInstance] trackerWithTrackingId:@"UA-51849119-2"];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
        
        [self registParseSubclasses];
        
        [Parse setApplicationId:@"n847Wlp5wbJxzU5sakhXd6ojpReDGDRKy5HhhmWN" clientKey:@"sYfLmXqCjf2DvH6LZZ3mobT8Jl9YDyxYv9q3bwvO"];
        
        [PFFacebookUtils initializeFacebook];
        
#warning Log To File (uncomment)
        //  [self logToFile];
        
        // Customize status bar
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        // Customize navigation bar
        [self customizeNavigationBar];
        
        [self appearenceCustumizations];
        
        // MMDrawerController for Left/Right Menu
        
        BDLeftViewController *leftSideDrawerViewController = [[BDLeftViewController alloc] init];
        
        UIViewController *centerViewController;
        
        if ([User currentUser]) {
            BDHomeViewController *viewController = [[BDHomeViewController alloc] init];
            centerViewController = [[MMNavigationController alloc] initWithRootViewController:viewController];
            [Session sharedSession].selectedSideMenu = SideMenuHome;
        } else {
            centerViewController = [[MMNavigationController alloc] initWithRootViewController:[[BDLoginViewController alloc] init]];
        }
        
        // Creating Drawer
        self.drawerController = [[MMDrawerController alloc]
                                 initWithCenterViewController:centerViewController
                                 leftDrawerViewController:leftSideDrawerViewController];
        
        // Show shadow beetween side view and center view
        [self.drawerController setShowsShadow:NO];
        
        // Visible Size of Left View
        [self.drawerController setMaximumLeftDrawerWidth:272.0];
        [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
        [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
        
        // Drawer Manager to open and close with animation. Using Default: MMDrawerAnimationTypeParallax
        [self.drawerController
         setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
             MMDrawerControllerDrawerVisualStateBlock block;
             block = [[MMExampleDrawerVisualStateManager sharedManager]
                      drawerVisualStateBlockForDrawerSide:drawerSide];
             if(block){
                 block(drawerController, drawerSide, percentVisible);
             }
         }];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        // Set window background color
        UIColor * tintColor = [UIColor colorWithRed:29.0/255.0
                                              green:173.0/255.0
                                               blue:234.0/255.0
                                              alpha:1.0];
        [self.window setTintColor:tintColor];
        
        [self.window setRootViewController:self.drawerController];
        
        [self.window makeKeyAndVisible];

    });
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Singlaton Launch
    [self launch];
    
    
    return YES;
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];

    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    [[Session sharedSession] updateUserData];
    
}

#pragma mark - Instalation For Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [[PFInstallation currentInstallation] saveInBackground];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NotificationType notificationType = [userInfo[@"notificationType"] integerValue];
    
    switch (notificationType) {
        case NotificationTypeBoatApproved:
            [[Session sharedSession] updateUserData];
            break;
        case NotificationTypeBoatRejected:
            [[Session sharedSession] updateUserData];
            break;
        case NotificationTypeSeatRequest:
            break;
        case NotificationTypeRequestApproved:
            
            break;
        case NotificationTypeRequestRejected:
            break;
        case NotificationTypeUserCertificationApproved:
            break;
        case NotificationTypeUserCertificationRejected:
            break;
        case NotificationTypeNewChatMessage:
            break;
        case NotificationTypeNewEventInvitation:
            break;
        case NotificationTypeRemovedFromAnEvent:
            break;
        case NotificationTypeEventRemoved:
            break;
        case NotificationTypeNewReview:
            break;
        case NotificationTypeHostRegistrationApproved:
            
            [[Session sharedSession] updateUserData];
            
            break;
        case NotificationTypeHostRegistrationRejected:
            break;
        case NotificationTypeSeatRequestCanceledByUser:
            break;
        case NotificationTypePaymentReminder:
            break;
        case NotificationTypeMerchantApproved:
            
            [[Session sharedSession] updateUserData];
            
            break;
        case NotificationTypeMerchantDeclined:
            break;
        case NotificationTypeEventEnded:
            break;
        case NotificationTypeEventWillStartIn48H:
            break;
        case NotificationTypeEventInvitationRemoved:
            break;
        case NotificationTypeFinalizeContribution:
            break;
        default:
            [[Session sharedSession] updateUserData];
            break;
    }
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    if (appState == UIApplicationStateActive) {
        NSLog(@"active %@",userInfo);

        [BoatdayNotificationMessage showNotificationMessage:@"New Notification" subTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] iconImage:@"logo" viewController:self.window.rootViewController callback:^(void){
            
        } typeOfMessage:BoatdayNotificationMessageTypeError];
    } else {
        NSLog(@"handlePush %@",userInfo);

        [PFPush handlePush:userInfo];
    }
}

#pragma mark - Log To File Methods

- (void) logToFile {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *fileName =[NSString stringWithFormat:@"%@.log",[NSDate date]];
    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    
}

#pragma mark - Navigation Bar

- (void)customizeNavigationBar {
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_background"]
                                       forBarMetrics:UIBarMetricsDefault];
    
     [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
     NSFontAttributeName:[UIFont abelFontWithSize:25.0f]}];
     
     [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:2.0f forBarMetrics:UIBarMetricsDefault];
     
     
     [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                                            NSFontAttributeName:[UIFont abelFontWithSize:16.0],
                                                            NSKernAttributeName:@(-0.6f)
                                                            }
                                                 forState:UIControlStateNormal];

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

}

#pragma mark - App Customs

- (void) appearenceCustumizations {
    //
    //    [[SVProgressHUD appearance] setHudBackgroundColor:[[UIColor greenBoatDay] colorWithAlphaComponent:0.4]];
    //    [[SVProgressHUD appearance] setHudForegroundColor:[UIColor whiteColor]];
    //    [[SVProgressHUD appearance] setHudFont:[UIFont abelFontWithSize:15.0]];
    //    [[SVProgressHUD appearance] setHudStatusShadowColor:[UIColor whiteColor]];
    //  
    // [[UITextField appearance] setTintColor:[UIColor mediumGreenBoatDay]];
    
}

- (void) registParseSubclasses {

    [User registerSubclass];
    [ActivityType registerSubclass];
    [Activity registerSubclass];
    [Certification registerSubclass];
    [Review registerSubclass];
    [Event registerSubclass];
    [Boat registerSubclass];
    [Report registerSubclass];
    [Invite registerSubclass];
    [SafetyFeature registerSubclass];
    [CertificationType registerSubclass];
    [Notification registerSubclass];
    [SeatRequest registerSubclass];
    [ChatMessage registerSubclass];
    [AdminMessage registerSubclass];
    [HostRegistration registerSubclass];
    
}

@end
