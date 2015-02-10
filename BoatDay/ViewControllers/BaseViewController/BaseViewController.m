//
//  BaseViewController.h
//
//  Created by Diogo Nunes on 28/05/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"
#import <AudioToolbox/AudioServices.h>

@interface BaseViewController ()

@property (strong, nonatomic) UIView *placeholderView;
@property (strong, nonatomic) NoConnectionView *noConnectionView;
@property (strong, nonatomic) BDPlaceholderView *bdPlaceholderView;

- (UIView *)placeholderView;
- (void)showFullPageLoadingViewWithMessage:(NSString*)message;
- (void)hideFullPageLoading;
- (void)addActivityView;
- (void)removeActivityView;
- (void)addNoConnectionView;
- (void)removeNoConnectionView;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tracker = [[GAI sharedInstance] defaultTracker];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    // DC Desactive the Back text when comming from HomeScreen
//    self.navigationItem.title = @"";
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    
    if (self.navigationController.childViewControllers.count > 1) {
        [self setupBackButton];
    }
    else {
        [self setupLeftSideMenuButton];
    }
    
//    self.navigationItem.leftBarButtonItem.title = @"";
    
}

- (BOOL)prefersStatusBarHidden {
    
    return NO;
    
}

- (void) setupBackButton {
    /*
     UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
     backButton.frame = CGRectMake(0, 0, 28, 15);
     backButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, -11.0, 0, 0);
     
     [backButton setImage:[UIImage imageNamed:@"hamburguerIcon"] forState:UIControlStateNormal];
     [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
     UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
     self.navigationItem.leftBarButtonItem = leftBarButtonItem;
     */
}

- (void) setupLeftSideMenuButton {
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 30, 30);
    [backButton setImage:[UIImage imageNamed:@"ico-Hamburger"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
}

#pragma mark - Actions Methods

- (void) leftSideMenuButtonPressed:(id) sender {
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}

- (void) backButtonPressed:(id) sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Placeholder View Methods

- (UIView *)placeholderView {
    
    if (_placeholderView == nil) {
        
        CGRect placeholderFrame = self.contentView.frame;
        
        UIView *placeholderView = [[UIView alloc] initWithFrame:placeholderFrame];
        placeholderView.backgroundColor = [UIColor whiteColor];
        
        _placeholderView = placeholderView;
        
        [self.view insertSubview:_placeholderView belowSubview:self.contentView];
    }
    
    return _placeholderView;
}

#pragma mark - Activity View Methods

- (void)showFullPageLoadingViewWithMessage:(NSString*)message {
    
    if(!message) {
        [DejalBezelActivityView activityViewForView:self.navigationController.view];
    }
    else {
        [DejalBezelActivityView activityViewForView:self.navigationController.view withLabel:message];
        
    }
    [DejalBezelActivityView currentActivityView].showNetworkActivityIndicator = YES;
    
}

- (void)hideFullPageLoading {
    
    [DejalBezelActivityView currentActivityView].showNetworkActivityIndicator = NO;
    [[DejalBezelActivityView currentActivityView] removeFromSuperview];
}

- (void)addActivityView {
    
    self.loadingView = [[NRLoadingView alloc] initWithFrame:self.placeholderView.bounds];
    
    [self.placeholderView addSubview:self.loadingView];
    [UIView showViewAnimated:self.loadingView withAlpha:YES duration:0.3 andDelay:0.0 andScale:NO];
    
    self.contentView.hidden = YES;
    
}

- (void)removeActivityView {
    
    [UIView removeViewAnimated:self.loadingView withAlpha:YES andDuration:0.0];
    
    self.contentView.hidden = NO;
    
}

- (void)addActivityViewforView:(UIView*)view withMessage:(NSString*)message {
    
    if ([self.loadingView superview] != view) {
        self.loadingView = [[NRLoadingView alloc] initWithFrame:view.bounds withMessage:message];
        self.loadingView.tag = 6564564;
        
        [UIView showViewAnimated:self.loadingView withAlpha:YES duration:0.3 andDelay:0.0 andScale:NO];
        [view addSubview:self.loadingView];
    }
    
}

- (void)addActivityViewforView:(UIView*)view {
    
    if ([self.loadingView superview] != view) {
        self.loadingView = [[NRLoadingView alloc] initWithFrame:view.bounds];
        self.loadingView.tag = 6564564;
        
        [UIView showViewAnimated:self.loadingView withAlpha:YES duration:0.0 andDelay:0.0 andScale:NO];
        [view addSubview:self.loadingView];
    }
    
}

- (void)removeActivityViewFromView:(UIView*)view {
    
    if ([self.loadingView superview]) {
        [UIView removeViewAnimated:self.loadingView withAlpha:YES andDuration:0.0];
    }
    
}

#pragma mark - No Connection View Methods

- (void)addNoConnectionView {
    
    self.noConnectionView = (NoConnectionView *)[[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil][0];
    self.noConnectionView.delegate = self;
    self.noConnectionView.frame = self.placeholderView.bounds;
    
    [UIView showViewAnimated:self.noConnectionView withAlpha:YES duration:0.5 andDelay:0.0 andScale:NO];
    
    [self.placeholderView addSubview:self.noConnectionView];
    
    self.contentView.hidden = YES;
    
}

- (void)removeNoConnectionView {
    
    [UIView removeViewAnimated:self.noConnectionView withAlpha:YES andDuration:0.1];
    
    [self.noConnectionView removeFromSuperview];
    
    self.contentView.hidden = NO;
    
}

#pragma mark - Placeholder View Methods

- (void)addPlaceholderViewWithTitle:(NSString*)title andMessage:(NSString*)message toView:(UIView*)view {
    
    self.bdPlaceholderView = (BDPlaceholderView *)[[NSBundle mainBundle] loadNibNamed:@"BDPlaceholderView" owner:self options:nil][0];
    self.bdPlaceholderView.frame = view.bounds;
    [self.bdPlaceholderView setTitle:title andMessage:message];
    
    [UIView showViewAnimated:self.bdPlaceholderView withAlpha:YES duration:0.5 andDelay:0.0 andScale:NO];
    
    [view addSubview:self.bdPlaceholderView];
    
}

- (void)removePlaceholderView {
    
    if ([self.bdPlaceholderView superview]) {
        [UIView removeViewAnimated:self.bdPlaceholderView withAlpha:YES andDuration:0.0];
    }
    
}

- (void)playSound:(NSString*) name {
    SystemSoundID sound;
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:name ofType:@"wav"];
    CFURLRef soundURL = (__bridge CFURLRef)[NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID(soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
}

@end
