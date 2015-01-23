//
//  BDSelectBoatViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 22/7/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDSelectBoatViewController.h"
#import "BDBoatListCell.h"
#import "BDBoatViewController.h"
#import "BDAddEditBoatViewController.h"

#define SUBMITED_BOATS_TABLEVIEW_SECTION 0

@interface BDSelectBoatViewController ()

@property (strong, nonatomic) User *user;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *noBoatsView;

@property (weak, nonatomic) IBOutlet UILabel *noBoatsViewLabel;

@property (strong, nonatomic) NSMutableArray *boats;

@end

@implementation BDSelectBoatViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.user = [User currentUser];
    
    [self setupView];
    
    // setup view
    [self setupTableView];
    
    // Get boats information
    [self getData];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // setup navigation bar buttons
    [self setupNavigationBar];
    
    [self.tableView reloadData];
    
    self.title = NSLocalizedString(@"selectBoats.title", nil);
    
}

#pragma mark - Setup View Methods

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

- (void) setupView {
    
    self.noBoatsViewLabel.text = NSLocalizedString(@"myBoats.noBoatsView.message", nil);
    self.noBoatsViewLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.noBoatsViewLabel.textColor = [UIColor greenBoatDay];
    
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
                
                for (Boat *boat in boats) {
                    if ([boat.status intValue] == BoatStatusApproved) {
                        [self.boats addObject:boat];
                    }
                }
                
                [self.tableView reloadData];
                
            } else {
                
                [self.contentView addSubview:self.noBoatsView];
                
            }
            
        } else {
            
            [self addNoConnectionView];
            
        }
        
    }];
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1.0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.boats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDBoatListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDBoatListCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Boat *boat = self.boats[indexPath.row];
    
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
    
    if (self.boatSelectedBlock) {
        Boat *boat = self.boats[indexPath.row];
        self.boatSelectedBlock(boat);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - IBAction Methods

-(void) addButtonPressed:(id)sender {
    
    BDAddEditBoatViewController *editUBoatViewController = [[BDAddEditBoatViewController alloc] init];
    
    UINavigationController *navigationController = [[MMNavigationController alloc] initWithRootViewController:editUBoatViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

@end
