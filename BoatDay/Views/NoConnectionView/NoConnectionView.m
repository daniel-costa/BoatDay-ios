//
//  NoConnectionView.m
//
//  Created by Diogo Nunes on 9/16/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import "NoConnectionView.h"

@interface NoConnectionView ()

- (IBAction)buttonDown:(id)sender;
- (IBAction)buttonUp:(id)sender;

@end

@implementation NoConnectionView

- (void)awakeFromNib {
    
   // self.backgroundColor = [UIColor grayBackgroundNReceitas];
    
    /*
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.messageView.bounds];
    self.messageView.layer.masksToBounds = NO;
    self.messageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.messageView.layer.shadowOffset = CGSizeMake(0.0f, 0.1f);
    self.messageView.layer.shadowOpacity = 0.3f;
    self.messageView.layer.shadowPath = shadowPath.CGPath;
    */
    
    self.messageLabel.text = NSLocalizedString(@"KEY_NO_CONNECTION_MESSAGE", nil);
    self.messageLabel.font = [UIFont abelFontWithSize:18.0];
    self.messageLabel.textColor = [UIColor greenBoatDay];
    self.messageLabel.highlightedTextColor = [UIColor whiteColor];
    
    self.verticalScrollView.delegate = self;
    self.horizontalScrollView.delegate = self;
    self.verticalScrollView.pagingEnabled = YES;
    self.horizontalScrollView.pagingEnabled = YES;
    
    [self.horizontalScrollView addSubview:self.messageView];
    [self.verticalScrollView addSubview:self.horizontalScrollView];
 
    self.verticalScrollView.delaysContentTouches = NO;
    
    [self.messageButton setImage:[UIImage imageNamed:@"events_nophoto_logo"] forState:UIControlStateNormal];
    [self.messageButton setImage:[UIImage imageNamed:@"events_nophoto_logo"] forState:UIControlStateHighlighted];
    self.backgroundColor = [UIColor whiteColor];
    
}

- (void) layoutSubviews {

    self.verticalScrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 2);
    self.verticalScrollView.contentOffset = CGPointMake(0.0, 0.0);
    self.horizontalScrollView.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
    self.horizontalScrollView.contentOffset = CGPointMake(self.frame.size.width, 0.0);
    self.messageView.frame = CGRectMake(self.frame.size.width, 0.0, self.messageView.frame.size.width, self.messageView.frame.size.height);
    self.horizontalScrollView.frame = CGRectMake(0.0, 0.0, self.horizontalScrollView.frame.size.width, self.horizontalScrollView.frame.size.height);

    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

    if (self.horizontalScrollView == scrollView) {
        if (scrollView.contentOffset.x == 0 || scrollView.contentOffset.x == self.frame.size.width*2) {
            //[self messageButtonPressed:self];
        }
        
    }
    
    if (self.verticalScrollView == scrollView) {
        if (scrollView.contentOffset.y == self.frame.size.height) {
            //[self messageButtonPressed:self];
        }
    }

}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView.contentOffset.y < - 30.0) {
      
        [UIView hideViewAnimated:self.messageView withAlpha:YES duration:0.3 andScale:NO];
        
        [self performBlock:^{
            
            if ([self.delegate respondsToSelector:@selector(refreshViewFromNoConnectionView)]) {
                [self.delegate refreshViewFromNoConnectionView];
            }
            
        } afterDelay:0.3];
    }
    
}

- (IBAction)messageButtonPressed:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(refreshViewFromNoConnectionView)]) {
        [self.delegate refreshViewFromNoConnectionView];
    }
    
}

- (IBAction)buttonDown:(id)sender {
    
    //[self.messageLabel setHighlighted:YES];
    
}

- (IBAction)buttonUp:(id)sender {
    
   // [self.messageLabel setHighlighted:NO];

}

@end
