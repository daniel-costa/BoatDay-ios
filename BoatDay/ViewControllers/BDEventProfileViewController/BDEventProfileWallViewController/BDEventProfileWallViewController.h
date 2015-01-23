//
//  BDEventProfileWallViewController.h
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSQMessages.h"

typedef void (^UserTappedBlock)(User *user);

@interface BDEventProfileWallViewController : JSQMessagesViewController

// Chat
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *avatars;

@property (strong, nonatomic) UIImageView *selfBubbleImageView;
@property (strong, nonatomic) UIImageView *hostSelfBubbleImageView;

@property (strong, nonatomic) UIImageView *usersBubbleImageView;
@property (strong, nonatomic) UIImageView *hostBubbleImageView;

@property (nonatomic, copy) UserTappedBlock userTapBlock;

- (instancetype)initWithEvent:(Event *)event NS_DESIGNATED_INITIALIZER;

@end
