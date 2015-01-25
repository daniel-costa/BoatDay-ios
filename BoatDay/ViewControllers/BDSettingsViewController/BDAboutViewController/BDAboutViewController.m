//
//  BDAboutViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 22/08/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDAboutViewController.h"
#import "BDEventGuestsCell.h"
#import "DevProfile.h"
#import "BDTermsOfServiceViewController.h"
@interface BDAboutViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;

@property (strong, nonatomic) NSMutableArray *peopleArray;

@end

@implementation BDAboutViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.screenName =@"BDAboutViewController";

    self.title = NSLocalizedString(@"aboutView.title", nil);
    
    [self createPeopleArray];
    
    [self setupHeaderView];
    
    [self setupTableView];
    
}

- (void) createPeopleArray {
    
    self.peopleArray = [[NSMutableArray alloc] init];
    
    DevProfile *diogoNunes = [[DevProfile alloc] initWithName:@"Diogo Nunes"
                                                     position:@"iOS Developer"
                                                    imageName:@"DiogoNunes.png"];
    
    [self.peopleArray addObject:diogoNunes];

    
    DevProfile *conrad = [[DevProfile alloc] initWithName:@"Conrad V."
                                                 position:@"CMS Developer"
                                                imageName:@"Conrad.png"];
    
    [self.peopleArray addObject:conrad];
    
    DevProfile *rJ = [[DevProfile alloc] initWithName:@"RJ NYE"
                                                     position:@"Graphic Designer"
                                                    imageName:@"RJ.png"];
    
    [self.peopleArray addObject:rJ];
 
    DevProfile *brooks = [[DevProfile alloc] initWithName:@"Chris Brooks"
                                             position:@"Project Manager"
                                            imageName:@"ChrisBrooks.png"];
    
    [self.peopleArray addObject:brooks];
    
    DevProfile *peter = [[DevProfile alloc] initWithName:@"Peter Yoder"
                                                 position:@"Project Manager"
                                                imageName:@"PeterYoder.png"];
    
    [self.peopleArray addObject:peter];
    
    DevProfile *steveNelson = [[DevProfile alloc] initWithName:@"Steven Nelson"
                                                position:@"QA Tester"
                                               imageName:@"SteveNelson.png"];
    
    [self.peopleArray addObject:steveNelson];
    
    DevProfile *lindenmayer = [[DevProfile alloc] initWithName:@"Chris L."
                                                      position:@"Creative Director"
                                                     imageName:@"ChrisLindenmayer.png"];
    
    [self.peopleArray addObject:lindenmayer];
    
    DevProfile *stevenWalker = [[DevProfile alloc] initWithName:@"Steven Walker"
                                                      position:@"UX Designer"
                                                     imageName:@"StevenWalker.png"];
    
    [self.peopleArray addObject:stevenWalker];
}

#pragma mark - Setup Methods

- (void) setupHeaderView {
    
    self.versionLabel.font = [UIFont quattroCentoBoldFontWithSize:16.0];
    self.versionLabel.textColor = [UIColor mediumGreenBoatDay];
    
    self.versionLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"aboutView.version", nil), [self versionBuild]];
    
    NSString *dateString = @"©2014";
    NSString *companyName = @"Peer-to-Pier Technologies";
    NSString *llcString = @", LLC";
    
    NSString *text = [NSString stringWithFormat:@"%@ %@%@", dateString, companyName, llcString];
    
    // Define general attributes for the entire text
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName:[UIColor grayBoatDay],
                              NSFontAttributeName: [UIFont quattroCentoBoldFontWithSize:14.0]
                              };
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text
                                                                                       attributes:attribs];
    
    
    NSRange range = [text rangeOfString:companyName];
    [attributedText setAttributes:@{NSForegroundColorAttributeName: [UIColor mediumGreenBoatDay],
                                    NSFontAttributeName:[UIFont quattroCentoBoldFontWithSize:14.0]} range:range];
    
    
    self.companyLabel.attributedText = attributedText;
    
    
    self.termsLabel.font = [UIFont quattroCentoRegularFontWithSize:14.0];
    self.termsLabel.textColor = [UIColor mediumGrayBoatDay];
    self.termsLabel.textAlignment = NSTextAlignmentLeft;
    self.termsLabel.text = NSLocalizedString(@"settings.termsOfService", nil);
    

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToTermsCondition:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.termsLabel addGestureRecognizer:singleTap];
    [self.termsLabel setUserInteractionEnabled:YES];

    
}

- (void) setupTableView {
    
    // Register nib cell class so they can be used in cellForRow
    UINib *storesCellNib = [UINib nibWithNibName:NSStringFromClass([BDEventGuestsCell class]) bundle:nil];
    [self.tableView registerNib:storesCellNib forCellReuseIdentifier:[BDEventGuestsCell reuseIdentifier]];
    
    // setup table view
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.delaysContentTouches = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.tableView.tableHeaderView = self.headerView;
    
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfColumns = 3;
    NSInteger numberOfUsers = self.peopleArray.count;
    
    NSInteger numberOfRows = ceil(numberOfUsers / (CGFloat)numberOfColumns);
    
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BDEventGuestsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BDEventGuestsCell reuseIdentifier]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DevProfile *firstUser, *secondUser, *thirdUser = nil;
    NSMutableArray *usersArray = self.peopleArray;
    
    NSInteger startPosition = (indexPath.row) * 3;
    
    firstUser = usersArray.count > startPosition ? usersArray[startPosition] : nil;
    secondUser = usersArray.count > startPosition+1 ? usersArray[startPosition+1] : nil;
    thirdUser = usersArray.count > startPosition+2 ? usersArray[startPosition+2] : nil;
    
    [cell updateCellWithFirstUser:firstUser
                       secondUser:secondUser
                        thirdUser:thirdUser];
    
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


#pragma mark - Get Version Methods

- (NSString *) appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}

- (NSString *) build
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

- (NSString *) versionBuild
{
    NSString * version = @"1 ";
    NSString * build = [self build];
    
    NSString * versionBuild = [NSString stringWithFormat: @"%@", version];
    
    if (![version isEqualToString: build]) {
        versionBuild = [NSString stringWithFormat: @"%@(%@)", versionBuild, build];
    }
    
    return versionBuild;
}

#pragma mark - Get Terms
- (void) pushToTermsCondition:(UITapGestureRecognizer *)sender{
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"pushToTermsCondition"
                                                                label:self.screenName
                                                                value:nil] build]];


    BDTermsOfServiceViewController *termsOfServiceViewController = [[BDTermsOfServiceViewController alloc] init];
    [self.navigationController pushViewController:termsOfServiceViewController animated:YES];
}


@end
