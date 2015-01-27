//
//  BDLeftViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 19/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDLeftViewController.h"
#import "BDHomeViewController.h"
#import "BDProfileViewController.h"
#import "BDLoginViewController.h"
#import "BDMyBoatsViewController.h"
#import "BDFindABoatDayViewController.h"
#import "BDMyEventsViewController.h"
#import "BDNotificationsViewController.h"
#import "BDBoatTowingViewController.h"
#import "BDSettingsViewController.h"
#import "BDHostRegistrationViewController.h"
#import "BDAboutViewController.h"
#import "BDLeftMenuCell.h"
#import "BDLeftMenuFactTableViewCell.h"
#import "BDLeftMenuNotificationTableViewCell.h"
#import "BDLeftMenuProfileTableViewCell.h"
#import "BDDefaultTableViewCell.h"



#define SELECTED_COLOR RGB(36, 154, 175)

@interface BDLeftViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *footerViewsOfController;


@end

@implementation BDLeftViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupTableView];
    self.tracker = [[GAI sharedInstance] defaultTracker];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:36.0/255 green:154.0/255 blue:174.0/255 alpha:1.0]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.screenName = @"BDLeftViewController";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoggedInNotification:)
                                                 name:@"userLoggedIn"
                                               object:nil];
    
    [self.tableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
    
}

#pragma mark - Setup Methods

- (void) setupTableView {
    [self setupProfileHeader];
    // setup table view
    self.tableView.backgroundColor = [UIColor greenBoatDay];
    _footerViewsOfController.backgroundColor = [UIColor greenBoatDay];
    self.tableView.backgroundView.backgroundColor = [UIColor greenBoatDay];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = SELECTED_COLOR;
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.tableView.tableHeaderView = [self setupTableViewHeader];
}

- (void) setupProfileHeader {
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDLeftMenuProfileTableViewCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDLeftMenuProfileTableViewCell reuseIdentifier]];
    
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDLeftMenuNotificationTableViewCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDLeftMenuNotificationTableViewCell reuseIdentifier]];
    
    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDLeftMenuFactTableViewCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDLeftMenuFactTableViewCell reuseIdentifier]];

    storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDDefaultTableViewCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDDefaultTableViewCell reuseIdentifier]];
    
  
}

- (UIView *) setupTableViewHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];

   [header setBackgroundColor:[UIColor colorWithRed:36.0/255 green:154.0/255 blue:174.0/255 alpha:1.0]];

    CGFloat btnDimantion = 35.0;
    CGFloat btnY = (CGRectGetHeight(header.frame) - btnDimantion)/2;
    CGFloat btnXOffSet = (CGRectGetWidth(self.tableView.frame)/4 - btnDimantion)/2;
    UIButton *btnNotification = [[UIButton alloc] initWithFrame:CGRectMake(btnXOffSet, btnY, btnDimantion,btnDimantion)];
    [btnNotification addTarget:self action:@selector(btnNotificationPressed) forControlEvents:UIControlEventTouchDown];
    [btnNotification setImage:[UIImage imageNamed:@"sidemenu_settings"] forState:UIControlStateNormal];
    
    UIButton *btnSetting = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.tableView.frame)/4 + btnXOffSet, btnY, btnDimantion,btnDimantion)];
    [btnSetting addTarget:self action:@selector(btnSettingPressed) forControlEvents:UIControlEventTouchDown];    [btnSetting setImage:[UIImage imageNamed:@"sidemenu_settings"] forState:UIControlStateNormal];
    
    UIButton *btnEmergency = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.tableView.frame)/2 + btnXOffSet, btnY, btnDimantion,btnDimantion)];
    [btnEmergency addTarget:self action:@selector(btnEmergencyPressed) forControlEvents:UIControlEventTouchDown];    [btnEmergency setImage:[UIImage imageNamed:@"sidemenu_settings"] forState:UIControlStateNormal];
    
    UIButton *btnAboutUs = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.tableView.frame) * 0.75 + btnXOffSet, btnY, btnDimantion,btnDimantion)];
    [btnAboutUs addTarget:self action:@selector(btnAboutUsPressed) forControlEvents:UIControlEventTouchDown];
    [btnAboutUs setImage:[UIImage imageNamed:@"sidemenu_settings"] forState:UIControlStateNormal];
    
    [header addSubview:btnNotification];
    [header addSubview:btnSetting];
    [header addSubview:btnEmergency];
    [header addSubview:btnAboutUs];
    
    return header;
}

