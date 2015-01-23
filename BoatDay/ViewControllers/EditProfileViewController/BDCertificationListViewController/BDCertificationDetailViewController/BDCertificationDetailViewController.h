//
//  BDCertificationDetailViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 27/06/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

@interface BDCertificationDetailViewController : BaseViewController

- (instancetype)initCertification:(Certification*)certification andCertificatonType:(CertificationType*)type NS_DESIGNATED_INITIALIZER;

@end
