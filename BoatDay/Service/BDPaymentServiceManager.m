//
//  BDPaymentServiceManager.m
//
//  Created by Diogo Nunes on 10/22/13.
//  Copyright (c) 2013 Diogo Nunes. All rights reserved.
//

#import "BDPaymentServiceManager.h"

static NSString* const kBaseUrl = @"https://boat-day-payments.herokuapp.com";

@interface BDPaymentServiceManager ()

@end

@implementation BDPaymentServiceManager

#pragma mark - Class Methods

+ (BDPaymentServiceManager *)sharedManager
{
    static BDPaymentServiceManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[BDPaymentServiceManager alloc] init];
        
    });
    
    return sharedInstance;
}

#pragma mark - Methods

- (void)chargeCancellationFeeWithRequestID:(NSString*)seatRequestID
                              sessionToken:(NSString*)sessionToken
                              paymentToken:(NSString*)paymentToken
                                merchantID:(NSString*)merchantId
                                    amount:(NSNumber*)amount
                                 withBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *cancel = @"%@/seat-request/%@/cancel";
    NSString *url = [NSString stringWithFormat:cancel, kBaseUrl, seatRequestID];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url
       parameters:@{@"session":      sessionToken,
                    @"paymentToken": paymentToken,
                    @"merchantId":   merchantId,
                    @"amount":       amount
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if (block) {
                  
                  block(YES, nil);
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              if (block) {
                  
                  block(NO, error);
              }
              
          }];
    
}

- (void)getClientTokenWithCustomerID:(NSString*)customerID
                           withBlock:(void (^)(NSString *clientToken, NSError *error))block {
    
    NSString *getToken;
    NSString *url;
    
    if(customerID) {
        getToken = @"%@/token?customerId=%@";
        url = [NSString stringWithFormat:getToken, kBaseUrl, customerID];
    }
    else {
        getToken = @"%@/token";
        url = [NSString stringWithFormat:getToken, kBaseUrl];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSString *responseClientId = responseObject[@"token"];
             
             if (block) {
                 
                 block(responseClientId, nil);
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             if (block) {
                 
                 block(nil, error);
             }
             
         }];
    
}

- (void)addCreditCardWithUserId:(NSString*)userID
                          nonce:(NSString*)nonce
                   sessionToken:(NSString*)sessionToken
                      withBlock:(void (^)(BOOL success, NSError *error))block {
    
    NSString *addCreditCard = @"%@/user/%@/card";
    NSString *url = [NSString stringWithFormat:addCreditCard, kBaseUrl, userID];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:url
       parameters:@{@"session":  sessionToken,
                    @"nonce":    nonce
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if (operation.response.statusCode == 200) {
                  
                  if (block) {
                      
                      block(YES, nil);
                  }
              }
              else {
                  
                  if (block) {
                      
                      block(NO, nil);
                      
                  }
                  
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              if (block) {
                  
                  block(NO, error);
              }
              
          }];
    
}

