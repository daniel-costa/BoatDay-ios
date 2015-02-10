//
//  BoatdayNotificationMessage.m
//  Boatday
//
//  Created by mier on 29/01/15.
//  Copyright (c) 2014 Mieraidihaimu Mieraisan. All rights reserved.
//

#import "BoatdayNotificationMessage.h"
#import "BoatdayNotificationMessageView.h"

#define kBoatdayNotificationMessageDisplayTime 1.5
#define kBoatdayNotificationMessageExtraDisplayTimePerPixel 0.04
#define kBoatdayNotificationMessageAnimationDuration 0.3

@interface BoatdayNotificationMessage ()

/** The queued messages (TSMessageView objects) */
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic,weak) UIViewController *pWeakController;
@end

@implementation BoatdayNotificationMessage

static BoatdayNotificationMessage *sharedMessage;

+ (BoatdayNotificationMessage *)sharedMessage
{
    static dispatch_once_t once;

    dispatch_once(&once, ^ { sharedMessage = [[[self class] alloc] init];
});

    return sharedMessage;
}


+ (void)showNotificationMessage:(NSString *)title
                       subTitle:(NSString *)subTitle
                      iconImage:(NSString *)iconImage
                 viewController:(UIViewController *)viewController
                       callback:(void (^)())callback
                  typeOfMessage:(BoatdayNotificationMessageType)typeOfMessage{
    BoatdayNotificationMessageView *pView = [[BoatdayNotificationMessageView alloc] initWithFrame:CGRectMake(0, -60, 320, 60)];
    [pView configMessage:title subTitle:subTitle
               iconImage:iconImage
               durations:3
                callback:callback
          viewController:viewController
           typeOfMessage:typeOfMessage];
    
    [self prepareNotificationToBeShown:pView];
}

+ (void)prepareNotificationToBeShown:(BoatdayNotificationMessageView *)messageView{

    for (BoatdayNotificationMessageView *n in [BoatdayNotificationMessage sharedMessage].messages)
    {
        if (([n.pTitle isEqualToString:messageView.pTitle] || (!n.pTitle && !messageView.pTitle)) && ([n.pSubTitle isEqualToString:messageView.pSubTitle] || (!n.pSubTitle && !messageView.pSubTitle)))
        {
            return; // avoid showing the same messages twice in a row
        }
    }
    
    [[[BoatdayNotificationMessage sharedMessage] messages] addObject:messageView];

    [[BoatdayNotificationMessage sharedMessage] fadeInCurrentNotification];

    
}


#pragma mark Fading in/out the message view

- (id)init
{
    if ((self = [super init]))
    {
        NSLog(@"init");
        _messages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)fadeInCurrentNotification
{
    if ([self.messages count] == 0) return;
    
    BoatdayNotificationMessageView *currentView = [self.messages objectAtIndex:0];

    CGPoint toPoint= CGPointMake(320/2, 30+44);
    dispatch_block_t animationBlock = ^{
        currentView.center = toPoint;
//        currentView.alpha = TSMessageViewAlpha;
    };
    void(^completionBlock)(BOOL) = ^(BOOL finished) {
//        currentView.messageIsFullyDisplayed = YES;
    };
    
    [UIView animateWithDuration:kBoatdayNotificationMessageAnimationDuration + 0.1
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:animationBlock
                     completion:completionBlock];
    
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self performSelector:@selector(fadeOutNotification:)
                                  withObject:currentView
                                  afterDelay:currentView.duration];
                   });


}


- (void)fadeOutNotification:(BoatdayNotificationMessageView *)currentView
{
    [self fadeOutNotification:currentView animationFinishedBlock:nil];
}

- (void)fadeOutNotification:(BoatdayNotificationMessageView *)currentView animationFinishedBlock:(void (^)())animationFinished
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(fadeOutNotification:)
                                               object:currentView];
    
    CGPoint fadeOutToPoint;
    fadeOutToPoint = CGPointMake(currentView.center.x, -CGRectGetHeight(currentView.frame)/2.f);

    [UIView animateWithDuration:kBoatdayNotificationMessageAnimationDuration animations:^
     {
         currentView.center = fadeOutToPoint;

             currentView.alpha = 0.f;

     } completion:^(BOOL finished)
     {
         [currentView removeFromSuperview];
       
         
         if ([self.messages count] > 0)
         {
             [self.messages removeObjectAtIndex:0];
         }
         

         
         if ([self.messages count] > 0)
         {
             [self fadeInCurrentNotification];
         }
         
         if(animationFinished) {
             animationFinished();
         }
     }];
}

@end
