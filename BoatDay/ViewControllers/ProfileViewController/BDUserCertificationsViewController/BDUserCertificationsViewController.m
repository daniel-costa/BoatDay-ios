//
//  BDUserCertificationsViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 25/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDUserCertificationsViewController.h"
#import "BDCertificationListCell.h"

@interface BDUserCertificationsViewController ()

@property (strong, nonatomic) User *user;

@property (strong, nonatomic) NSArray *certifications;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BDUserCertificationsViewController

- (instancetype)initWithUser:(User *)user {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _user = user;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([self.user isEqual:[User currentUser]]) {
        
        self.certifications = [Session sharedSession].myCertifications;
        
        if (self.certifications) {
            
            NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"approved == YES"];
            self.certifications = [self.certifications filteredArrayUsingPredicate:bPredicate];
            
            [self.tableView reloadData];
            
        }
        else {
            
            [self getData];
            
        }
    }
    else {
        
        [self getData];
        
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
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}


#pragma mark - Get Data Methods

- (void) getData {
    
    [self addActivityViewforView:self.contentView];
    
    PFQuery *query = [Certification query];
    [query includeKey:@"type"];
    [query whereKey:@"user" equalTo:self.user];
    [query whereKey:@"approved" equalTo:@(YES)];
    [query whereKey:@"deleted" notEqualTo:@(YES)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *certifications, NSError *error) {
        
        [self removeActivityViewFromView:self.contentView];
        
        if (!error) {
            
            self.certifications = certifications;
            [self.tableView reloadData];
            
        }
        else {
            
            
            // If something is wrong (99% is no connection), shows a warning
            
            [self addNoConnectionView];
            
        }
        
    }];
    
    
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.certifications.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDCertificationListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDCertificationListCell reuseIdentifier]];
    
    Certification *certification = self.certifications[indexPath.row];
    
    CertificationType *type = certification.type;
    
    cell.titleLabel.text = type.name;
    
    cell.status = [certification.status integerValue];
    
    cell.arrowImageView.hidden = YES;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - NoConnectionView Delegate Methods

// If user taps or try to reload the No Connection View (maybe he turned on the internet connection)
// We must try to get the data we need
- (void) refreshViewFromNoConnectionView {
    
    [self removeNoConnectionView];
    
    [self getData];
    
}

@end
