//
//  BDNotificationsCell.m
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDNotificationsCell.h"

@implementation BDNotificationsCell

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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

//    [self setCellColor:[UIColor greenBoatDay]];
    
    self.messageLabel.textColor = [UIColor darkGreenBoatDay];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.font = [UIFont quattroCentoRegularFontWithSize:15.0];

    self.detailMessageLabel.textColor = [UIColor grayBoatDay];
    self.detailMessageLabel.backgroundColor = [UIColor clearColor];
    self.detailMessageLabel.font = [UIFont quattroCentoRegularFontWithSize:12.0];
    
    self.dateLabel.textColor = [UIColor yellowBoatDay];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.font = [UIFont quattroCentoRegularFontWithSize:10.0];

}

- (void)updateLayoutWithNotification:(Notification*)notification {

    NSString *message = @"";
//    NSString *detailMessage = @"";
    NSString *date = @"";

    NSDateFormatter *dateFormatter = [NSDateFormatter notificationMessageDateFormatter];
    NSString *createdAt = [dateFormatter stringFromDate:notification.createdAt];
    date = createdAt;
    
    NotificationType type = [notification.notificationType integerValue];
    
    switch (type) {
        case NotificationTypeBoatApproved:
        {
            message = NSLocalizedString(@"notifications.type.boatApproved", nil);
//            detailMessage = notification.boat.name;
        }
            break;
        case NotificationTypeBoatRejected:
        {
            message = NSLocalizedString(@"notifications.type.boatRejected", nil);
//            detailMessage = notification.boat.name;
        }
            break;
        case NotificationTypeSeatRequest:
        {
            NSInteger numberOfSeats = [notification.seatRequest.numberOfSeats integerValue];
            
            if (numberOfSeats == 1) {
                message = [NSString stringWithFormat:NSLocalizedString(@"notifications.type.seatRequestSingle", nil), notification.seatRequest.numberOfSeats];
            }
            else {
            message = [NSString stringWithFormat:NSLocalizedString(@"notifications.type.seatRequest", nil), notification.seatRequest.numberOfSeats];
            }
            
//            detailMessage = notification.seatRequest.event.name;
            
        }
            break;
        case NotificationTypeRequestApproved:
        {
            message = NSLocalizedString(@"notifications.type.seatRequestApproved", nil);
//            detailMessage = notification.event.name;
        }
            break;
        case NotificationTypeRequestRejected:
        {
            message = NSLocalizedString(@"notifications.type.seatRequestRejected", nil);
//            detailMessage = notification.event.name;
        }
            break;
        case NotificationTypeUserCertificationApproved:
        {
            message = NSLocalizedString(@"notifications.type.certificationApproved", nil);
//            detailMessage = notification.certification.type.name;
        }
            break;
        case NotificationTypeUserCertificationRejected:
        {
            message = NSLocalizedString(@"notifications.type.certificationRejected", nil);
//            detailMessage = notification.certification.type.name;
        }
            break;
        case NotificationTypeNewChatMessage:
        {
            message = NSLocalizedString(@"notifications.type.newChatMessage", nil);
//            detailMessage = notification.event.name;
        }
            break;
        case NotificationTypeNewEventInvitation:
        {
            message = NSLocalizedString(@"notifications.type.eventInvitation", nil);
//            detailMessage = notification.event.name;
        }
            break;
        case NotificationTypeRemovedFromAnEvent:
        {
            message = NSLocalizedString(@"notifications.type.userRemovedFromEvent", nil);
//            detailMessage = notification.event.name;
        }
            break;
        case NotificationTypeEventRemoved:
        {
            message = NSLocalizedString(@"notifications.type.eventCanceled", nil);
//            detailMessage = notification.text;
        }
            break;
        case NotificationTypeNewReview:
        {
            message = NSLocalizedString(@"notifications.type.newReview", nil);
//            detailMessage = notification.review.from.shortName;
        }
            break;
        case NotificationTypeHostRegistrationApproved:
        {
            message = NSLocalizedString(@"notifications.type.hostRegistrationApproved", nil);
//            detailMessage = notification.user.shortName;
        }
            break;
        case NotificationTypeHostRegistrationRejected:
        {
            message = NSLocalizedString(@"notifications.type.hostRegistrationRejected", nil);
//            detailMessage = notification.user.shortName;
        }
            break;
        case NotificationTypeSeatRequestCanceledByUser: {
            message = NSLocalizedString(@"notifications.type.seatRequestCanceledByUser", nil);
//            detailMessage = [NSString stringWithFormat:@"Event: %@, User: %@", notification.event.name, notification.seatRequest.user.shortName];
        }
            break;
        case NotificationTypePaymentReminder: {
            message = NSLocalizedString(@"notifications.type.paymentReminder", nil);
//            detailMessage = notification.event.name;
        }
            break;
        case NotificationTypeMerchantApproved: {
            message = NSLocalizedString(@"notifications.type.merchantApproved", nil);
//            detailMessage = notification.user.shortName;
        }
            break;
        case NotificationTypeMerchantDeclined: {
            message = NSLocalizedString(@"notifications.type.merchantRejected", nil);
//            detailMessage = notification.user.shortName;
        }
            break;
        case NotificationTypeEventEnded: {
            message = NSLocalizedString(@"notifications.type.eventEnded", nil);
//            detailMessage = notification.event.name;
        }
            break;
        case NotificationTypeEventWillStartIn48H: {
            message = NSLocalizedString(@"notifications.type.48hoursPriorToEvent", nil);
//            detailMessage = notification.event.name;
        }
            break;
        case NotificationTypeEventInvitationRemoved: {
            message = NSLocalizedString(@"notifications.type.invitationRemoved", nil);
//            detailMessage = notification.event.name;
        }
            break;
        case NotificationTypeFinalizeContribution: {
            message = NSLocalizedString(@"notifications.type.finalizeContribution", nil);
        }
            break;
        default:
            message = @"Notification from BoatDay";
            break;
    }
    
    self.messageLabel.text = message;
    self.detailMessageLabel.text = notification.text;
    self.dateLabel.text = date;
    
    self.detailMessageLabel.numberOfLines = 0;
    [self.detailMessageLabel sizeToFit];
    self.detailMessageLabel.frame = CGRectMake(self.detailMessageLabel.frame.origin.x, self.detailMessageLabel.frame.origin.y, 300, self.detailMessageLabel.frame.size.height);

}

#pragma mark - Private

- (void)changeCellStateHighlighted:(BOOL)highlighted {
    
    if (highlighted) {
        
        [self setCellColor:[UIColor mediumGreenBoatDay]];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.detailMessageLabel.textColor = [UIColor whiteColor];
        self.messageLabel.textColor = [UIColor yellowBoatDay];
        
    } else {
        
        [self setCellColor:[UIColor whiteColor]];
        self.dateLabel.textColor = [UIColor yellowBoatDay];
        self.detailMessageLabel.textColor = [UIColor grayBoatDay];
        self.messageLabel.textColor = [UIColor darkGreenBoatDay];

    }

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


- (void)setCellColor:(UIColor *)color{
    self.contentView.backgroundColor = color;
    self.backgroundColor = color;
}
         
    

@end
