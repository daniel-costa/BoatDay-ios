//
//  User.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic facebookID;
@dynamic aboutMe;
@dynamic birthday;
@dynamic firstName;
@dynamic lastName;
@dynamic fullName;
@dynamic pictures;
@dynamic city;
@dynamic state;
@dynamic country;
@dynamic activities;
@dynamic reviews;
@dynamic friendsFacebookID;
@dynamic selectedPictureIndex;
@dynamic firstLineAddress;
@dynamic zipCode;
@dynamic phoneNumber;
@dynamic hostRegistration;
@dynamic braintreePaymentToken;
@dynamic braintreeCustomerId;
@dynamic deleted;

// Return the current user
+ (User *)currentUser {
    return (User *)[PFUser currentUser];
}

// Return a full location string
- (NSString *)fullLocation {
    
    NSMutableArray *cityCountryArray = [[NSMutableArray alloc] init];
    
    if (![NSString isStringEmpty:self.city]) {
        [cityCountryArray addObject:[self.city capitalizedString]];
    }
    
    if (![NSString isStringEmpty:self.country]) {
        [cityCountryArray addObject:[self.country capitalizedString]];
    }
    
    return [cityCountryArray componentsJoinedByString:@", "];
    
}

// Return a full location string
- (NSString *)shortName {
    return [NSString stringWithFormat:@"%@ %@.", [self.firstName capitalizedString], [[self.lastName substringToIndex:1] uppercaseString]];
}

- (PFObject *)copyShallow {
    PFObject *clone = [PFObject objectWithoutDataWithClassName:self.parseClassName
                                                      objectId:self.objectId];
    NSArray *keys = [self allKeys];
    for (NSString *key in keys) {
        
        clone[key] = self[key];
    }
    return clone;
}

- (void)resetValuesToObject:(PFObject*)oldValue {
    
    NSArray *keys = [self allKeys];
    for (NSString *key in keys) {

        if ([[oldValue allKeys] containsObject:key]) {
            self[key] = oldValue[key];
        }
        else {
            self[key] = [NSNull null];
        }
        
    }
    
}

- (BOOL)isEqual:(User *)other {
    
    return [other.objectId isEqualToString:self.objectId];
}

- (BOOL)hasEventsGoingOn {
    
    PFQuery *eventQuery = [Event query];
    [eventQuery includeKey:@"user"];
    [eventQuery includeKey:@"boat"];
    [eventQuery whereKey:@"startsAt" greaterThan:[NSDate date]];
    [eventQuery whereKey:@"host" equalTo:[User currentUser]];
    [eventQuery whereKey:@"deleted" notEqualTo:@(YES)];
    
    PFQuery *attendingQuery = [Event query];
    [attendingQuery whereKey:@"startsAt" greaterThan:[NSDate date]];
    [attendingQuery whereKey:@"deleted" notEqualTo:@(YES)];
    
    PFQuery *attendingSeatRequestQuery = [SeatRequest query];
    [attendingSeatRequestQuery includeKey:@"event"];
    [attendingSeatRequestQuery includeKey:@"event.user"];
    [attendingSeatRequestQuery includeKey:@"event.boat"];
    [attendingSeatRequestQuery whereKey:@"event" matchesQuery:attendingQuery];
    [attendingSeatRequestQuery whereKey:@"user" equalTo:self];
    [attendingSeatRequestQuery whereKey:@"status" equalTo:@(SeatRequestStatusAccepted)];
    [attendingSeatRequestQuery whereKey:@"deleted" notEqualTo:@(YES)];

    return ([eventQuery countObjects] + [attendingSeatRequestQuery countObjects]) > 0;
}


@end
