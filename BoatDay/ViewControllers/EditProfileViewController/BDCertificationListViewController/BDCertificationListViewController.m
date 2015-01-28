//
//  BDCertificationListViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 25/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDCertificationListViewController.h"
#import "BDCertificationListCell.h"
#import "BDCertificationDetailViewController.h"
#import <objc/runtime.h>

static char associatedKey;

@interface BDCertificationListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BDCertificationListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.screenName =@"BDCertificationListViewController";

    self.title = NSLocalizedString(@"certificationsList.title", nil);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // setup view
    [self setupTableView];
    
    if (![Session sharedSession].certificationTypes) {
        
        // Add a loading view while we fetch the data
        [self addActivityViewforView:self.contentView];
        
        [self getData];
    }
    else {
        // Must reload table view to show all the fetched data
        [self.tableView reloadData];
    }
    
}

#pragma mark - Setup Methods

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDCertificationListCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDCertificationListCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor whiteColor];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}


#pragma mark - Get Data Methods

- (void) getData {
    
    // Get all types of Certifications
    [self getCertificationTypes];
    
}

- (void) getCertificationTypes {
    
    PFQuery *query = [CertificationType query];
    [query orderByAscending:@"order"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *certifications, NSError *error) {
        
        if (!error) {
            
            // store objects in session
            [Session sharedSession].certificationTypes = certifications;
            
            // Must reload table view to show all the fetched data
            [self.tableView reloadData];
            
            // We got all the data, we can remove the loading view
            [self removeActivityViewFromView:self.contentView];
            
        } else {
            
            // If something is wrong (99% is no connection), shows a warning
            [self addNoConnectionView];
            
        }
        
    }];
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60.0;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [Session sharedSession].certificationTypes.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDCertificationListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDCertificationListCell reuseIdentifier]];
    
    CertificationType *type = [Session sharedSession].certificationTypes[indexPath.row];
    
    cell.titleLabel.text = type.name;
    cell.status = CertificationStatusNone;
    
    //remove previous associated objects to the cell
    objc_removeAssociatedObjects(cell);
    
    // for all the user certifications, check is if there is one with the same type as this one
    for (Certification *certification in [Session sharedSession].myCertifications) {
        
        if ([certification.type.objectId isEqualToString:type.objectId]) {
            
            //k if is approved. If not, its a pending request
            cell.status = [certification.status integerValue];
            
            //associate certification to the cell
            objc_setAssociatedObject(cell, &associatedKey, certification, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
    }
    
    if (indexPath.row == 0) {
        cell.deepDescription.hidden = NO;
        [cell.deepDescription setText:NSLocalizedString(@"certificationsList.boatSafteyEduCou", nil)];
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
    
    // get the cell so we can get the associated certification, if there is one.
    BDCertificationListCell *cell = (BDCertificationListCell* )[tableView cellForRowAtIndexPath:indexPath];
    
    // get the type
    CertificationType *type = [Session sharedSession].certificationTypes[indexPath.row];
    
    // get certification from cell (associated object)
    Certification *certification = objc_getAssociatedObject(cell, &associatedKey);
    
    // init view controller (certification can be nil)
    BDCertificationDetailViewController *certificationDetail = [[BDCertificationDetailViewController alloc] initCertification:certification andCertificatonType:type];
    
    [self.navigationController pushViewController:certificationDetail animated:YES];
    
}

#pragma mark - NoConnectionView Delegate Methods

// If user taps or try to reload the No Connection View (maybe he turned on the internet connection)
// We must try to get the data we need
- (void) refreshViewFromNoConnectionView {
    
    [self removeNoConnectionView];
    
    [self getData];
    
}

@end
