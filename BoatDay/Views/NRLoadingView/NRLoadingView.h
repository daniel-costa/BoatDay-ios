//
//  NRLoadingView.h
//
//  Created by Diogo Nunes on 10/12/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NRLoadingView : UIView

- (instancetype)initWithFrame:(CGRect)frame withMessage:(NSString*)message NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

@end
