//
//  BDSelectDestinationPaymentCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDSelectDestinationPaymentCell.h"

@implementation BDSelectDestinationPaymentCell

+ (NSString *)reuseIdentifier {
    
    return NSStringFromClass([self class]);
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    
    for (UIView *currentView in self.subviews)
    {
        if([currentView isKindOfClass:[UIScrollView class]])
        {
            ((UIScrollView *)currentView).delaysContentTouches = NO;
            break;
        }
    }
    
    self.segmentedControl.selectedSegmentIndex = 0;

    UIFont *font = [UIFont abelFontWithSize:14.0];
    
    NSDictionary *attributes = @{NSFontAttributeName: font};
    [self.segmentedControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    setFrameX(self.venmoView, CGRectGetWidth(self.frame));
    self.venmoView.alpha = 0.0;

    self.bAIndicateLabel.font = [UIFont abelFontWithSize:10.0];
    self.bAIndicateLabel.textColor = [UIColor grayBoatDay];
    
    self.bAAccountNumberLabel.font = [UIFont abelFontWithSize:12.0];
    self.bAAccountNumberLabel.textColor = [UIColor grayBoatDay];
    
    self.bARoutingNumberLabel.font = [UIFont abelFontWithSize:12.0];
    self.bARoutingNumberLabel.textColor = [UIColor grayBoatDay];
    
    self.bAAccountNumberTextField.font = [UIFont abelFontWithSize:17.0];
    self.bAAccountNumberTextField.textColor = [UIColor greenBoatDay];
    
    self.bARoutingNumberTextField.font = [UIFont abelFontWithSize:17.0];
    self.bARoutingNumberTextField.textColor = [UIColor greenBoatDay];
    
    [self.bAAccountNumberTextField setTintColor:[UIColor greenBoatDay]];
    [self.bARoutingNumberTextField setTintColor:[UIColor greenBoatDay]];
    
    self.venmoIndicateLabel.font = [UIFont abelFontWithSize:10.0];
    self.venmoIndicateLabel.textColor = [UIColor grayBoatDay];
    
    self.venmoEmailLabel.font = [UIFont abelFontWithSize:12.0];
    self.venmoEmailLabel.textColor = [UIColor grayBoatDay];
    
    self.venmoPhoneNumberLabel.font = [UIFont abelFontWithSize:12.0];
    self.venmoPhoneNumberLabel.textColor = [UIColor grayBoatDay];
    
    self.venmoEmailTextField.font = [UIFont abelFontWithSize:17.0];
    self.venmoEmailTextField.textColor = [UIColor greenBoatDay];
    
    self.venmoPhoneNumberTextField.font = [UIFont abelFontWithSize:17.0];
    self.venmoPhoneNumberTextField.textColor = [UIColor greenBoatDay];
    
    [self.venmoEmailTextField setTintColor:[UIColor greenBoatDay]];
    [self.venmoPhoneNumberTextField setTintColor:[UIColor greenBoatDay]];

}

#pragma mark - Private

- (void)changeCellStateHighlighted:(BOOL)highlighted {
    
}

- (void)changeCellStateSelected:(BOOL)selected {
    
}

#pragma mark - Overriden Methods

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    [super setHighlighted:highlighted animated:animated];
    
    [self changeCellStateHighlighted:highlighted];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    [self changeCellStateHighlighted:selected];
    
}

#pragma mark - Segmented Control Changes

- (IBAction)segmentedValueChanged:(id)sender {

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: // bank account
        {
            
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 setFrameX(self.bankAccountView, 0.0);
                                 self.bankAccountView.alpha = 1.0;

                                 setFrameX(self.venmoView, CGRectGetWidth(self.frame));
                                 self.venmoView.alpha = 0.0;

                                 
                             }
                             completion:nil];
        }
            break;
        case 1: // venmo
        {
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 setFrameX(self.bankAccountView, -CGRectGetWidth(self.frame));
                                 self.bankAccountView.alpha = 0.0;

                                 setFrameX(self.venmoView, 0.0);
                                 self.venmoView.alpha = 1.0;

                                 
                             }
                             completion:nil];
        }
            break;
        default:
            break;
    }

    if (self.segmentedControlChangeBlock) {
        self.segmentedControlChangeBlock(self.segmentedControl.selectedSegmentIndex);
    }
    
}


@end
