//
//  BoatdayNotificationMessageView.m
//  Boatday
//
//  Created by mier on 29/01/15.
//  Copyright (c) 2014 Mieraidihaimu Mieraisan. All rights reserved.
//

#import "BoatdayNotificationMessageView.h"

@interface BoatdayNotificationMessage (BoatdayNotificationMessageView)
- (void)fadeOutNotification:(BoatdayNotificationMessageView *)currentView; // private method of TSMessage, but called by TSMessageView in -[fadeMeOut]
@end
@interface BoatdayNotificationMessageView()<UIGestureRecognizerDelegate>{
    UIImageView* _appIcon;
    UILabel* _titleLabel;
    UILabel* _dateLabel;
    UILabel* _messageLabel;
    
    UIView* _notificationContentView;

}


@property (nonatomic,strong) UILabel *pTitleLable;
@property (nonatomic,strong) UILabel *pSubTitleLable;
@property (nonatomic,strong) UIImageView *pIconImageView;

@property (nonatomic,weak) UIViewController *pWeakController;


@property (copy) void (^callback)();
@end


@implementation BoatdayNotificationMessageView
/*
+ (BoatdayNotificationMessageView*)sharedView {
    static dispatch_once_t once;
    static BoatdayNotificationMessageView *sharedView;
    dispatch_once(&once, ^ { sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
    return sharedView;
}
*/

-(instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    if(self)
    {
        
        
        self.backgroundColor = [UIColor darkGreenBoatDay];
        
        
        _notificationContentView = [[UIView alloc] initWithFrame:self.bounds];

        _appIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 30, 30)];
        _appIcon.contentMode = UIViewContentModeScaleAspectFit;

        
        
        [_notificationContentView addSubview:_appIcon];
        
        
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 8, 160, 15)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:13];
        _titleLabel.textColor = [UIColor whiteColor];

        
        [_notificationContentView addSubview:_titleLabel];
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(46, 24, 320-56, 50)];
        _messageLabel.font = [UIFont systemFontOfSize:13];
        _messageLabel.textColor = [UIColor whiteColor];

        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode=NSLineBreakByWordWrapping;

        
        [_notificationContentView addSubview:_messageLabel];
        
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 8, 100, 15)];
        _dateLabel.textAlignment=NSTextAlignmentRight;
        _dateLabel.font = [UIFont systemFontOfSize:13];
        _dateLabel.textColor = [UIColor whiteColor];

        [_dateLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
        [_dateLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisVertical];
        [_dateLabel setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
        [_dateLabel setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisVertical];
        
        
        [_notificationContentView addSubview:_dateLabel];
        
//        UIView* drawer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, 5)];
//        drawer.backgroundColor = [UIColor whiteColor];
//
//        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 37, 5) cornerRadius:3];
//        CAShapeLayer* layer = [CAShapeLayer layer];
//        layer.path = path.CGPath;
//        
//        drawer.layer.mask = layer;
//        drawer.center=CGPointMake(self.center.x, self.frame.size.height-10);
//        [_notificationContentView addSubview:drawer];
        
        
        [self addSubview:_notificationContentView];
        
        
       
       
        
        
        

    }
    return self;

}

-(void)configMessage:(NSString *)title
            subTitle:(NSString *)subTitle
           iconImage:(NSString *)iconImage
           durations:(CGFloat)durations
            callback:(void (^)())callback
      viewController:(UIViewController *)viewController
       typeOfMessage:(BoatdayNotificationMessageType)typeOfMessage{
    
    _duration = durations;
    
    _appIcon.image = [UIImage imageNamed:@"myboats_noboats"];
    _titleLabel.text = title;
    _messageLabel.text = subTitle;
    _dateLabel.text = NSLocalizedString(@"now", @"");
    [_messageLabel sizeToFit];

   self.callback=callback;
    
    if (self.callback) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
     __weak MMDrawerController *pWeak = (MMDrawerController *)viewController;
            if (viewController && pWeak.centerViewController.navigationController) {
                __weak UINavigationController *pWeakNav = (UINavigationController *)pWeak.centerViewController;


                [viewController.view insertSubview:self belowSubview:pWeakNav.navigationBar];
            }else{
                [viewController.view addSubview:self];
        
            
            }

//    return self;

}

- (void)layoutSubviews
{
    [super layoutSubviews];
}
- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.duration == -1 && self.superview && !self.window ) {
        // view controller was dismissed, let's fade out
        [self fadeMeOut];
    }
}
-(void)fadeMeOut{
    [[BoatdayNotificationMessage sharedMessage] performSelectorOnMainThread:@selector(fadeOutNotification:) withObject:self waitUntilDone:NO];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateRecognized)
    {
        if (self.callback)
        {
            self.callback();
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ! ([touch.view isKindOfClass:[UIControl class]]);
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
