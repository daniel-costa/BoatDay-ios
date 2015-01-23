//
//  NSDate+Extensions.h
//
//  Created by Diogo Nunes on 18/09/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

+ (NSString *)timeAgoStringFromTimeIntervail:(NSDate*)date;

+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate;

- (BOOL)isSameDay:(NSDate*)date;

- (NSString*)timeLeftSinceDate:(NSDate*)date;

@end
