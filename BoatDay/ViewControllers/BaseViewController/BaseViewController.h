//
//  BaseViewController.h
//
//  Created by Diogo Nunes on 28/05/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRLoadingView.h"
#import "NoConnectionView.h"
#import "DejalActivityView.h"
#import "BDPlaceholderView.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
@interface BaseViewController : GAITrackedViewController <NoConnectionViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) NRLoadingView *loadingView;

#pragma mark - Activity View Methods

- (void)addActivityView;

- (void)removeActivityView;

- (void)addActivityViewforView:(UIView*)view;

- (void)addActivityViewforView:(UIView*)view withMessage:(NSString*)message;

- (void)removeActivityViewFromView:(UIView*)view;

- (void)showFullPageLoadingViewWithMessage:(NSString*)message;

- (void)hideFullPageLoading;

#pragma mark - No Connection View Methods

- (void)addNoConnectionView;

- (void)removeNoConnectionView;

#pragma mark - Placeholder View Methods

- (void)addPlaceholderViewWithTitle:(NSString*)title andMessage:(NSString*)message toView:(UIView*)view;

- (void)removePlaceholderView;

@end
