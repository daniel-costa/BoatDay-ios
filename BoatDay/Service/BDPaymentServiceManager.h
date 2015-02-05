//
//  BDPaymentServiceManager.h
//
//  Created by Diogo Nunes on 9/19/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class User;

@interface BDPaymentServiceManager : NSObject

+ (BDPaymentServiceManager *)sharedManager;

#pragma mark - Methods

- (void)chargeCancellationFeeWithRequestID:(NSString*)seatRequestID
                              sessionToken:(NSString*)sessionToken
                              paymentToken:(NSString*)paymentToken
                                merchantID:(NSString*)merchantId
                                    amount:(NSNumber*)amount
                                 withBlock:(void (^)(BOOL success, NSError *error))block;

- (void)getClientTokenWithCustomerID:(NSString*)customerID
                           withBlock:(void (^)(NSString *clientToken, NSError *error))block;

- (void)addCreditCardWithUserId:(NSString*)userID
                          nonce:(NSString*)nonce
                   sessionToken:(NSString*)sessionToken
                      withBlock:(void (^)(BOOL success, NSError *error))block;

- (void)chargeContributionWithRequestID:(NSString*)seatRequestID
                           sessionToken:(NSString*)sessionToken
                           paymentToken:(NSString*)paymentToken
                             merchantID:(NSString*)merchantId
                                 amount:(NSString*)amount
                              withBlock:(void (^)(BOOL success, NSString *error))block;

- (void)createMerchantWithUser:(User*)user
        paymentInfoDestination:(PaymentInfoDestination)paymentInfoDestination
            hostRegistrationID:(NSString*)hostRegistrationID
                 accountNumber:(NSString*)accountNumber
                 routingNumber:(NSString*)routingNumber
                         email:(NSString*)email
                   phoneNumber:(NSString*)phoneNumber
                  businessName:(NSString*)businessName
                         taxID:(NSString*)taxID
             lastFourSSNDigits:(NSString*)lastFourSSNDigits
                       address:(NSString*)address
                        region:(NSString*)region
                    postalCode:(NSString*)postalCode
       termsOfServiceAgreement:(BOOL)termsOfServiceAgreement
                     withBlock:(void (^)(BOOL success, NSString *error))block;

- (void)updateMerchantWithUser:(User*)user
                    merchantId:(NSString*)merchantId
        paymentInfoDestination:(PaymentInfoDestination)paymentInfoDestination
            hostRegistrationID:(NSString*)hostRegistrationID
                 accountNumber:(NSString*)accountNumber
                 routingNumber:(NSString*)routingNumber
                         email:(NSString*)email
                   phoneNumber:(NSString*)phoneNumber
                  businessName:(NSString*)businessName
                         taxID:(NSString*)taxID
             lastFourSSNDigits:(NSString*)lastFourSSNDigits
                       address:(NSString*)address
                        region:(NSString*)region
                    postalCode:(NSString*)postalCode
       termsOfServiceAgreement:(BOOL)termsOfServiceAgreement
                     withBlock:(void (^)(BOOL success, NSString *error))block;


@end
