//
//  BDFindABoatCalendarViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindABoatCalendarViewController.h"
#import "CKCalendarView.h"
#import "BDFindABoatCalendarCell.h"

@interface BDFindABoatCalendarViewController () <CKCalendarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CKCalendarView *calendar;

@property (strong, nonatomic) NSMutableArray *eventsToShow;


// Data
@property (nonatomic, strong) NSArray *events;

@end

@implementation BDFindABoatCalendarViewController

- (instancetype)initWithEvents:(NSArray *)events {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _events = events;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.eventsToShow = [[NSMutableArray alloc] init];
    
    [self setupCalendar];
    
    [self setupTableView];
    
}

#pragma mark - Setup Methods

- (void) setupCalendar {
    
    //configure the calendar
    self.calendar = nil;
    self.calendar = [[CKCalendarView alloc] initWithStartDay:startSunday selectedDay:[NSDate date]];
    self.calendar = self.calendar;
    self.calendar.delegate = self;
    self.calendar.onlyShowCurrentMonth = NO;
    self.calendar.adaptHeightToNumberOfWeeksInMonth = NO;
    
    [self.calendar selectDate:[NSDate date] makeVisible:YES];
    [self.calendar layoutSubviews];
    
}

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDFindABoatCalendarCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDFindABoatCalendarCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.delaysContentTouches = YES;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.tableHeaderView = self.calendar;
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    [self.eventsToShow removeAllObjects];
    
    for (Event *event in self.events) {
        
        if ([event.startsAt isSameDay:self.calendar.selectedDate]) {
            
            [self.eventsToShow addObject:event];
            
        }
        
    }
    
    return self.eventsToShow.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event *event = self.eventsToShow[indexPath.row];
    
    BDFindABoatCalendarCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDFindABoatCalendarCell reuseIdentifier]];
    
    NSDate *now = [NSDate date];
    
    // Event Started
    if ([now compare:event.startsAt] == NSOrderedDescending) {
        cell.shouldBeGray = YES;
    }
    else {
        cell.shouldBeGray = NO;
    }
    
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
    
    Event *event = self.eventsToShow[indexPath.row];
    
    if (self.eventTappedBlock) {
        self.eventTappedBlock(event);
    }
    
}

#pragma mark - CKCalendar Delegate Methods

- (BOOL)calendar:(CKCalendarView *)calendar bottomIndicatorForDate:(NSDate *)date {
    
    for (Event *event in self.events) {
        if ([event.startsAt isSameDay:date]) {
            return YES;
        }
    }
    
    return NO;
    
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    
    //[self.tableView reloadData];
    NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
    
}


@end
