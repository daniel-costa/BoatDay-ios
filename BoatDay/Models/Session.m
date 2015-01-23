//
//
//  Created by Diogo Nunes on 10/22/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import "Session.h"

@interface Session ()

@end

@implementation Session

#pragma mark - Class Methods

+ (Session *)sharedSession
{
    static Session *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[Session alloc] init];
        sharedInstance.dataWasFechted = NO;
        sharedInstance.finalizeContributionTimeframeWindowHours = 24; // default  value
        sharedInstance.cancelRequestTimeframeWindowHours = 24; // default  value
        
    });
    
    return sharedInstance;
}

- (NSMutableDictionary *)activitiesByTypes {
    
    if (!_activitiesByTypes)  {
        _activitiesByTypes = [[NSMutableDictionary alloc] init];
    }
    return _activitiesByTypes;
}

- (NSInteger)getCertificationsApproved {
    
    NSInteger result = 0;
    
    for (Certification *certification in self.myCertifications) {
        
        if ([certification.status integerValue] == CertificationStatusApproved) {
            result++;
        }
    }
    
    return result;
    
}

#pragma mark - Reviews

- (NSInteger)averageReviewsStarsWithReviews:(NSArray*)reviews {
    
    if (reviews && ![reviews isEqual:[NSNull null]]) {
        
        CGFloat averageStars = 0.0;
        
        for (Review *review in reviews) {
            
            if (![review isEqual:[NSNull null]]) {
                averageStars += review.stars.integerValue;
            }
        }
        
        if (reviews.count) {
            averageStars /= reviews.count;
        }
        
        return (NSInteger)averageStars;
    }
    
    return 0;
    
}

#pragma mark - User Methods

- (void) logOutUser {
    
    [PFUser logOut];
    
    self.myCertifications = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fb_access_token"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fb_expiration_date"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

#pragma mark - RAC Signals

- (RACSignal *) getActivitiesSignal {
    
    RACSignal *fileSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {
        
        PFQuery *query = [ActivityType query];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *activityTypes, NSError *error) {
            
            if (!error) {
                
                PFQuery *query = [Activity query];
                [query includeKey:@"type"];
                
                [query orderByAscending:@"order"];
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    if (!error) {
                        
                        [Session sharedSession].allActivities = objects;
                        
                        // Populate Activ1ities Dictionary to facilitate table display
                        [self populateActivitiesDictionaryWithTypes:activityTypes andActivities:objects];
                        
                        [subscriber sendNext:nil];
                        [subscriber sendCompleted];
                        
                    } else {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:self];
                        
                    }
                    
                }];
                
            } else {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:self];
                
            }
            
        }];
        
    }];
    
    return fileSignal;
}

- (void) populateActivitiesDictionaryWithTypes:(NSArray *)types andActivities:(NSArray *)activities {
    
    [Session sharedSession].activitiesByTypes = nil;
    
    // Create arrays for each Type with name as dictionary Key and add activities to each type
    for (Activity *activity in activities) {
        
        NSMutableArray *typeArray = [Session sharedSession].activitiesByTypes[activity.type.name];
        
        // If we dont have created the array, we must create a new one
        if (!typeArray) {
            
            // Create new array
            typeArray = [[NSMutableArray alloc] init];
            
            // store activities in session
            [Session sharedSession].activitiesByTypes[activity.type.name] = typeArray;
        }
        
        // Add the object to his Activity Type array
        [typeArray addObject:activity];
        
    }
    
}

- (RACSignal *) getUserCertificationsSignal {
    
    RACSignal *fileSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {
        
        if ([Session sharedSession].myCertifications) {
            
            [subscriber sendNext:[Session sharedSession].myCertifications];
            [subscriber sendCompleted];
            
        }
        else {
            
            PFQuery *query = [Certification query];
            [query includeKey:@"type"];
            [query includeKey:@"user"];
            
            [query whereKey:@"user" equalTo:[User currentUser]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *certifications, NSError *error) {
                
                if (!error) {
                    
                    [subscriber sendNext:certifications];
                    [subscriber sendCompleted];
                    
                } else {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:self];
                    
                }
                
            }];
            
        }
        
    }];
    
    return fileSignal;
    
}

- (RACSignal *) getUserHostRegistration {
    
    RACSignal *fileSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {
        
        PFQuery *query = [HostRegistration query];
        [query whereKey:@"user" equalTo:[User currentUser]];
        [query whereKey:@"deleted" notEqualTo:@(YES)];

        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            [subscriber sendNext:(HostRegistration*)object];
            [subscriber sendCompleted];
            
        }];
        
    }];
    
    return fileSignal;
    
}

- (RACSignal *) getTimeframeWindows {
    
    RACSignal *fileSignal = [RACSignal startEagerlyWithScheduler:[RACScheduler scheduler] block:^(id<RACSubscriber> subscriber) {
        
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            
            if (error) {
                config = [PFConfig currentConfig];
            }
            
            [subscriber sendNext:config];
            [subscriber sendCompleted];
            
        }];
        
    }];
    
    return fileSignal;
    
}

- (void) getUserRelationshipsData {
    
    [self getUserRelationshipsDataWithPostNotificationName:@"userLoggedIn"];
    
}

- (void) updateUserData {
    
    [self getUserRelationshipsDataWithPostNotificationName:nil];
    
}

- (void) getUserRelationshipsDataWithPostNotificationName:(NSString*)postNotificationName {
    
    if ([User currentUser]) {
        
        [[User currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (!object) {
                
                [PFUser logOut];
                [Session sharedSession].hostRegistration = nil;
                [User currentUser].hostRegistration = nil;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:self];
                
                return;
                
            } else {
                
                [self runUserUpdateSignalsWithNotificationName:postNotificationName];
                
            }
            
        }];
        
    }
    
}

- (void) runUserUpdateSignalsWithNotificationName:(NSString*)postNotificationName {
    
    RACSignal *userCertifications = [self getUserCertificationsSignal];
    RACSignal *activitiesSignal = [self getActivitiesSignal];
    RACSignal *hostRegistrationSignal = [self getUserHostRegistration];
    RACSignal *timeframeSignal = [self getTimeframeWindows];
    
    [[RACSignal
      combineLatest:@[userCertifications, activitiesSignal, hostRegistrationSignal, timeframeSignal]
      reduce:^id(NSArray *certifications, NSArray* activities, HostRegistration* hostRegistration, PFConfig *configObject) {
          
          [Session sharedSession].myCertifications = [NSMutableArray arrayWithArray:certifications];
          
          [Session sharedSession].hostRegistration = hostRegistration;
          
          [User currentUser].hostRegistration = hostRegistration;
          
          self.cancelRequestTimeframeWindowHours = [configObject[@"cancelRequestTimeInHours"] integerValue];
          
          self.finalizeContributionTimeframeWindowHours = [configObject[@"finalizeContributionTimeInHours"] integerValue];
          
          self.dataWasFechted = YES;
          
          return nil;
          
      }] subscribeCompleted:^{
          
          dispatch_async(dispatch_get_main_queue(), ^{
              
              [[NSNotificationCenter defaultCenter] postNotificationName:@"merchantApproved" object:self];
              
              if (postNotificationName) {
                  
                  [[NSNotificationCenter defaultCenter] postNotificationName:postNotificationName object:self];
                  
              }
          });
          
      }];
    
}

@end
