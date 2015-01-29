//
//  BoatdayNotificationMessage.h
//  Boatday
//
//  Created by mier on 29/01/15.
//  Copyright (c) 2014 Mieraidihaimu Mieraisan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BoatdayNotificationMessageType) {
    BoatdayNotificationMessageTypeMessage = 0,
    BoatdayNotificationMessageTypeWarning,
    BoatdayNotificationMessageTypeError,
    BoatdayNotificationMessageTypeSuccess
};


@interface BoatdayNotificationMessage : NSObject


+ (instancetype)sharedMessage;

+ (void)showNotificationMessage:(NSString *)title
                       subTitle:(NSString *)subTitle
                      iconImage:(NSString *)iconImage
                 viewController:(UIViewController *)viewController
                       callback:(void (^)())callback
                  typeOfMessage:(BoatdayNotificationMessageType)typeOfMessage;
@end
