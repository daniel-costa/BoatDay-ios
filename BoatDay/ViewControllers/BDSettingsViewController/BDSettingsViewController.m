//
//  BDSettingsViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 03/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDSettingsViewController.h"
#import "BDFindABoatFilterDefaultCell.h"
#import "MBSwitch.h"

#import "BDAboutViewController.h"
#import "BDTermsOfServiceViewController.h"
#import "BDPaymentInfoViewController.h"
#import "BDPaymentStatusViewController.h"
#import "BDLoginViewController.h"
typedef NS_ENUM(NSUInteger, SettingsRow) {
    
    SettingsRowAboutThisApp = 0,
    SettingsRowPaymentInfo = 1
    
};

@interface BDSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

@end

@implementation BDSettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"settings.title", nil);
    self.signOutButton.titleLabel.font = [UIFont abelFontWithSize:17.0];
    [self.signOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self setupTableView];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if ([User currentUser]) {
        [self.signOutButton setTitle:NSLocalizedString(@"sideMenu.signOutButton", nil) forState:UIControlStateNormal];
    }
    else {
        [self.signOutButton setTitle:NSLocalizedString(@"sideMenu.loginButton", nil) forState:UIControlStateNormal];
    }
}
#pragma mark - Setup Methods

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDFindABoatFilterDefaultCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDFindABoatFilterDefaultCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor whiteColor];
    
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

#pragma mark - UITableView Datasource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    
//    if ([Session sharedSession].hostRegistration && [User currentUser]) {
//        return 2;
//    }
//    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    SettingsRow row = indexPath.row;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    
    if (cell == nil) {
        
        cell = [[BDFindABoatFilterDefaultCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"defaultCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont abelFontWithSize:14.0];
        cell.textLabel.textColor = [UIColor grayBoatDay];
        
        cell.detailTextLabel.font = [UIFont abelFontWithSize:12.0];
        cell.detailTextLabel.textColor = [UIColor grayBoatDay];
        cell.detailTextLabel.numberOfLines = 0;
        
        
        // arrow as cell accessory view
        UIImage *arrowImage = [UIImage imageNamed:@"cell_arrow_grey"];
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        CGRect frame = CGRectMake(0.0, 0.0, arrowImage.size.width, arrowImage.size.height);
        arrowImageView.frame = frame;
        arrowImageView.image = arrowImage;
        arrowImageView.backgroundColor = [UIColor clearColor];
        cell.accessoryView = arrowImageView;
        
    }
    
    cell.detailTextLabel.text = @"";
    
    switch (row) {
        case SettingsRowAboutThisApp:
            cell.textLabel.text = NSLocalizedString(@"settings.aboutThisApp", nil);
            break;
        case SettingsRowPaymentInfo:
            cell.textLabel.text = NSLocalizedString(@"settings.paymentInfo", nil);
            break;
        default:
            break;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    
    SettingsRow row = indexPath.row;
    
    switch (row) {
        case SettingsRowAboutThisApp:
        {
            BDAboutViewController *aboutViewController = [[BDAboutViewController alloc] init];
            [self.navigationController pushViewController:aboutViewController animated:YES];
        }
            break;
        case SettingsRowPaymentInfo:
        {
            if ([Session sharedSession].hostRegistration.merchantId) {
                BDPaymentStatusViewController *paymentStatusView = [[BDPaymentStatusViewController alloc] init];
                [self.navigationController pushViewController:paymentStatusView animated:YES];
            }
            else {
                BDPaymentInfoViewController *paymentInfoViewController = [[BDPaymentInfoViewController alloc] init];
                [self.navigationController pushViewController:paymentInfoViewController animated:YES];
            }
        }
            break;

        default:
            break;
    }
    
}

- (IBAction)signOutAction:(id)sender {
    
    if ([User currentUser]) {
        
        [[Session sharedSession] logOutUser];
        
    }
    
    UINavigationController *centerViewController = (UINavigationController *)self.mm_drawerController.centerViewController;
    
    if ([[centerViewController.childViewControllers lastObject] isKindOfClass:[BDLoginViewController class]]) {
        
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        
    }
    else {
        
        UIViewController *viewController = [[MMNavigationController alloc] initWithRootViewController:[[BDLoginViewController alloc] init]];
        [self.mm_drawerController setCenterViewController:viewController withCloseAnimation:YES completion:nil];
        
    }
    
    [self.tableView reloadData];
}


@end
