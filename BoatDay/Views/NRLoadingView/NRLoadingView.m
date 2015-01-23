//
//  NRLoadingView.m
//
//  Created by Diogo Nunes on 10/12/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import "NRLoadingView.h"
#import "UIImage+animatedGIF.h"

@interface NRLoadingView ()

@property (nonatomic,strong) NSString *message;
@property (nonatomic,strong) UIView *loadingView;

@end

@implementation NRLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

        [self setupView];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withMessage:(NSString*)message {
    self = [super initWithFrame:frame];
    if (self) {
        _message = message;
        [self setupView];
    }
    return self;
}

- (void) setupView {

    self.backgroundColor = [UIColor whiteColor];

    UIView *view = [[UIView alloc] init];

    UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 137.0, 42.0)];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loadingBoatDay" withExtension:@"gif"];
    animatedImageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    [view addSubview: animatedImageView];
    
    view.frame = animatedImageView.frame;

    view.center = self.center;
    
    self.loadingView = view;
    [self addSubview:view];
    
}

@end
