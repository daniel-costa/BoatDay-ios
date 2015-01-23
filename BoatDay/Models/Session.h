//
//
//  Created by Diogo Nunes on 9/19/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@class User;
@class HostRegistration;

@interface Session : NSObject

// User Data

@property (strong, nonatomic) NSMutableArray *myCertifications;

@property (nonatomic) BOOL dataWasFechted;

@property (strong, nonatomic) HostRegistration *hostRegistration;

// App data

@property (nonatomic) SideMenu selectedSideMenu;

@property (strong, nonatomic) NSMutableDictionary *activitiesByTypes;

@property (copy, nonatomic) NSArray *allActivities;

@property (copy, nonatomic) NSArray *certificationTypes;

// Timeframe Window

@property (nonatomic) NSInteger cancelRequestTimeframeWindowHours;

@property (nonatomic) NSInteger finalizeContributionTimeframeWindowHours;

+ (Session *)sharedSession;

@property (NS_NONATOMIC_IOSONLY, getter=getCertificationsApproved, readonly) NSInteger certificationsApproved;

- (void) logOutUser;

- (void) getUserRelationshipsData;

- (void) updateUserData;

- (NSInteger)averageReviewsStarsWithReviews:(NSArray*)reviews;

@end
