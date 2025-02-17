//
//  NSString+Additions.m
//  BoatDay
//
//  Created by Diogo Nunes on 31/05/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (BOOL)isStringEmpty:(NSString *)string {

    if([string length] == 0) { //string is empty or nil
        return YES;
    }
    
    if(![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        //string is all whitespace
        return YES;
    }
    
    return NO;
    
}

- (BOOL) isValidEmail {
    
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
    
}

- (BOOL)isNumeric{
    
    BOOL isValid=NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:self];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isValid;
    
}

@end
