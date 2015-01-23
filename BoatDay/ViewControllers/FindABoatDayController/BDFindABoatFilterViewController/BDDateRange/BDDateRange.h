//
//  BDDateRange.h
//  BoatDay
//
//  Created by Diogo Nunes on 05/08/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDDateRange : NSObject

@property (strong, nonatomic) NSDate *startDate;

@property (strong, nonatomic) NSDate *endDate;

+ (BDDateRange *)rangeForDayContainingDate:(NSDate *)date;

+ (BDDateRange *)rangeForWeekContainingDate:(NSDate *)date;

+ (BDDateRange *)rangeForMonthContainingDate:(NSDate *)date;

+ (BDDateRange *)rangeForYearContainingDate:(NSDate *)date;

@end
