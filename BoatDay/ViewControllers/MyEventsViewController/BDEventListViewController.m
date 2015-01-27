//
//  BDEventListViewController.m
//  BoatDay
//
//  Created by Mieraidihaimu Mieraisan on 24/01/15.
//  Copyright (c) 2015 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEventListViewController.h"
#import "BDMyEventListCell.h"
@interface BDEventListViewController ()<UITableViewDataSource,UITableViewDelegate>

// Data
@property (nonatomic, strong) NSArray *events;
@end

@implementation BDEventListViewController

- (instancetype)initWithEvents:(NSArray *)events {
    
    self = [super init];
    
    if( !self ) return nil;

    _events = events;

    return self;
    
}
- (instancetype)initWithEventsHostingAndHistory:(NSArray *)events{
    NSArray *reorderEvents = [events sortedArrayUsingComparator:
                              ^(Event *obj1, Event *obj2) {
                                  return [obj2.startsAt compare:obj1.startsAt];
                              }];

    return [self initWithEvents:reorderEvents];

}
- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];

    [self setupTableView];
    
    if (!self.events.count) {
        [self addPlaceholderViewWithTitle:@"There are no events available!" andMessage:@"" toView:self.view];
    }
    
}

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDMyEventListCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDMyEventListCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.delaysContentTouches = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;

    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event *event = self.events[indexPath.row];
   
    BDMyEventListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDMyEventListCell reuseIdentifier]];
    
//    NSDate *now = [NSDate date];
    
    // Event Started
//    if ([now compare:event.startsAt] == NSOrderedDescending) {
//        cell.shouldBeGray = YES;
//    }
//    else {
//        cell.shouldBeGray = NO;
//    }
    
    [cell updateWithEvent:event];
    
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
    
    Event *event = self.events[indexPath.row];
    
    if (self.eventTappedBlock) {
        self.eventTappedBlock(event);
    }
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
