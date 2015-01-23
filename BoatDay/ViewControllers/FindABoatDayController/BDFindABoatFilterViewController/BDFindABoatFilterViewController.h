//
//  BDFindABoatFilterViewController.h
//  BoatDay
//
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BaseViewController.h"

// Define filterDictionary change block
typedef void (^NewFilterDictionaryChangeBlock)(NSMutableDictionary *filterDictionary);

@interface BDFindABoatFilterViewController : BaseViewController

@property (nonatomic, copy) NewFilterDictionaryChangeBlock filterDictionaryChangeBlock;

- (instancetype)initWithFilterDictionary:(NSMutableDictionary*)filterDictionary NS_DESIGNATED_INITIALIZER;

@end