#pragma mark - UITableView Datasource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideMenu sideMenu = [BDLeftViewController convertSideMenuIndex:indexPath.row];

    switch (sideMenu) {
        case SideMenuProfileHeader:
            return 60.0;
            break;
        case SideMenuNotificationBar:
            return 24.0;
            break;
        case SidemenuFactBar:
            return 160.0;
            break;
        default:
            break;
    }

    return 50.0;
}


//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 88.0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//
//    UIView *headerSection = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 88)];
//    headerSection.backgroundColor = [UIColor greenBoatDay];
//    return headerSection;
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [BDLeftViewController sideMenuNumberOfRows];
    
}

- (UITableViewCell *)profileHeaderCell:(UITableView *)tableView{
    BDLeftMenuProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[BDLeftMenuProfileTableViewCell reuseIdentifier]];
    User *user = [User currentUser];
    
    
    if(user.pictures.count > 0 && [user.selectedPictureIndex integerValue] >= 0) {
        PFFile *theImage = user.pictures[[user.selectedPictureIndex integerValue]];
        
        // Get image from cache or from server if isnt available (background task)
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            [cell updateProfileCellWith:image profileName:[user fullName]];
        }];
    } else {
        [cell updateProfileCellWith:nil profileName:[user fullName]];
    }

    

    return cell;
}

- (UITableViewCell *)notificationBarHeaderCell:(UITableView *)tableView{
    BDLeftMenuNotificationTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:[BDLeftMenuNotificationTableViewCell reuseIdentifier]];

    
    return cell;
}

- (UITableViewCell *)factHeaderCell:(UITableView *)tableView{
    BDLeftMenuFactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[BDLeftMenuFactTableViewCell reuseIdentifier]];
    
    return cell;
}

- (UITableViewCell *)returnDefaultCell:(UITableView *)tableView name:(NSString *)name image:(NSString *)image{
    BDDefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[BDDefaultTableViewCell reuseIdentifier]];
    [cell updateCellWith:name imageName:image];
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideMenu sideMenu = [BDLeftViewController convertSideMenuIndex:indexPath.row];
    static NSString *cellIdentifier = @"Cell";

    BDLeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[BDLeftMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont abelFontWithSize:17.0];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.frame = CGRectMake(54, 3, 202, 42);
    cell.accessoryView.frame = CGRectMake(4, 3, 42, 42);

    switch (sideMenu) {
        case SideMenuProfileHeader:
            return [self profileHeaderCell:tableView];
            break;
        case SideMenuNotificationBar:
            return [self notificationBarHeaderCell:tableView];

            break;
        case SidemenuFactBar:
            return [self factHeaderCell:tableView];

            break;
        case SideMenuHome:
            return [self returnDefaultCell:tableView name:NSLocalizedString(@"sideMenu.home", nil) image:@"home_boatday_logo"];
            
            break;
        case SideMenuFindABoatDay:
            cell.textLabel.text = NSLocalizedString(@"sideMenu.findABoatDay", nil);
            
            break;
        case SideMenuMyEvents:
            return [self returnDefaultCell:tableView name:NSLocalizedString(@"sideMenu.myEvents", nil) image:@"ico-Events"];
            break;
        
        case SideMenuHostRegistration:

            return [self returnDefaultCell:tableView name:NSLocalizedString(@"sideMenu.hostRegistration", nil) image:@"ico-Host-center"];
            break;
        case SideMenuMyBoats:

            return [self returnDefaultCell:tableView name:NSLocalizedString(@"sideMenu.myBoats", nil) image:@"ico-Host-center"];
            break;
    
        default:
            break;
    }
    
    if ([Session sharedSession].selectedSideMenu == sideMenu) {
        [self setCellColor:SELECTED_COLOR forCell:cell];
    } else {
        [self setCellColor:[UIColor clearColor] forCell:cell];
    }

    if ([User currentUser] && [Session sharedSession].dataWasFechted) {
        [cell.textLabel setTextColor:[UIColor whiteColor]];

    } else if(indexPath.row != 0){
        [cell.textLabel setTextColor:[UIColor grayBoatDay]];
        
    }
    
    return cell;
}


