//
//  BDMyBoatsViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 22/7/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDMyBoatsViewController.h"
#import "BDBoatListCell.h"
#import "BDBoatViewController.h"
#import "BDAddEditBoatViewController.h"

#define SUBMITED_BOATS_TABLEVIEW_SECTION 0

@interface BDMyBoatsViewController ()

@property (strong, nonatomic) User *user;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *noBoatsView;

@property (weak, nonatomic) IBOutlet UILabel *noBoatsViewLabel;

@property (strong, nonatomic) NSMutableArray *boats;
@property (strong, nonatomic) NSMutableArray *notSubmitedBoats;

@end

@implementation BDMyBoatsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"myBoats.title", nil);
    
    self.user = [User currentUser];
    
    [self setupView];
    
    // setup view
    [self setupTableView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // setup navigation bar buttons
    [self setupNavigationBar];
    
    // Get boats information
    [self getData];
    
    [self.tableView reloadData];
    
    [UIView showViewAnimated:self.tableView withAlpha:YES andDuration:0.5];

}

#pragma mark - Setup View Methods

- (void) setupView {
    
    self.noBoatsViewLabel.text = NSLocalizedString(@"myBoats.noBoatsView.message", nil);
    self.noBoatsViewLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.noBoatsViewLabel.textColor = [UIColor greenBoatDay];
    
}

- (void) setupNavigationBar {
    
    
    if ([User currentUser]) {
        
        UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.frame = CGRectMake(0, 0, 25, 25);
        [addButton setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
        self.navigationItem.rightBarButtonItem = addButtonItem;
        
    }
    
}

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDBoatListCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDBoatListCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}

#pragma mark - Get Data Information Methods

- (void) getData {
    
    [self addActivityViewforView:self.contentView];
    
    PFQuery *query = [Boat query];
    [query includeKey:@"safetyFeatures"];
    [query includeKey:@"rejectionMessage"];
    
    [query orderByAscending:@"name"];
    
    [query whereKey:@"owner" equalTo:self.user];
    [query whereKey:@"deleted" notEqualTo:@(YES)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *boats, NSError *error) {
        
        [self removeActivityViewFromView:self.contentView];
        
        if (!error) {
            
            if(boats.count) {
                
                self.boats = [[NSMutableArray alloc] init];
                self.notSubmitedBoats = [[NSMutableArray alloc] init];
                
                for (Boat *boat in boats) {
                    if ([boat.status intValue] == BoatStatusNotSubmited) {
                        [self.notSubmitedBoats addObject:boat];
                    }
                    else {
                        [self.boats addObject:boat];
                    }
                }
                
                [self.tableView reloadData];
                
            }
            else {
                [self.contentView addSubview:self.noBoatsView];
            }
        }
        else {
            [self addNoConnectionView];
        }
        
    }];
    
}


#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80.0;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 22.0)];
        [view setBackgroundColor:[UIColor greenBoatDay]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
        label.font = [UIFont abelFontWithSize:12.0];
        label.text = [NSLocalizedString(@"myBoats.tableView.section.notApproved", nil) uppercaseString];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        return view;
        
    }
    else {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 22.0)];
        [view setBackgroundColor:[UIColor yellowBoatDay]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
        label.font = [UIFont abelFontWithSize:12.0];
        label.text = [NSLocalizedString(@"myBoats.tableView.section.submited", nil) uppercaseString];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        return view;
        
    }
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return self.boats.count;
            break;
        case 1:
            return self.notSubmitedBoats.count;
            break;
        default:
            break;
    }
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDBoatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDBoatListCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Boat *boat = self.boats.count && indexPath.section == SUBMITED_BOATS_TABLEVIEW_SECTION ? self.boats[indexPath.row] : self.notSubmitedBoats[indexPath.row];
    if (indexPath.section == 1) {
        cell.statusImage.hidden = YES;
    }
    
     cell.statusImage.hidden = (indexPath.section == 1) ? YES : NO;
    [cell updateLayoutWithBoat:boat];
    
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
    
    Boat *boat = self.boats.count && indexPath.section == SUBMITED_BOATS_TABLEVIEW_SECTION ? self.boats[indexPath.row] : self.notSubmitedBoats[indexPath.row];
    
    BDBoatViewController *boatViewController = [[BDBoatViewController alloc] initWithBoat:boat];
    [self.navigationController pushViewController:boatViewController animated:YES];
    
}

#pragma mark - IBAction Methods

-(void) addButtonPressed:(id)sender {
    
    BDAddEditBoatViewController *editUBoatViewController = [[BDAddEditBoatViewController alloc] init];
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:editUBoatViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

@end
