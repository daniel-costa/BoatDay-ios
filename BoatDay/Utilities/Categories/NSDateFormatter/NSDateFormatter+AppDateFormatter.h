//
//  NSDateFormatter+AppDateFormatter.h
//
//  Created by Diogo Nunes.
//  Copyright (c) 2014 Diogo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (AppDateFormatter)

+ (NSDateFormatter *)birthdayDateFormatter;

+ (NSDateFormatter *)reviewsDateFormatter;

+ (NSDateFormatter *)notificationMessageDateFormatter;

+ (NSDateFormatter *)eventsCardDateFormatter;

+ (NSDateFormatter *)eventProfileDateFormatter;

+ (NSDateFormatter *)braintreeBirthdayDateFormatter;

@end
