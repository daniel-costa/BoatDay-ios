//
//  DNButtonContainerView.m
//
//  Created by Diogo Nunes on 25/10/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import "DNButtonContainerView.h"

@implementation DNButtonContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isPressed = NO;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    if(!self.isPressed){
        
        self.isPressed = YES;
        
        if ([self.delegate respondsToSelector:@selector(touchedButtonContainerView:)]) {
            
            [self.delegate touchedButtonContainerView:self];
            
        }
        
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint = [touch locationInView:self];
    
    if ([self pointInside:touchPoint withEvent:nil]) {
        
        if(!self.isPressed){
            
            self.isPressed = YES;
            
            if ([self.delegate respondsToSelector:@selector(touchedButtonContainerView:)]) {
                
                [self.delegate touchedButtonContainerView:self];
                
            }
            
        }
        
    }
    else {
        
        if(self.isPressed){
            
            self.isPressed = NO;
            
            [self releaseButton];

        }
        
    }
    
    
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(self.isPressed){
        
        self.isPressed = NO;
        
        UITouch *touch = [touches anyObject];
        
        CGPoint touchPoint = [touch locationInView:self];
        
        if ([self pointInside:touchPoint withEvent:nil]) {
            
            if ([self.delegate respondsToSelector:@selector(pressedButtonContainerView:)]) {
                
                [self.delegate pressedButtonContainerView:self];
                
            }
        }
        
        [self releaseButton];

    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(self.isPressed){
        
        self.isPressed = NO;
        
        [self releaseButton];
        
    }
    
}

- (void) releaseButton {
    
    [self performBlock:^{
        if ([self.delegate respondsToSelector:@selector(releasedButtonContainerView:)]) {
            [self.delegate releasedButtonContainerView:self];
        }
    } afterDelay:0.05];

    /*
    if ([self.delegate respondsToSelector:@selector(releasedButtonContainerView:)]) {
        
        [self.delegate releasedButtonContainerView:self];
        
    }
     */
}

@end
