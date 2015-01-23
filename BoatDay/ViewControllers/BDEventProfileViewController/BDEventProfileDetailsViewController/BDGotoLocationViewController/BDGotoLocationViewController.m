//
//  BDGotoLocationViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 25/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDGotoLocationViewController.h"
#import "BDBoatLocationPinAnnotation.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface BDGotoLocationViewController () <MKMapViewDelegate>

// Map View
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) BDBoatLocationPinAnnotation *annotation;
@property (weak, nonatomic) IBOutlet UIButton *getDirectionsButton;

// Data
@property (strong, nonatomic) PFGeoPoint *location;
@property (strong, nonatomic) Event *event;

- (IBAction)getDirectionsButtonPressed:(id)sender;

@end

@implementation BDGotoLocationViewController

// init this view with a location already
- (instancetype)initWithEvent:(Event*)event{
    
    self = [super init];
    
    if( !self ) return nil;
    
    _location = event.pickupLocation;
    _event = event;
    
    return self;
    
}

// init this view with a location already
- (instancetype)initWithPFGeoPoint:(PFGeoPoint *)location {
    
    self = [super init];
    
    if( !self ) return nil;
    
    _location = location;
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"event.pickupLocation.title", nil);
    
}

#pragma mark - Setup Methods

- (void) setupView {
    
    // Setup Map View
    [self setupMapView];
    
    [self.getDirectionsButton setBackgroundColor:[UIColor clearColor]];
    
    [self.getDirectionsButton setTitle:NSLocalizedString(@"event.pickupLocation.getDirections", nil) forState:UIControlStateNormal];
    [self.getDirectionsButton.titleLabel setFont:[UIFont abelFontWithSize:15.0]];
    
    [self.getDirectionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.getDirectionsButton setTitleColor:[UIColor mediumGreenBoatDay] forState:UIControlStateHighlighted];
    
    [self.getDirectionsButton setImage:[UIImage imageNamed:@"location_gps_lg_white"] forState:UIControlStateNormal];
    [self.getDirectionsButton setImage:[UIImage imageNamed:@"location_gps_lg_on"] forState:UIControlStateHighlighted];
    
    [self.getDirectionsButton setBackgroundImage:[UIImage imageNamed:@"greenBarBackground"] forState:UIControlStateNormal];
    [self.getDirectionsButton setBackgroundImage:[UIImage imageNamed:@"whiteBarBackground"] forState:UIControlStateHighlighted];
    
    [self prepareMapForGeoPoint:self.location];
    
}

- (void) setupMapView {
    
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    
}

- (void) prepareMapForGeoPoint:(PFGeoPoint *)geoPoint {
    
    MKCoordinateRegion region;
    
    float spanX = 0.05;
    float spanY = 0.05;
    
    region.center.latitude = geoPoint.latitude;
    region.center.longitude = geoPoint.longitude;
    region.span = MKCoordinateSpanMake(spanX, spanY);
    [self.mapView setRegion:region animated:YES];
    
    [self addPinToGeoPoint:geoPoint];
    
}

- (void) addPinToGeoPoint:(PFGeoPoint *)geoPoint {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.selectedAnnotations = nil;
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    self.annotation = [[BDBoatLocationPinAnnotation alloc] init];
    self.annotation.coordinate = coord;
    self.annotation.event = nil;
    [self.mapView addAnnotation:self.annotation];
    
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


#pragma mark - Action Methods

- (IBAction)getDirectionsButtonPressed:(id)sender {
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude);
    
    //Apple Maps, using the MKMapItem class
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = self.event.name;
    [item openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
    
}


@end
