//
//  NoConnectionView.h
//
//  Created by Diogo Nunes on 9/16/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoConnectionViewDelegate <NSObject>

@optional

- (void) refreshViewFromNoConnectionView;

@end

@interface NoConnectionView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id<NoConnectionViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@property (weak, nonatomic) IBOutlet UIScrollView *verticalScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *horizontalScrollView;

- (IBAction)messageButtonPressed:(id)sender;

@end
