//
//  BDLocationViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 25/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"


@protocol BDLocationViewControllerDelegate <NSObject>
@optional
- (void)changedLocation:(PFGeoPoint*)location withLocationString:(NSString*)locationString;
- (void)changedLocation:(PFGeoPoint*)location withCity:(NSString *)city andCountry:(NSString*)country;

@end



@interface BDLocationViewController : BaseViewController

@property (nonatomic, weak) IBOutlet id<BDLocationViewControllerDelegate> delegate;

- (instancetype)initWithStringLocation:(NSString *)locationString NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithPFGeoPoint:(PFGeoPoint *)location NS_DESIGNATED_INITIALIZER;

@end
