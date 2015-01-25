//
//  BDFindABoatMapViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 29/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDFindABoatMapViewController.h"
#import "BDBoatLocationPinAnnotation.h"
#import <MapKit/MapKit.h>

@interface BDFindABoatMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// Data
@property (nonatomic, strong) NSArray *events;

@end

@implementation BDFindABoatMapViewController

- (instancetype)initWithEvents:(NSArray *)events {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _events = events;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.screenName =@"BDFindABoatMapViewController";

    // Setup Map View
    [self setupMapView];
    
}

- (void) setupMapView {
    
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = NO;
    
    [self.mapView addAnnotations:[self createAnnotations]];
    
    if (![self.mapCenter isKindOfClass:[NSNull class]]) {
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.2;
        span.longitudeDelta = 0.2;
        CLLocationCoordinate2D location;
        location.latitude = self.mapCenter.latitude;
        location.longitude = self.mapCenter.longitude;
        region.span = span;
        region.center = location;
        [self.mapView setRegion:region animated:YES];
        
    }
    
}

- (NSMutableArray *)createAnnotations {
    
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    //Read locations details from plist
    for (Event *event in self.events) {
        
        NSNumber *latitude = @(event.pickupLocation.latitude);
        NSNumber *longitude = @(event.pickupLocation.longitude);
        
        //Create coordinates from the latitude and longitude values
        CLLocationCoordinate2D coord;
        coord.latitude = latitude.doubleValue;
        coord.longitude = longitude.doubleValue;
        
        BDBoatLocationPinAnnotation *annotation = [[BDBoatLocationPinAnnotation alloc] init];
        annotation.coordinate = coord;
        annotation.event = event;
        
        [annotations addObject:annotation];
    }
    
    return annotations;
    
}

#pragma mark -
#pragma mark MKMapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        ((MKUserLocation *)annotation).title = @"";
        return nil;
    }
    
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    
    annotationView.image = [UIImage imageNamed:@"map_pin"];
    annotationView.annotation = annotation;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if ([self.mapCenter isKindOfClass:[NSNull class]]) {
        
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.2;
        span.longitudeDelta = 0.2;
        CLLocationCoordinate2D location;
        location.latitude = userLocation.coordinate.latitude;
        location.longitude = userLocation.coordinate.longitude;
        region.span = span;
        region.center = location;
        [aMapView setRegion:region animated:YES];
        
    }
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    BDBoatLocationPinAnnotation *annotation = view.annotation;
    
    if ([annotation isKindOfClass:[BDBoatLocationPinAnnotation class]]) {
        
        Event *event = annotation.event;
        
        if (self.eventTappedBlock) {
            self.eventTappedBlock(event);
        }
        
    }
    
    [self.mapView deselectAnnotation:annotation animated:YES];
    
}

@end
