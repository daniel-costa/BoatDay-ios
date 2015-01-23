//
//  NSMutableAttributedString+AppAttributedStrings.h
//
//  Created by Diogo Nunes on 30/05/14.
//  Copyright (c) 2014  Diogo Nunes . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (AppAttributedStrings)

+ (NSMutableAttributedString *)boatDayStringWithText:(NSString* )text font:(UIFont *)font color:(UIColor *)color textAlignment:(NSTextAlignment)textAlignment;

@end
