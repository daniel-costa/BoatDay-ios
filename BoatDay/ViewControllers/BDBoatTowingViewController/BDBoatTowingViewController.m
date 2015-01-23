//
//  BDBoatTowingViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 03/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDBoatTowingViewController.h"

@interface BDBoatTowingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *numberButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)numberButtonPressed:(id)sender;
@end

@implementation BDBoatTowingViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"boatTowing.title", nil);
    
    [self.numberButton setTitle:NSLocalizedString(@"boatTowing.phoneNumber", nil) forState:UIControlStateNormal];
    [self.numberButton setTitleColor:[UIColor mediumGreenBoatDay] forState:UIControlStateNormal];
    [self.numberButton setTitleColor:[UIColor grayBoatDay] forState:UIControlStateNormal];
    
    self.titleLabel.text = NSLocalizedString(@"boatTowing.titleText", nil);
    self.titleLabel.font = [UIFont quattroCentoBoldFontWithSize:16.0];
    self.titleLabel.textColor = [UIColor mediumGreenBoatDay];
    
    self.textView.text = NSLocalizedString(@"boatTowing.text", nil);
    self.textView.textAlignment = NSTextAlignmentCenter;
    self.textView.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.textView.textColor = [UIColor grayBoatDay];
    
}

- (IBAction)numberButtonPressed:(id)sender {
    
    NSString *phNo = NSLocalizedString(@"boatTowing.phoneNumber", nil);
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        
        [[UIApplication sharedApplication] openURL:phoneUrl];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"boatTowing.alert.title", nil)
                                                           message:NSLocalizedString(@"boatTowing.alert.message", nil)
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"errorMessages.ok", nil)
                                                 otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

@end
