//
//  DNButtonContainerView.h
//
//  Created by Diogo Nunes on 25/10/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DNButtonContainerViewDelegate <NSObject>

- (void)touchedButtonContainerView:(UIView*)view;
- (void)releasedButtonContainerView:(UIView*)view;
- (void)pressedButtonContainerView:(UIView*)view;

@end

@interface DNButtonContainerView : UIView

@property (nonatomic, weak) IBOutlet id<DNButtonContainerViewDelegate> delegate;
@property (nonatomic) BOOL isPressed;

@end
