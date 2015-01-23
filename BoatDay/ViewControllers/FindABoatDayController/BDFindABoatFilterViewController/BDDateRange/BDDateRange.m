//
//  BDDateRange.m
//  BoatDay
//
//  Created by Diogo Nunes on 05/08/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDDateRange.h"

@implementation BDDateRange

+ (NSCalendar *)calendar {
    
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return gregorian;
}

+ (NSDateComponents *)singleComponentOfUnit:(NSCalendarUnit)unit {
    
    NSDateComponents * component = [[NSDateComponents alloc] init];
    
    switch (unit) {
            
        case NSDayCalendarUnit:
            [component setDay:1];
            break;
        case NSWeekCalendarUnit:
            [component setWeekOfMonth:1];
            break;
        case NSMonthCalendarUnit:
            [component setMonth:1];
            break;
        case NSYearCalendarUnit:
            [component setYear:1];
            break;
        default:
            break;
    }
    
    return component;
}

+ (BDDateRange *)rangeForUnit:(NSCalendarUnit)unit surroundingDate:(NSDate *)date {
    
    BDDateRange * range = [[self alloc] init];
    
    // start of the period
    NSDate * firstDay;
    [[self calendar] rangeOfUnit:unit
                       startDate:&firstDay
                        interval:0
                         forDate:date];
    [range setStartDate:firstDay];
    
    // end of the period
    [range setEndDate:[[self calendar]
                       dateByAddingComponents:[self singleComponentOfUnit:unit]
                       toDate:firstDay
                       options:0]];
    
    return range;
}

+ (BDDateRange *)rangeForDayContainingDate:(NSDate *)date {
    return [self rangeForUnit:NSDayCalendarUnit surroundingDate:date];
}

+ (BDDateRange *)rangeForWeekContainingDate:(NSDate *)date {
    return [self rangeForUnit:NSWeekCalendarUnit surroundingDate:date];
}

+ (BDDateRange *)rangeForMonthContainingDate:(NSDate *)date {
    return [self rangeForUnit:NSMonthCalendarUnit surroundingDate:date];
}

+ (BDDateRange *)rangeForYearContainingDate:(NSDate *)date {
    return [self rangeForUnit:NSYearCalendarUnit surroundingDate:date];
}

@end
