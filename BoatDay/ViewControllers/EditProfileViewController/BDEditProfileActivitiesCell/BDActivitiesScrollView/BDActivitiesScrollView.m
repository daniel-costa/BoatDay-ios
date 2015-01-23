//
//  BDActivitiesScrollView.m
//  BoatDay
//
//  Created by Diogo Nunes on 17/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDActivitiesScrollView.h"

@implementation BDActivitiesScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self superview]touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self superview]touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self superview]touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self superview]touchesEnded:touches withEvent:event];
}

@end