- (void)chargeContributionWithRequestID:(NSString*)seatRequestID
                           sessionToken:(NSString*)sessionToken
                           paymentToken:(NSString*)paymentToken
                             merchantID:(NSString*)merchantId
                                 amount:(NSString*)amount
                              withBlock:(void (^)(BOOL success, NSString *error))block {

    NSString *payment = @"%@/seat-request/%@/payment";
    NSString *url = [NSString stringWithFormat:payment, kBaseUrl, seatRequestID];
        NSLog(@"-%@", amount ?: @"");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url
       parameters:@{@"session":         sessionToken ?: @"",
                    @"paymentToken":    paymentToken ?: @"",
                    @"merchantId":      merchantId ?: @"",
                    @"amount":          amount ?: @""
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if (block) {
                  
                  block(YES, nil);
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              if (block) {
                  
                  NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                  
                  NSString *stringError = json[@"message"];
                  
                  block(NO, stringError);
                  
              }
              
          }];
    
}

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
                     withBlock:(void (^)(BOOL success, NSString *error))block {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter braintreeBirthdayDateFormatter];
    NSString *birthday = [dateFormatter stringFromDate:user.birthday];
    
    NSDictionary *addressDict = @{@"streetAddress": address ?: @"",
                                  @"locality": user.city ?: @"",
                                  @"region": region ?: @"",
                                  @"postalCode": postalCode ?: @"",
                                  };
    
    NSDictionary *individualDict = @{@"firstName": user.firstName ?: @"",
                                     @"lastName": user.lastName ?: @"",
                                     @"email": user.email?  : @"",
                                     @"dateOfBirth": birthday ?: @"",
                                     @"ssn": lastFourSSNDigits ?: @"",
                                     @"address": addressDict
                                     };
    
    NSDictionary *businessDict = @{@"legalName": businessName ?: @"",
                                   @"taxId": taxID ?: @""
                                   };
    
    NSDictionary *fundingDict;
    
    switch (paymentInfoDestination) {
        case PaymentInfoDestinationBank:
            fundingDict = @{@"destination": @"bank",
                            @"accountNumber": accountNumber ?: @"",
                            @"routingNumber": routingNumber ?: @""
                            };
            break;
        case PaymentInfoDestinationEmail:
            fundingDict = @{@"destination": @"email",
                            @"email": email ?: @""
                            };
            break;
        case PaymentInfoDestinationPhoneNumber:
            fundingDict = @{@"destination": @"mobile_phone",
                            @"mobilePhone": phoneNumber ?: @""
                            };
            break;
        default:
            break;
    }
    
    NSString *merchant = @"%@/merchant";
    NSString *url = [NSString stringWithFormat:merchant, kBaseUrl];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url
       parameters:@{@"individual":          individualDict,
                    @"business":            businessDict,
                    @"funding":             fundingDict,
                    @"hostRegistrationId":  hostRegistrationID,
                    @"tosAccepted":         @(termsOfServiceAgreement)
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if (block) {
                  
                  block(YES, nil);
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              if (block) {
                  
                  NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                  
                  NSString *stringError = json[@"message"];
                  
                  block(NO, stringError);
              }
              
          }];
    
}

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
                     withBlock:(void (^)(BOOL success, NSString *error))block {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter braintreeBirthdayDateFormatter];
    NSString *birthday = [dateFormatter stringFromDate:user.birthday];
    
    NSDictionary *addressDict = @{@"streetAddress": address ?: @"",
                                  @"locality": user.city ?: @"",
                                  @"region": region ?: @"",
                                  @"postalCode": postalCode ?: @"",
                                  };
    
    NSDictionary *individualDict = @{@"firstName": user.firstName ?: @"",
                                     @"lastName": user.lastName ?: @"",
                                     @"email": user.email?  : @"",
                                     @"dateOfBirth": birthday ?: @"",
                                     @"ssn": lastFourSSNDigits ?: @"",
                                     @"address": addressDict
                                     };
    
    NSDictionary *businessDict = @{@"legalName": businessName ?: @"",
                                   @"taxId": taxID ?: @""
                                   };
    
    NSDictionary *fundingDict;
    
    switch (paymentInfoDestination) {
        case PaymentInfoDestinationBank:
            fundingDict = @{@"destination": @"bank",
                            @"accountNumber": accountNumber ?: @"",
                            @"routingNumber": routingNumber ?: @""
                            };
            break;
        case PaymentInfoDestinationEmail:
            fundingDict = @{@"destination": @"email",
                            @"email": email ?: @""
                            };
            break;
        case PaymentInfoDestinationPhoneNumber:
            fundingDict = @{@"destination": @"mobile_phone",
                            @"mobilePhone": phoneNumber ?: @""
                            };
            break;
        default:
            break;
    }
    
    NSString *merchant = @"%@/merchant/%@";
    NSString *url = [NSString stringWithFormat:merchant, kBaseUrl, merchantId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url
       parameters:@{@"individual":          individualDict,
                    @"business":            businessDict,
                    @"funding":             fundingDict,
                    @"hostRegistrationId":  hostRegistrationID,
                    @"tosAccepted":         @(termsOfServiceAgreement),
                    @"session":             user.sessionToken
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if (block) {
                  
                  block(YES, nil);
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              if (block) {
                  
                  NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                  
                  NSString *stringError = json[@"message"];
                  
                  block(NO, stringError);
              }
              
          }];
    
}


@end
