//
//  NSNumberFormatter+AppNumberFormatter.h
//
//  Created by Diogo Nunes on 27/05/14.
//  Copyright (c) 2014 Diogo Nunes. All rights reserved.
//

#import "NSNumberFormatter+AppNumberFormatter.h"

@implementation NSNumberFormatter (AppNumberFormatter)

+ (NSNumberFormatter*)valuesNumberFormatter {

    static dispatch_once_t onceMark;
    static NSNumberFormatter *formatterValues = nil;
    
    dispatch_once(&onceMark, ^{
        
        formatterValues = [[NSNumberFormatter alloc] init];
        [formatterValues setMinimumIntegerDigits:1];
        [formatterValues setRoundingMode:NSNumberFormatterRoundHalfEven];
        [formatterValues setDecimalSeparator:@"."];
        [formatterValues setUsesSignificantDigits:YES];
        [formatterValues setMaximumSignificantDigits:2];
        [formatterValues setMaximumFractionDigits:3];
        [formatterValues setMinimumFractionDigits:0];
        
    });
    
    return formatterValues;
    
}

+ (NSNumberFormatter*)percentNumberFormatter {
    
    static dispatch_once_t onceMark;
    static NSNumberFormatter *formatterPercent = nil;
    
    dispatch_once(&onceMark, ^{
        
        formatterPercent = [[NSNumberFormatter alloc] init];
        [formatterPercent setMaximumFractionDigits:0];
        [formatterPercent setMinimumFractionDigits:0];
        [formatterPercent setMinimumIntegerDigits:1];
        [formatterPercent setMaximumIntegerDigits:3];
        [formatterPercent setRoundingMode:NSNumberFormatterRoundHalfEven];
        
    });
    return formatterPercent;
    
}

+ (NSNumberFormatter*)reportRowValuesNumberFormatter {
    
    static dispatch_once_t onceMark;
    static NSNumberFormatter *formatterValues = nil;
    
    dispatch_once(&onceMark, ^{
        
        formatterValues = [[NSNumberFormatter alloc] init];
        [formatterValues setMinimumIntegerDigits:1];
        [formatterValues setRoundingMode:NSNumberFormatterRoundHalfEven];
        [formatterValues setDecimalSeparator:@"."];
        [formatterValues setUsesSignificantDigits:YES];
        [formatterValues setMaximumSignificantDigits:6];
        [formatterValues setMinimumSignificantDigits:3];
        [formatterValues setMaximumFractionDigits:3];
        [formatterValues setMinimumFractionDigits:0];
        
    });
    
    return formatterValues;
    
}





@end
