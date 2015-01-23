//
//  BDFindABoatEventsViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindABoatEventsViewController.h"
#import "iCarousel.h"
#import "BDEventCardView.h"

@interface BDFindABoatEventsViewController ()

// View
@property (weak, nonatomic) IBOutlet iCarousel *scrollView;

// Data
@property (nonatomic, strong) NSArray *events;


@end

@implementation BDFindABoatEventsViewController

- (instancetype)initWithEvents:(NSArray *)events {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _events = events;
    _showCardsWithStatus = NO;
    
    return self;
    
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [self setupView];
    
    if (!self.events.count) {
        [self addPlaceholderViewWithTitle:@"There are no events available!" andMessage:@"" toView:self.view];
    }
    
}

- (void)dealloc
{
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    self.scrollView.delegate = nil;
    self.scrollView.dataSource = nil;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.scrollView = nil;
}

#pragma mark - Setup Methods

- (void) setupView {
    
    self.scrollView.type = iCarouselTypeCustom;
    self.scrollView.scrollSpeed = 0.9;
    self.scrollView.decelerationRate = 0.6;
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.events count];
}

- (BDEventCardView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(BDEventCardView *)view {
    
    NSString *nibName = self.showCardsWithStatus ? @"BDEventCardViewWithStatus" : @"BDEventCardView";
    
    //create new view if no view is available for recycling
    if (view == nil) {
        
        view = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil][0];
        
        setFrameHeight(view, CGRectGetHeight(self.scrollView.frame) * 0.91);
        
    }
    
    [view updateCardWithEvent:self.events[index]];
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
    
    const CGFloat offsetFactor = [self carousel:carousel valueForOption:iCarouselOptionSpacing withDefault:1.0f]*carousel.itemWidth;
    
    //... the faster they shrink
    const CGFloat shrinkFactor = 2.0f;
    
    //hyperbola
    CGFloat fSize = sqrtf(offset*offset+1)-1;
    
    transform = CATransform3DTranslate(transform, offset*offsetFactor, 0.0, 0.0);
    transform = CATransform3DScale(transform, 1/(fSize/shrinkFactor+1.0f), 1/(fSize/shrinkFactor+1.0f), 1.0);
    
    return transform;
    
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.01f;
        }
        default:
        {
            return value;
        }
    }
}

#pragma mark -
#pragma mark iCarousel taps

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
    Event *event = self.events[index];
    
    if (self.eventTappedBlock) {
        self.eventTappedBlock(event);
    }
    
}

@end
