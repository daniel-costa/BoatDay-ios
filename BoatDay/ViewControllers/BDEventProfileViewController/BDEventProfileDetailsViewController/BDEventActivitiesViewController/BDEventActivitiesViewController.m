//
//  BDEventActivitiesViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 12/08/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEventActivitiesViewController.h"
#import "BDEventActivitiesCell.h"

#define numberOfPermissions 3

@interface BDEventActivitiesViewController ()

// View
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Data
@property (nonatomic, strong) Event *event;

@end

@implementation BDEventActivitiesViewController

- (instancetype)initWithEvent:(Event *)event {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _event = event;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.screenName =@"BDEventActivitiesViewController";

    self.title = NSLocalizedString(@"eventProfile.activities.title", nil);
    
    [self setupTableView];
    
}

#pragma mark - Setup Methods

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDEventActivitiesCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDEventActivitiesCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.delaysContentTouches = YES;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath {
    
    BDEventActivitiesCell *cell = (BDEventActivitiesCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    CGFloat height = CGRectGetMaxY(cell.activityDescriptionLabel.frame);
    CGFloat bottomSpace = 10.0;
    
    return height + bottomSpace;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.event.activities.count + numberOfPermissions;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDEventActivitiesCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDEventActivitiesCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case EventPermissionsNoDrinking:
        {
            BOOL hasPermission = [self.event.alcoholPermitted boolValue];
            
            if (hasPermission) {
                [cell updateCellWithTitle:NSLocalizedString(@"eventProfile.activities.yesDrinking.title", nil)
                         descriptionTitle:NSLocalizedString(@"eventProfile.activities.yesDrinking.description", nil)
                                    image:[UIImage imageNamed:@"activity_parental_drinking_yes"]
                            hasPermission:hasPermission];
            }
            else {
                [cell updateCellWithTitle:NSLocalizedString(@"eventProfile.activities.noDrinking.title", nil)
                         descriptionTitle:NSLocalizedString(@"eventProfile.activities.noDrinking.description", nil)
                                    image:[UIImage imageNamed:@"activity_parental_drinking_no"]
                            hasPermission:hasPermission];
            }
            
        }
            break;
        case EventPermissionsNoSmoking:
        {
            BOOL hasPermission = [self.event.smokingPermitted boolValue];
            
            if (hasPermission) {
                [cell updateCellWithTitle:NSLocalizedString(@"eventProfile.activities.yesSmoking.title", nil)
                         descriptionTitle:NSLocalizedString(@"eventProfile.activities.yesSmoking.description", nil)
                                    image:[UIImage imageNamed:@"activity_parental_smoking_yes"]
                            hasPermission:hasPermission];
            }
            else {
                [cell updateCellWithTitle:NSLocalizedString(@"eventProfile.activities.noSmoking.title", nil)
                         descriptionTitle:NSLocalizedString(@"eventProfile.activities.noSmoking.description", nil)
                                    image:[UIImage imageNamed:@"activity_parental_smoking_no"]
                            hasPermission:hasPermission];
            }
        }
            break;
        case EventPermissionsFamiliesWelcome:
        {
            BOOL hasPermission = [self.event.childrenPermitted boolValue];
            
            if (hasPermission) {
                [cell updateCellWithTitle:NSLocalizedString(@"eventProfile.activities.familyWelcome.title", nil)
                         descriptionTitle:NSLocalizedString(@"eventProfile.activities.familyWelcome.description", nil)
                                    image:[UIImage imageNamed:@"activity_parental_children_yes"]
                            hasPermission:hasPermission];
            }
            else {
                [cell updateCellWithTitle:NSLocalizedString(@"eventProfile.activities.nofamilyWelcome.title", nil)
                         descriptionTitle:NSLocalizedString(@"eventProfile.activities.nofamilyWelcome.description", nil)
                                    image:[UIImage imageNamed:@"activity_parental_children_no"]
                            hasPermission:hasPermission];
            }
        }
            break;
        default:
        {
            Activity *activity = self.event.activities[indexPath.row - numberOfPermissions];
            [cell updateCellWithActivity:activity];
        }
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
    
}

@end
