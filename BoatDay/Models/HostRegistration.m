//
//  HostRegistration.m
//  BoatDay
//
//  Created by Diogo Nunes on 24/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "HostRegistration.h"

@implementation HostRegistration

@dynamic user;
@dynamic status;
@dynamic merchantMessage;
@dynamic merchantId;
@dynamic merchantStatus;
@dynamic rejectionMessage;
@dynamic driversLicenseImage;
@dynamic deleted;

+ (NSString *)parseClassName {

    return @"HostRegistration";
}

@end