- (void)setCellColor:(UIColor *)color forCell:(UITableViewCell *)cell {
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([User currentUser] && [Session sharedSession].dataWasFechted) {
       
        SideMenu pressedSideMenu = [BDLeftViewController convertSideMenuIndex:indexPath.row];
        
        [self openViewController:pressedSideMenu];
        
        [self.tableView reloadData];

    }
    
}

- (void) openViewController:(SideMenu)pressedSideMenu {
    

    [Session sharedSession].selectedSideMenu = pressedSideMenu;
    
    UIViewController *centerViewController;
    
    switch (pressedSideMenu) {
        case SideMenuHome:
        {
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SideMenuHome"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            [self openHomeView];
            return;
        }
            break;
        case SideMenuFindABoatDay:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SideMenuFindABoatDay"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            centerViewController = [[BDFindABoatDayViewController alloc] init];
            break;
        case SideMenuProfileHeader:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SideMenuProfileHeader"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            centerViewController = [[BDProfileViewController alloc] initWithUser:[User currentUser] andProfileType:ProfileTypeSelf];
            break;
        case SideMenuMyEvents:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SideMenuMyEvents"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            centerViewController = [[BDMyEventsViewController alloc] init];
            break;
        case SideMenuNotificationBar:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SideMenuNotificationBar"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            centerViewController = [[BDNotificationsViewController alloc] init];
            break;
        case SideMenuHostRegistration:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SideMenuHostRegistration"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            centerViewController = [[BDHostRegistrationViewController alloc] init];
            break;
        case SideMenuMyBoats:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SideMenuMyBoats"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            centerViewController = [[BDMyBoatsViewController alloc] init];
            break;
        case SideMenuEmergencyBoatTowing:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SideMenuEmergencyBoatTowing"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            centerViewController = [[BDBoatTowingViewController alloc] init];
            break;
        case SideMenuSettings:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SideMenuSettings"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            centerViewController = [[BDSettingsViewController alloc] init];
            break;
        case SideMenuAboutUs:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SideMenuAboutUs"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            centerViewController =  [[BDAboutViewController alloc] init];
            break;
        case SidemenuFactBar:
            [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                                       action:@"SidemenuFactBar"
                                                                        label:@"BDLeftViewController"
                                                                        value:nil] build]];
            return;
            break;
        default:
            break;
    }
    
    UINavigationController * navigationController = [[MMNavigationController alloc] initWithRootViewController:centerViewController];
    [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
    
}


#pragma mark - Methods

- (void) openHomeView {
    
    UINavigationController *centerViewController = (UINavigationController *)self.mm_drawerController.centerViewController;
    
    if ([User currentUser]) {
        
        if ([[centerViewController.childViewControllers lastObject] isKindOfClass:[BDHomeViewController class]]) {
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
            
        } else {
            BDHomeViewController *homeViewController = [[BDHomeViewController alloc] init];
            UIViewController *viewController = [[MMNavigationController alloc] initWithRootViewController:homeViewController];
            
            [self.mm_drawerController setCenterViewController:viewController withCloseAnimation:YES completion:nil];
        }
        
    }
    else {
        
        if ([[centerViewController.childViewControllers lastObject] isKindOfClass:[BDLoginViewController class]]) {
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        } else {
            BDLoginViewController *loginViewController = [[BDLoginViewController alloc] init];
            UIViewController *viewController = [[MMNavigationController alloc] initWithRootViewController:loginViewController];
            
            [self.mm_drawerController setCenterViewController:viewController withCloseAnimation:YES completion:nil];
        }
        
    }
    
}

- (void) btnNotificationPressed{
    [self openViewController:SideMenuNotifications];
}

- (void) btnSettingPressed{
    [self openViewController:SideMenuSettings];

}

- (void) btnEmergencyPressed{
    [self openViewController:SideMenuEmergencyBoatTowing];

}

- (void) btnAboutUsPressed{
    [self openViewController:SideMenuAboutUs];
}

