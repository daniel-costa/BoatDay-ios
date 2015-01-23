//
//  BDFindABoatFilterFamilyContentViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 05/08/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindABoatFilterFamilyContentViewController.h"
#import "BDFindABoatFilterFamilyContentViewCell.h"

extern const NSString * kChildrenPermitted;
extern const NSString * kSmokingPermitted;
extern const NSString * kAlcoholPermitted;

@interface BDFindABoatFilterFamilyContentViewController ()



@property (strong, nonatomic) NSMutableDictionary *filterDictionary;

@end

@implementation BDFindABoatFilterFamilyContentViewController

- (instancetype)initWithFilterDictionary:(NSMutableDictionary*)filterDictionary {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _filterDictionary = filterDictionary;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"familyContent.title", nil);
    
    [self setupTableView];
    
}

#pragma mark - Setup Methods

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDFindABoatFilterFamilyContentViewCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDFindABoatFilterFamilyContentViewCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor lightGrayBoatDay];
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDFindABoatFilterFamilyContentViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDFindABoatFilterFamilyContentViewCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 0: // children permitted
        {
            cell.titleLabel.text = [NSLocalizedString(@"findABoat.familyContent.childrenPermitted", nil) uppercaseString];
            
            if ([self.filterDictionary[kChildrenPermitted] integerValue] == -1) {
                [cell.MBSwitch setOn:NO];
            }
            else {
                [cell.MBSwitch setOn:[self.filterDictionary[kChildrenPermitted] boolValue]];
            }
            
            [cell setMbSwitchChangeBlock:^(BOOL isON) {
                
                self.filterDictionary[kChildrenPermitted] = @(isON);
                
            }];
        }
            break;
        case 1: // alcohol permitted
        {
            cell.titleLabel.text = [NSLocalizedString(@"findABoat.familyContent.alcoholPermitted", nil) uppercaseString];
            
            if ([self.filterDictionary[kChildrenPermitted] integerValue] == -1) {
                [cell.MBSwitch setOn:NO];
            }
            else {
                [cell.MBSwitch setOn:[self.filterDictionary[kAlcoholPermitted] boolValue]];
            }
            
            [cell setMbSwitchChangeBlock:^(BOOL isON) {
                
                self.filterDictionary[kAlcoholPermitted] = @(isON);
                
            }];
        }
            break;
        case 2: // smoking permitted
        {
            cell.titleLabel.text = [NSLocalizedString(@"findABoat.familyContent.smokingPermitted", nil) uppercaseString];
            
            if ([self.filterDictionary[kChildrenPermitted] integerValue] == -1) {
                [cell.MBSwitch setOn:NO];
            }
            else {
                [cell.MBSwitch setOn:[self.filterDictionary[kSmokingPermitted] boolValue]];
            }
            
            [cell setMbSwitchChangeBlock:^(BOOL isON) {
                
                self.filterDictionary[kSmokingPermitted] = @(isON);
                
            }];
        }
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
    
}

@end
