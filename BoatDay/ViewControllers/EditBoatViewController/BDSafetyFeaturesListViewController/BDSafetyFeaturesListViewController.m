//
//  BDSafetyFeaturesListViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 28/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDSafetyFeaturesListViewController.h"
#import "BDEditBoatDefaultCell.h"

@interface BDSafetyFeaturesListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *safetyFeatures;
@property (strong, nonatomic) NSMutableArray *selectedSafetyFeatures;

@end

@implementation BDSafetyFeaturesListViewController

- (instancetype)initWithSelectedSafetyFeatures:(NSMutableArray *)selectedSafetyFeatures {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _selectedSafetyFeatures = selectedSafetyFeatures;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"addEditBoat.safetyFeatures.title", nil);
    
    // setup view
    [self setupTableView];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self getData];
    
}

- (void) getData {
    
    // Get all Safety Features
    [self getSafetyFeatures];
    
}

- (void) getSafetyFeatures {
    
    // Add a loading view while we fetch the data
    [self addActivityViewforView:self.contentView];
    
    PFQuery *query = [SafetyFeature query];
    [query orderByAscending:@"order"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *safetyFeatures, NSError *error) {
        
        if (!error) {
            
            // store objects in session
            self.safetyFeatures = safetyFeatures;
            
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

#pragma mark - Setup Methods

- (void) setupTableView {
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.safetyFeatures.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self defaultCellRowForIndexPath:indexPath];
}

- (UITableViewCell *) defaultCellRowForIndexPath:(NSIndexPath*)indexPath {
    
    BDEditBoatDefaultCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    
    if (cell == nil) {
        
        cell = [[BDEditBoatDefaultCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"defaultCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont abelFontWithSize:14.0];
        cell.textLabel.textColor = [UIColor grayBoatDay];
        
        cell.detailTextLabel.font = [UIFont abelFontWithSize:11.0];
        cell.detailTextLabel.textColor = [UIColor grayBoatDay];
        cell.detailTextLabel.numberOfLines = 0;
        
        // arrow as cell accessory view
        UIImage *arrowImage = [UIImage imageNamed:@"cert_approved"];
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        CGRect frame = CGRectMake(0.0, 0.0, arrowImage.size.width, arrowImage.size.height); // 18x21
        arrowImageView.frame = frame;
        arrowImageView.image = arrowImage;
        arrowImageView.backgroundColor = [UIColor clearColor];
        cell.accessoryView = arrowImageView;
        
    }
    
    SafetyFeature *safetyFeature = self.safetyFeatures[indexPath.row];
    
    cell.textLabel.text = [safetyFeature.name uppercaseString];
    cell.detailTextLabel.text = safetyFeature.details;
    cell.accessoryView.hidden = ![self.selectedSafetyFeatures containsObject:safetyFeature];
    
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
    
    SafetyFeature *safetyFeature = self.safetyFeatures[indexPath.row];
    
    if ([self.selectedSafetyFeatures containsObject:safetyFeature]) {
        [self.selectedSafetyFeatures removeObject:safetyFeature];
    }
    else {
        if (!self.selectedSafetyFeatures) {
            self.selectedSafetyFeatures = [[NSMutableArray alloc] init];
        }
        [self.selectedSafetyFeatures addObject:safetyFeature];
        
    }
    
    [self.tableView reloadData];
    
    if (self.safetyFeaturesArrayBlock) {
        self.safetyFeaturesArrayBlock(self.selectedSafetyFeatures);
    }
    
}

@end
