//
//  BoatdayNotificationMessageView.h
//  Boatday
//
//  Created by mier on 29/01/15.
//  Copyright (c) 2014 Mieraidihaimu Mieraisan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoatdayNotificationMessage.h"
@interface BoatdayNotificationMessageView : UIView



@property (nonatomic,strong) NSString *pTitle;
@property (nonatomic,strong) NSString *pSubTitle;
@property (nonatomic) CGFloat duration;


-(void)configMessage:(NSString *)title
            subTitle:(NSString *)subTitle
           iconImage:(NSString *)iconImage
           durations:(CGFloat)durations
            callback:(void (^)())callback
      viewController:(UIViewController *)viewController
       typeOfMessage:(BoatdayNotificationMessageType)typeOfMessage;

-(void)fadeMeOut;

@end
