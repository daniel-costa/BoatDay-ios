//
//  NSString+Additions.h
//  BoatDay
//
//  Created by Diogo Nunes on 31/05/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

+ (BOOL)isStringEmpty:(NSString *)string;

- (BOOL)isValidEmail;

- (BOOL)isNumeric;

@end
