//
//  NSDateFormatter+AppDateFormatter.m
//
//  Created by Diogo Nunes.
//  Copyright (c) 2014 Diogo Nunes. All rights reserved.
//

#import "NSDateFormatter+AppDateFormatter.h"

@implementation NSDateFormatter (AppDateFormatter)

+ (NSDateFormatter *)birthdayDateFormatter {
    
    static dispatch_once_t onceMark;
    static NSDateFormatter *dateFormatter = nil;
    
    dispatch_once(&onceMark, ^{
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    });
    
    return dateFormatter;
}

+ (NSDateFormatter *)reviewsDateFormatter {
    
    static dispatch_once_t onceMark;
    static NSDateFormatter *dateFormatter = nil;
    
    dispatch_once(&onceMark, ^{
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mma"];
    });
    
    return dateFormatter;
}

+ (NSDateFormatter *)notificationMessageDateFormatter {
    
    static dispatch_once_t onceMark;
    static NSDateFormatter *dateFormatter = nil;
    
    dispatch_once(&onceMark, ^{
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mma - MM/dd/yyyy"];
    });
    
    return dateFormatter;
}

+ (NSDateFormatter *)eventsCardDateFormatter {
    
    static dispatch_once_t onceMark;
    static NSDateFormatter *dateFormatter = nil;
    
    dispatch_once(&onceMark, ^{
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE MM/dd/yyyy hh:mma"];
    });
    
    return dateFormatter;
}

+ (NSDateFormatter *)eventProfileDateFormatter {
    
    static dispatch_once_t onceMark;
    static NSDateFormatter *dateFormatter = nil;
    
    dispatch_once(&onceMark, ^{
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mma"];
    });
    
    return dateFormatter;
}


+ (NSDateFormatter *)braintreeBirthdayDateFormatter {
    
    static dispatch_once_t onceMark;
    static NSDateFormatter *dateFormatter = nil;
    
    dispatch_once(&onceMark, ^{
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    });
    
    return dateFormatter;
}


@end
