//
//  UIFont+BoatDayFonts.m
//
//  Created by Diogo Nunes.
//  Copyright (c) 2014 Diogo Nunes. All rights reserved.
//

#import "UIFont+AppFonts.h"

@implementation UIFont (AppFonts)

+ (UIFont *)abelFontWithSize:(float)size {
    
    return [UIFont fontWithName:@"Abel-Regular" size:size];
    
}


+ (UIFont *)quattroCentoRegularFontWithSize:(float)size {
    
    return [UIFont fontWithName:@"QuattrocentoSans" size:size];
    
}

+ (UIFont *)quattoCentoItalicFontWithSize:(float)size {
    
    return [UIFont fontWithName:@"QuattrocentoSans-Italic" size:size];
    
}

+ (UIFont *)quattroCentoBoldFontWithSize:(float)size {
    
    return [UIFont fontWithName:@"QuattrocentoSans-Bold" size:size];
    
}
+ (UIFont *)quattoCentoBoldItalicFontWithSize:(float)size {
    
    return [UIFont fontWithName:@"QuattrocentoSans-BoldItalic" size:size];
    
}

@end
