//
//  BDPlaceholderView.m
//
//  Created by Diogo Nunes on 9/16/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import "BDPlaceholderView.h"

@interface BDPlaceholderView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation BDPlaceholderView

- (void)awakeFromNib {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel.font = [UIFont quattroCentoBoldFontWithSize:16.0];
    self.titleLabel.textColor = [UIColor greenBoatDay];
    
    self.messageLabel.font = [UIFont quattroCentoRegularFontWithSize:13.0];
    self.messageLabel.textColor = [UIColor grayBoatDay];
    
}

- (void) setTitle:(NSString*)title andMessage:(NSString*)message {

    self.titleLabel.text = title;
    self.messageLabel.text = message;
    
    [self.messageLabel sizeToFit];
    
    setFrameX(self.messageLabel, (self.frame.size.width - self.messageLabel.frame.size.width) / 2.0);
    
}

@end

