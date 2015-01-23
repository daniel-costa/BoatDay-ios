//
//  BDEventProfileWallViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDEventProfileWallViewController.h"
#import "BDEventGuestsCell.h"
#import "NRLoadingView.h"
#import "BDProfileViewController.h"

@interface BDEventProfileWallViewController ()

@property (nonatomic, strong) NRLoadingView *loadingView;

// Data
@property (nonatomic, strong) Event *event;

@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *confirmedRequests;

@end

@implementation BDEventProfileWallViewController

- (instancetype)initWithEvent:(Event *)event {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _event = event;
    
    return self;
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.sender = [User currentUser].objectId;
    
    self.messages = [[NSMutableArray alloc] init];
    
    self.avatars = [[NSMutableDictionary alloc] init];
    
    [self.inputToolbar setTintColor:[UIColor greenBoatDay]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self setupView];
    
    BOOL canSendMessages = NO;
    
    if ([self.event.host isEqual:[User currentUser]]) {
        canSendMessages = YES;
    }
    else {
        for (SeatRequest *request in self.event.seatRequests) {
            if(![request isEqual:[NSNull null]]) {
                
                if ([request.user isEqual:[User currentUser]]) {
                    canSendMessages = YES;
                }
            }
        }
    }
    
    if (!canSendMessages) {
        self.inputToolbar.userInteractionEnabled = NO;
    }
    
    if (self.messages.count == 0) {
        
        if ([self.loadingView superview] != self.view) {
            
            self.loadingView = [[NRLoadingView alloc] initWithFrame:self.view.bounds];
            [UIView showViewAnimated:self.loadingView withAlpha:YES duration:0.3 andDelay:0.0 andScale:NO];
            [self.view addSubview:self.loadingView];
            
        }
        
    }
    
    self.isLoading = NO;
    [self loadMessages];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
    
}

#pragma mark - Get Data Methods

- (void)loadMessages {
    
    if (self.isLoading == NO) {
        
        self.isLoading = YES;
        
        ChatMessage *lastMessage = [self.messages lastObject];
        
        PFQuery *query = [ChatMessage query];
        
        [query whereKey:@"event" equalTo:self.event];
        
        if (lastMessage != nil) {
            [query whereKey:@"createdAt" greaterThan:lastMessage.createdAt];
        }
        
        [query includeKey:@"user"];
        [query orderByAscending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if ([self.loadingView superview]) {
                [UIView removeViewAnimated:self.loadingView withAlpha:YES andDuration:0.0];
            }
            
            if (error == nil) {
                
                [self.messages addObjectsFromArray:objects];
                
                if ([objects count] != 0) {
                    
                    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                    
                    [self finishReceivingMessage];
                    
                }
                
            }
            
            
            self.isLoading = NO;
            
        }];
    }
}

#pragma mark - Setup Methods

