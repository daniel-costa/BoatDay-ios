//
//  BDActivitiesListViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 25/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDActivitiesListViewController.h"
#import "BDActivitiesListCell.h"

@interface BDActivitiesListViewController () <BDActivitiesListCellDelegate>

@property (nonatomic, strong) NSMutableArray *activities;

// View
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BDActivitiesListViewController

// init this view with diferent profile types (self  and other)
- (instancetype)initWithActivities:(NSMutableArray *)activities {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _activities = activities;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
        self.screenName =@"BDActivitiesListViewController";

    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDActivitiesListCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDActivitiesListCell reuseIdentifier]];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 29.0)];
    [view setBackgroundColor:[UIColor lightGrayBoatDay]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0.0, tableView.frame.size.width, 23.0)];
    
    label.font = [UIFont abelFontWithSize:14.0];
    label.text = [[Session sharedSession].activitiesByTypes allKeys][section];
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [Session sharedSession].activitiesByTypes.count;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[Session sharedSession].activitiesByTypes allKeys][section];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDActivitiesListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDActivitiesListCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.section = indexPath.section;
    cell.delegate = self;
    
    // Get Activities to show
    NSString *key = [[Session sharedSession].activitiesByTypes allKeys][indexPath.section];
    NSMutableArray *typeArray = [Session sharedSession].activitiesByTypes[key];
    
    for (int i = 0; i < 4; i++) {
        
        UIView *view = (UIView *)[cell viewWithTag:VIEWS_PREFIX + i];
        
        if (i < typeArray.count) {
            
            view.hidden = NO;
            
            Activity *activity = typeArray[i];
            
            NSMutableArray *userActivities = self.activities;
            
            cell.selectedArray[i] = @([userActivities containsObject:activity]);
            
            UIImageView *imageView = (UIImageView *)[view viewWithTag:IMAGE_TAG];
            
            PFFile *theImage = activity.picture;
            
            // Get image from cache or from server if isnt available (background task)
            [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                UIImage *image = [UIImage imageWithData:data];
                
                imageView.image = image;
                [UIView showViewAnimated:imageView withAlpha:YES andDuration:0.2];
                
            }];
            
            UILabel *activityNameLabel = (UILabel *)[view viewWithTag:LABEL_TAG];
            activityNameLabel.text = [activity.name uppercaseString];
            
        }
        else {
            view.hidden = YES;
        }
    }
    
    [cell updateCell];
    
    return cell;
}

#pragma mark - BDActivitiesListCell Delegate Methods

- (void)viewTappedAtSection:(NSInteger)section andRow:(NSInteger)row isSelected:(BOOL)selected {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"BDActivitiesListCellTapped"
                                                                label:self.screenName
                                                                value:nil] build]];


    NSString *key = [[Session sharedSession].activitiesByTypes allKeys][section];
    NSMutableArray *typeArray = [Session sharedSession].activitiesByTypes[key];
    Activity *activity = typeArray[row];
    
    if (selected) {
        
        if (!self.activities) {
            
            self.activities = [[NSMutableArray alloc]init];
            
        }
        
        [self.activities addObject:activity];
        
        
    } else {
        
        [self.activities removeObject:activity];
        
    }
    
    
    if (self.activitiesChangeBlock){
        self.activitiesChangeBlock(self.activities);
    }
    
}

@end