- (IBAction)settingButtonPressed:(id)sender {
    
    [self openViewController:SideMenuSettings];

}
- (IBAction)emergencyButtonPressed:(id)sender {
    [self openViewController:SideMenuEmergencyBoatTowing];

}
- (IBAction)aboutUsButtonPressed:(id)sender {
    [self openViewController:SideMenuAboutUs];

}

#pragma mark - Notification Methods

- (void) userLoggedInNotification:(NSNotification *) notification {
    
    if ([[notification name] isEqualToString:@"userLoggedIn"]) {
        
        [UIView hideViewAnimated:self.tableView withAlpha:YES andDuration:0.2];
        
        UIActivityIndicatorView * activityindicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(50, 50, 30, 30)];
        [activityindicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityindicator setColor:[UIColor whiteColor]];
        [self.view addSubview:activityindicator];
        
        activityindicator.center = self.view.center;
        setFrameY(activityindicator, activityindicator.frame.origin.y - 100.0);
        
        [activityindicator startAnimating];
        
        [self performSelector:@selector(stopActivity:) withObject:activityindicator afterDelay:1.0];
        
    }
    
}

- (void)stopActivity:(UIActivityIndicatorView*)activity {
    
    [activity removeFromSuperview];
    
    [self.tableView reloadData];
    
    [UIView showViewAnimated:self.tableView withAlpha:YES andDuration:0.2];
    
}

#pragma mark - Convert Arrays

+ (NSArray *) getCurrentConvertArray {
    
    NSArray *convertArray;
    
    if ([User currentUser] && [Session sharedSession].dataWasFechted) {
        
        if ([Session sharedSession].hostRegistration) {
            
            if ([[Session sharedSession].hostRegistration.status intValue] == HostRegistrationStatusAccepted) {
                
                convertArray = [BDLeftViewController hostRegistrationAccepted];
            }
            else {
                
                // last step of registration, otherwise it should be with HostRegistrationStatusPending
                if ([[Session sharedSession].hostRegistration.merchantStatus isEqualToString:@"active"]) {
                    
                    convertArray = [BDLeftViewController hostRegistrationPending];
                    
                }
                else {
                    
                    convertArray = [BDLeftViewController hostRegistrationNormal];
                    
                }
                
            }
            
        }
        else {
            
            convertArray = [BDLeftViewController hostRegistrationNormal];
            
        }
    }
    else {
        
        convertArray = [BDLeftViewController loggedOutArray];
        
    }
    
    return convertArray;
    
}

+ (SideMenu) convertSideMenuIndex:(NSInteger)index {
    
    NSArray *convertArray = [BDLeftViewController getCurrentConvertArray];
    
    return [convertArray[index] integerValue];
    
}

+ (NSInteger) sideMenuNumberOfRows {
    
    NSArray *convertArray = [BDLeftViewController getCurrentConvertArray];
    
    return convertArray.count;
    
}

+ (NSArray *)hostRegistrationAccepted {
    
    static NSArray *_convertArray;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _convertArray = @[@(SideMenuProfileHeader),
                          @(SideMenuNotificationBar),
                          @(SidemenuFactBar),
                          @(SideMenuHome),
                          @(SideMenuMyEvents),
                          @(SideMenuMyBoats)];
    });
    
    return _convertArray;
    
}

+ (NSArray *)hostRegistrationPending {
    
    static NSArray *_convertArray;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _convertArray = @[@(SideMenuProfileHeader),
                          @(SideMenuNotificationBar),
                          @(SidemenuFactBar),
                          @(SideMenuHome),
                          @(SideMenuMyEvents),
                          @(SideMenuMyBoats)];
    });
    
    return _convertArray;
    
}

+ (NSArray *)hostRegistrationNormal {
    
    static NSArray *_convertArray;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _convertArray = @[@(SideMenuProfileHeader),
                          @(SideMenuNotificationBar),
                          @(SidemenuFactBar),
                          @(SideMenuHome),
                          @(SideMenuMyEvents),
                          @(SideMenuHostRegistration)];
    });
    
    return _convertArray;
    
}

+ (NSArray *)loggedOutArray {
    
    static NSArray *_convertArray;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _convertArray =  @[];
    });
    
    return _convertArray;
    
}

@end
