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
    
    self.user = [User currentUser];
    
    [self setupView];

    // setup navigation bar buttons
    [self setupNavigationBar];
    
    // setup view
    [self setupTableView];
    
    // Get boats information
    [self getData];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
 
    [self.tableView reloadData];
    
}

#pragma mark - Setup View Methods

- (void) setupView {
    
    self.noBoatsViewLabel.text = NSLocalizedString(@"myBoats.noBoatsView.message", nil);
    self.noBoatsViewLabel.font = [UIFont quattoCentoRegularFontWithSize:13.0];
    self.noBoatsViewLabel.textColor = [UIColor greenBoatDay];
    
}

- (void) setupNavigationBar {
    
    self.title = NSLocalizedString(@"myBoats.title", nil);
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(0, 0, 25, 25);
    [addButton setImage:[UIImage imageNamed:@"nav_add"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
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
    [query whereKey:@"owner" equalTo:self.user];
    
    [query includeKey:@"safetyFeatures"];
    [query includeKey:@"rejectionMessage"];
    [query orderByAscending:@"name"];
    
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
    if (section == 0)
        return 0.0f;
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

    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return (self.boats.count > 0) + (self.notSubmitedBoats.count > 0);
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.boats.count && section == SUBMITED_BOATS_TABLEVIEW_SECTION) {
        return self.boats.count;

    }

    return self.notSubmitedBoats.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BDBoatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDBoatListCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    Boat *boat = indexPath.section == SUBMITED_BOATS_TABLEVIEW_SECTION ? self.boats[indexPath.row] : self.notSubmitedBoats[indexPath.row];

    [cell updateLayoutWithBoat:boat];
    
    return cell;
    
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Boat *boat = indexPath.section == SUBMITED_BOATS_TABLEVIEW_SECTION ? self.boats[indexPath.row] : self.notSubmitedBoats[indexPath.row];
    
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
