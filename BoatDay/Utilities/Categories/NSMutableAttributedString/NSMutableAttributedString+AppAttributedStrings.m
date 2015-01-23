//
//  NSMutableAttributedString+AppAttributedStrings.h
//
//  Created by Diogo Nunes on 30/05/14.
//  Copyright (c) 2014  Diogo Nunes . All rights reserved.
//

#import "NSMutableAttributedString+AppAttributedStrings.h"

@implementation NSMutableAttributedString (AppAttributedStrings)

+ (NSMutableAttributedString *)boatDayStringWithText:(NSString* )text font:(UIFont *)font color:(UIColor *)color textAlignment:(NSTextAlignment)textAlignment {
    
    return [self boatDayStringWithText:text font:font color:color kern:-0.6f textAlignment:textAlignment];
    
}

+ (NSMutableAttributedString *)boatDayStringWithText:(NSString* )text font:(UIFont *)font color:(UIColor *)color kern:(CGFloat)kern textAlignment:(NSTextAlignment)textAlignment {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3.0];
    paragraphStyle.alignment = textAlignment;

    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [text length])];
    
    [attributedString addAttribute:NSFontAttributeName
                             value:font
                             range:NSMakeRange(0, [text length])];
    
    [attributedString addAttribute:NSKernAttributeName
                             value:@(kern)
                             range:NSMakeRange(0, [text length])];
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:color
                             range:NSMakeRange(0, [text length])];
    
    return attributedString;
    
}

@end
