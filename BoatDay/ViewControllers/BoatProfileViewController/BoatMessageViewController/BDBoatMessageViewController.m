//
//  BDViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDBoatMessageViewController.h"

@interface BDBoatMessageViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *adminLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) Boat *boat;

@end

@implementation BDBoatMessageViewController

// init this view with message
- (instancetype)initWithNotificationForBoat:(Boat*)boat {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _boat = boat;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"boatProfile.messageNotification.title", nil);
    
    [self setupView];
    
}

// setup view
- (void) setupView {
    
    self.adminLabel.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.adminLabel.textColor = [UIColor yellowBoatDay];
    
    self.nameLabel.font = [UIFont quattroCentoRegularFontWithSize:21.0];
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.dateLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.dateLabel.textColor = [UIColor whiteColor];
    
    self.textView.font = [UIFont quattroCentoRegularFontWithSize:15.0];
    self.textView.textColor = [UIColor grayBoatDay];
    self.textView.backgroundColor = [UIColor clearColor];
    
    self.nameLabel.text = self.boat.name;
    self.adminLabel.text = NSLocalizedString(@"boatProfile.messageNotification.adminName", nil);
    
    NSDateFormatter *dateFormatter = [NSDateFormatter notificationMessageDateFormatter];
    NSString *createdAt = [dateFormatter stringFromDate:self.boat.rejectionMessage.createdAt];
    self.dateLabel.text = createdAt;
    
    self.textView.text = self.boat.rejectionMessage.text;
    
}

@end
