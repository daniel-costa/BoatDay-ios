//
//  NSNumberFormatter+AppNumberFormatter.h
//
//  Created by Diogo Nunes.
//  Copyright (c) 2014 Diogo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumberFormatter (AppNumberFormatter)

+ (NSNumberFormatter*)valuesNumberFormatter;

+ (NSNumberFormatter*)percentNumberFormatter;

+ (NSNumberFormatter*)reportRowValuesNumberFormatter;

@end
