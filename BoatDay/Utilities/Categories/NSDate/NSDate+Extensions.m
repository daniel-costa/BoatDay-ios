//
//  NSDate+Extensions.m
//
//  Created by Diogo Nunes on 18/09/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import "NSDate+Extensions.h"

@implementation NSDate (Extensions)

#pragma mark - Date Methods

+ (NSString *)timeAgoStringFromTimeIntervail:(NSDate*)date {
    
    int delta = [[NSDate date] timeIntervalSinceDate:date];
    
    NSString * prettyTimestamp;
    
    if (delta < 60) {
        prettyTimestamp = NSLocalizedString(@"just now", @"");
    } else if (delta < 120) {
        prettyTimestamp = NSLocalizedString(@"one minute ago", @"");
    } else if (delta < 3600) {
        prettyTimestamp = [NSString stringWithFormat:NSLocalizedString(@"%d minutes ago", @""), (int) floor(delta/60.0) ];
    } else if (delta < 7200) {
        prettyTimestamp = NSLocalizedString(@"one hour ago", @"");
    } else if (delta < 86400) {
        prettyTimestamp = [NSString stringWithFormat:NSLocalizedString(@"%d hours ago", @""), (int) floor(delta/3600.0) ];
    } else if (delta < ( 86400 * 2 ) ) {
        prettyTimestamp = NSLocalizedString(@"one day ago", @"");
    } else if (delta < ( 86400 * 7 ) ) {
        prettyTimestamp = [NSString stringWithFormat:NSLocalizedString(@"%d days ago", @""), (int) floor(delta/86400.0) ];
    } else {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        
        prettyTimestamp = [NSString stringWithFormat:NSLocalizedString(@"%@", @""), [formatter stringFromDate:date]];
    }
    
    return prettyTimestamp;
}

+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    
    if ([firstDate compare:date] == NSOrderedAscending &&
        [lastDate compare:date] == NSOrderedDescending) {
        
        return YES;
    }
    
    return NO;
    
}

- (BOOL)isSameDay:(NSDate*)date {
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        
        return YES;
    }
    
    return NO;
}

- (NSString*)timeLeftSinceDate:(NSDate*)oldDate {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:
                                    NSCalendarUnitYear|
                                    NSCalendarUnitMonth|
                                    NSCalendarUnitDay|
                                    NSCalendarUnitHour|
                                    NSCalendarUnitMinute
                                               fromDate:oldDate
                                                 toDate:self
                                                options:0];
    
    NSString *yearString = components.year ? [NSString stringWithFormat:@"%ldY ", (long)components.year] : @"";
    NSString *monthString = components.month ? [NSString stringWithFormat:@"%ldM ", (long)components.month] : @"";
    NSString *dayString = components.day ? [NSString stringWithFormat:@"%ldd ", (long)components.day] : @"";
    NSString *hourString = components.hour ? [NSString stringWithFormat:@"%ldh ", (long)components.hour] : @"";
    NSString *minuteString = components.minute ? [NSString stringWithFormat:@"%ldm", (long)components.minute] : @"";
    
    NSString *timeLeft = [NSString stringWithFormat:@"%@%@%@%@%@",
                          yearString,
                          monthString,
                          dayString,
                          hourString,
                          minuteString];
    
    return timeLeft;
    
}



@end
