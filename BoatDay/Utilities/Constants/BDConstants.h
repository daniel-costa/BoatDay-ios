//
//  BDConstants.h
//
//  Created by Diogo Nunes.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#define weakify(VAR) \
autoreleasepool {} \
__weak __typeof(VAR) VAR ## _weak_ = (VAR)

#define strongify(VAR) \
autoreleasepool {} \
__strong __typeof(VAR) VAR = VAR ## _weak_

typedef void (^SimpleBooleanBlock)(BOOL response);

typedef NS_ENUM(NSInteger, ProfileType) {
    
    ProfileTypeSelf = 0,
    ProfileTypeOther
    
};

typedef NS_ENUM(NSInteger, SideMenu) {
    SideMenuProfileHeader = 0,
    SideMenuNotificationBar,
    SidemenuFactBar,
    SideMenuHome,
    SideMenuFindABoatDay,
    SideMenuMyProfile,
    SideMenuMyEvents,
    SideMenuNotifications,
    SideMenuHostRegistration,
    SideMenuMyBoats,
    SideMenuEmergencyBoatTowing,
    SideMenuSettings,
    SideMenuAboutUs
    
};


typedef NS_ENUM(NSInteger, CertificationStatus) {
    
    CertificationStatusNone = -1,
    CertificationStatusDenied = 0,
    CertificationStatusApproved = 1,
    CertificationStatusPending = 2,
    CertificationStatusInactive = 3
    
};

typedef NS_ENUM(NSInteger, BoatStatus) {
    
    BoatStatusNotSubmited = -1,
    BoatStatusDenied = 0,
    BoatStatusApproved = 1,
    BoatStatusPending = 2,
    BoatStatusInactive = 3
    
};

typedef NS_ENUM(NSInteger, EventStatus) {
    
    EventStatusNotSubmited = -1,
    EventStatusDenied = 0,
    EventStatusApproved = 1,
    EventStatusPending = 2,
    EventStatusCanceled = 3
    
};

typedef NS_ENUM(NSInteger, FindABoatTab) {
    
    FindABoatTabEvents = 0,
    FindABoatTabMap,
    FindABoatTabCalendar
    
};

typedef NS_ENUM(NSInteger, EventProfileTab) {
    
    EventProfileTabDetails = 0,
    EventProfileTabGuests,
    EventProfileTabWall
    
};

typedef NS_ENUM(NSInteger, EventPermissions) {
    
    EventPermissionsNoDrinking = 0,
    EventPermissionsNoSmoking,
    EventPermissionsFamiliesWelcome
    
};

typedef NS_ENUM(NSInteger, NotificationType) {
    
    NotificationTypeBoatApproved = 0,
    NotificationTypeBoatRejected = 1,
    NotificationTypeSeatRequest = 2,
    NotificationTypeRequestApproved = 3,
    NotificationTypeRequestRejected = 4,
    NotificationTypeUserCertificationApproved = 5,
    NotificationTypeUserCertificationRejected = 6,
    NotificationTypeNewChatMessage = 7,
    NotificationTypeNewEventInvitation = 8,
    NotificationTypeRemovedFromAnEvent = 9,
    NotificationTypeEventRemoved = 10,
    NotificationTypeNewReview = 11,
    NotificationTypeHostRegistrationApproved = 12,
    NotificationTypeHostRegistrationRejected = 13,
    NotificationTypeSeatRequestCanceledByUser = 14,
    NotificationTypePaymentReminder = 15,
    NotificationTypeMerchantApproved = 16,
    NotificationTypeMerchantDeclined = 17,
    NotificationTypeEventEnded = 18,
    NotificationTypeEventWillStartIn48H = 19,
    NotificationTypeEventInvitationRemoved = 20,
    NotificationTypeFinalizeContribution = 21

    
};

typedef NS_ENUM(NSInteger, SeatRequestStatus) {
    
    SeatRequestStatusPending = 0,
    SeatRequestStatusAccepted,
    SeatRequestStatusRejected
    
};

typedef NS_ENUM(NSInteger, HostRegistrationStatus) {
    
    HostRegistrationStatusNone = -1,
    HostRegistrationStatusPending = 2,
    HostRegistrationStatusAccepted = 1,
    HostRegistrationStatusDenied = 0,
    HostRegistrationStatusInactive = 3
    
};

typedef NS_ENUM(NSInteger, PaymentInfoDestination) {
    
    PaymentInfoDestinationBank = 0,
    PaymentInfoDestinationEmail,
    PaymentInfoDestinationPhoneNumber
    
};