- (void) setupView {
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont quattroCentoRegularFontWithSize:15.0];
    
    self.selfBubbleImageView = [JSQMessagesBubbleImageFactory
                                outgoingMessageBubbleImageViewWithColor:RGB(53, 190, 206)];
    
    self.hostSelfBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:RGB(27, 116, 130)];
    
    self.usersBubbleImageView = [JSQMessagesBubbleImageFactory
                                 incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.hostBubbleImageView = [JSQMessagesBubbleImageFactory
                                incomingMessageBubbleImageViewWithColor:RGB(27, 116, 130)];
    
    
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date {
    
    if (![NSString isStringEmpty:text]) {
        
        ChatMessage *object = [ChatMessage object];
        object.event = self.event;
        object.user = [User currentUser];
        object.text = text;
        
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                [self.messages addObject:object];
                
                [self createNotificationsWithChatMessage:object];
                
                [JSQSystemSoundPlayer jsq_playMessageSentSound];
                
                [self finishSendingMessage];
                
                [self loadMessages];
                
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Network error"];
            }
            
        }];
        
        
    }
    
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.item];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatMessage *message = self.messages[indexPath.item];
    
    if ([message.sender isEqualToString:self.event.host.objectId]) {
        
        if ([message.sender isEqualToString:[User currentUser].objectId]) {
            
            return [[UIImageView alloc] initWithImage:self.hostSelfBubbleImageView.image
                                     highlightedImage:self.hostSelfBubbleImageView.highlightedImage];
            
        }
        else {
            return [[UIImageView alloc] initWithImage:self.hostBubbleImageView.image
                                     highlightedImage:self.hostBubbleImageView.highlightedImage];
        }
        
    }
    
    if ([message.sender isEqualToString:self.sender]) {
        return [[UIImageView alloc] initWithImage:self.selfBubbleImageView.image
                                 highlightedImage:self.selfBubbleImageView.highlightedImage];
    }
    
    
    return [[UIImageView alloc] initWithImage:self.usersBubbleImageView.image
                             highlightedImage:self.usersBubbleImageView.highlightedImage];
    
    
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ChatMessage *chatMessage = self.messages[indexPath.item];
    User *user = chatMessage.user;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_avatar"]];
    
    if (self.avatars[user.objectId] == nil) {
        
        PFFile *filePicture = user.pictures[[user.selectedPictureIndex integerValue]];
        
        [filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 self.avatars[user.objectId] = [UIImage imageWithData:imageData];
                 [imageView setImage:self.avatars[user.objectId]];
                 
             }
         }];
    }
    else {
        [imageView setImage:self.avatars[user.objectId]];
    }
    
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.layer.masksToBounds = YES;
    
    return imageView;
    
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item % 3 == 0)
    {
        ChatMessage *message = self.messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMessage *message = self.messages[indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.sender isEqualToString:self.sender]){
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"eventProfile.wall.you", nil)];
    }
    
    if (indexPath.item - 1 > 0) {
        ChatMessage *previousMessage = self.messages[indexPath.item - 1];
        if ([[previousMessage sender] isEqualToString:message.sender]) {
            return nil;
        }
    }
    
    User *user = message.user;
    
    return [[NSAttributedString alloc] initWithString:user ? user.shortName : @"Unknown"];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    ChatMessage *msg = self.messages[indexPath.item];
    
    if ([msg.sender isEqualToString:self.sender] || [msg.sender isEqualToString:self.event.host.objectId]) {
        cell.textView.textColor = [UIColor whiteColor];
    }
    else {
        cell.textView.textColor = RGB(109, 110, 112);
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}


#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item % 3 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    ChatMessage *currentMessage = self.messages[indexPath.item];
    if ([[currentMessage sender] isEqualToString:self.sender]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        ChatMessage *previousMessage = self.messages[indexPath.item- 1];
        if ([[previousMessage sender] isEqualToString:[currentMessage sender]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    
    ChatMessage *currentMessage = self.messages[indexPath.item];
    
    if (self.userTapBlock){
        self.userTapBlock(currentMessage.user);
    }
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
}

#pragma mark - Notification Methods

- (void) createNotificationsWithChatMessage:(ChatMessage *)chatMessage {
    
    // Notifications only from event host (boat owner) messages
    if (![[User currentUser] isEqual:self.event.host]) {
        return;
    }
    
    if (!self.confirmedRequests) {
        
        self.confirmedRequests = [[NSMutableArray alloc] init];
        
        // Check for user seats request
        for (SeatRequest *request in self.event.seatRequests) {
            
            if(![request isEqual:[NSNull null]]) {
                
                if ([request.status integerValue] == SeatRequestStatusAccepted) {
                    
                    [self.confirmedRequests addObject:request];
                    
                }
                
            }
            
        }
        
    }
    
    for (User *user in self.confirmedRequests) {
        
        Notification *object = [Notification object];
        object.event = self.event;
        object.user = user;
        object.text = NSLocalizedString(@"notifications.newComent", nil);
        object.read = @(NO);
        object.notificationType = @(NotificationTypeNewChatMessage);
        object.seatRequest = nil;
        object.boat = nil;
        
        [object saveInBackground];
        
    }
    
}

@end
