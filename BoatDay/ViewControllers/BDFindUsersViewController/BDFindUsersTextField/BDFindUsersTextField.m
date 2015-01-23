//
//  BDFindUsersTextField.m
//  BoatDay
//
//  Created by Diogo Nunes on 19/08/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindUsersTextField.h"

@implementation BDFindUsersTextField

- (void)drawPlaceholderInRect:(CGRect)rect {
    
    UIColor *colour = RGB(179, 179, 180);
    
    if ([self.placeholder respondsToSelector:@selector(drawInRect:withAttributes:)]) {
        
        // iOS7 and later
        NSDictionary *attributes = @{NSForegroundColorAttributeName: colour,
                                     NSFontAttributeName: [UIFont abelFontWithSize:16.0]};
        
        CGRect boundingRect = [self.placeholder boundingRectWithSize:rect.size options:0 attributes:attributes context:nil];
        
        [self.placeholder drawAtPoint:CGPointMake(0, (rect.size.height/2)-boundingRect.size.height/2) withAttributes:attributes];
        
    }
    
}

@end
