//
//  BDTermsOfServiceViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 03/09/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDTermsOfServiceViewController.h"

@interface BDTermsOfServiceViewController (){
    NSString *topTitle;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BDTermsOfServiceViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"termsOfService.title", nil);

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    self.webView.backgroundColor = [UIColor greenBoatDay];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"termsAndConditions" ofType:@"pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.webView loadRequest:request];
    
}

@end

