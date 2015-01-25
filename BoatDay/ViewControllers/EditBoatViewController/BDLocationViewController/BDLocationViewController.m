//
//  BDLocationViewController.m
//  BoatDay
//
//  Created by Diogo Nunes on 25/07/14.
//  Copyright (c) 2014 Rocksauce Studios LLC. All rights reserved.
//

#import "BDLocationViewController.h"
#import <MapKit/MapKit.h>
#import "UIAlertView+Blocks.h"
#import <CoreLocation/CoreLocation.h>

@interface BDLocationViewController () <MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate>

// Navigation Bar
@property (strong, nonatomic) UIBarButtonItem *saveButton;

// Map View
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation *annotation;

// Top Search View
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *pinButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

// Gestures
@property (strong, nonatomic) UITapGestureRecognizer *tap;

// Data
@property (strong, nonatomic) PFGeoPoint *oldLocation;
@property (strong, nonatomic) PFGeoPoint *actualLocation;
@property (strong, nonatomic) Boat *boat;
@property (strong, nonatomic) NSString *locationString;

@property (strong, nonatomic) NSString *locality;
@property (strong, nonatomic) NSString *country;


//Location
@property (strong, nonatomic) CLLocationManager *locationManager;

// Action Methods
- (IBAction)pinButtonPressed:(id)sender;

@end

@implementation BDLocationViewController

// init this view with a location string
- (instancetype)initWithStringLocation:(NSString *)locationString{
    
    self = [super init];
    
    if( !self ) return nil;
    
    _locationString = locationString;
    
    return self;
    
}

// init this view with a location geopoint
- (instancetype)initWithPFGeoPoint:(PFGeoPoint *)location {
    
    self = [super init];
    
    if( !self ) return nil;
    
    if (location != (id)[NSNull null]) {
        _oldLocation = location;
    }
    
    return self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.screenName =@"BDLocationViewController";

    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    
    // set keyboard observers to be called when textFields and textFields are responders
    //   we will need to scroll the table to show the field that is being editing
    [self addKeyboardObservers];
    
    // Setup Map View
    [self setupMapView];
    
    if (self.oldLocation) {
        [self setLocationLabelFromGeoPoint:self.oldLocation];
    }
    else {
        if ([NSString isStringEmpty:self.locationString]) {
            [self getCurrentLocation];
        }
        else {
            self.searchBar.text = self.locationString;
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // setup navigation bar buttons
    [self setupNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    // remove all observers from notification center to be sure we got no memory leaks
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [SVProgressHUD dismiss];
    [self.locationManager stopUpdatingLocation];
    
    
}

- (void) addKeyboardObservers {
    
    // add will hide and show keyboard observers from notification center
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

#pragma mark - Setup Methods

- (void) setupNavigationBar {
    
    self.title = NSLocalizedString(@"location.title", nil);
    
    // create save button to navigatio bar at top of the view
    UIButton *saveButtons = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButtons.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [saveButtons setImage:[UIImage imageNamed:@"ico-save"] forState:UIControlStateNormal];
    [saveButtons addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton = [[UIBarButtonItem alloc] initWithCustomView:saveButtons];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
    [cancelButton setImage:[UIImage imageNamed:@"ico-Cancel"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
}

- (void) setupMapView {
    
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    
}

#pragma mark - Navigation Bar Button Actions

- (void) cancelButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"cancelButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    if ([self.delegate respondsToSelector:@selector(changedLocation:withLocationString:)]) {
        [self.delegate changedLocation:self.oldLocation withLocationString:nil];
    }
    
    if ([self.delegate respondsToSelector:@selector(changedLocation:withCity:andCountry:)]) {
        [self.delegate changedLocation:self.oldLocation withCity:nil andCountry:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) saveButtonPressed {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"saveButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    if ([self.delegate respondsToSelector:@selector(changedLocation:withLocationString:)]) {
        [self.delegate changedLocation:self.actualLocation withLocationString:self.searchBar.text];
    }
    
    if ([self.delegate respondsToSelector:@selector(changedLocation:withCity:andCountry:)]) {
        [self.delegate changedLocation:self.actualLocation withCity:self.locality andCountry:self.country];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

// Action Methods

- (IBAction)pinButtonPressed:(id)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"pinButtonPressed"
                                                                label:self.screenName
                                                                value:nil] build]];


    [self getCurrentLocation];
    
}

#pragma mark - Map Search Methods

-(void)searchMapLocationForText:(NSString *)text {
    
    [SVProgressHUD show];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        
        [SVProgressHUD dismiss];
        
        if (placemarks.count) {
            
            CLPlacemark *placemark = placemarks[0];
            
            PFGeoPoint *geoPoint = [PFGeoPoint geoPoint];
            geoPoint.latitude = placemark.location.coordinate.latitude;
            geoPoint.longitude = placemark.location.coordinate.longitude;
            
            [self prepareMapForGeoPoint:geoPoint locality:placemark.locality country:placemark.country];
            
        }
        else {
            
            [self showLocationFailedAlertView];
            
        }
        
    }];
    
}

- (void) setLocationLabelFromGeoPoint:(PFGeoPoint *)geoPoint {
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if (error){
                           
                           self.searchBar.text = @"";
                           
                           [self showLocationFailedAlertView];
                           
                           return;
                           
                       }
                       
                       CLPlacemark *placemark = placemarks[0];
                       
                       [self prepareMapForGeoPoint:geoPoint locality:placemark.locality country:placemark.country];
                       
                   }];
    
}

- (void) prepareMapForGeoPoint:(PFGeoPoint *)geoPoint locality:(NSString *)locality country:(NSString *)country {
    
    MKCoordinateRegion region;
    
    float spanX = 0.05;
    float spanY = 0.05;
    
    region.center.latitude = geoPoint.latitude;
    region.center.longitude = geoPoint.longitude;
    region.span = MKCoordinateSpanMake(spanX, spanY);
    [self.mapView setRegion:region animated:YES];
    
    NSMutableArray *cityCountryArray = [[NSMutableArray alloc] init];
    
    if (![NSString isStringEmpty:locality]) {
        [cityCountryArray addObject:[locality capitalizedString]];
    }
    
    if (![NSString isStringEmpty:country]) {
        [cityCountryArray addObject:[country capitalizedString]];
    }
    
    self.searchBar.text = [cityCountryArray componentsJoinedByString:@", "];
    self.locality = locality;
    self.country = country;
    
    [self addPinToGeoPoint:geoPoint];
    
    [self.navigationItem setRightBarButtonItem:self.saveButton animated:YES];
    
}

- (void) addPinToGeoPoint:(PFGeoPoint *)geoPoint {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.selectedAnnotations = nil;
    
    self.annotation = [[MKPointAnnotation alloc] init];
    [self.mapView addAnnotation:self.annotation];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    [self.annotation setCoordinate:coord];
    [self.annotation setTitle:self.searchBar.text];
    [self.mapView selectAnnotation:self.annotation animated:YES];
    
    self.actualLocation = geoPoint;
    
}

- (void) showLocationFailedAlertView {
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"location.placeNotFound.title", nil)
                                message:NSLocalizedString(@"location.placeNotFound", nil)
                       cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"location.placeNotFound.okButton", nil) action:^{
        
        // Handle "Cancel"
        
    }]
                       otherButtonItems:nil, nil] show];
    
}

#pragma mark - Location Manager Delegate Methods

-(void) getCurrentLocation {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    if (!self.locationManager) {
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            
            [self.locationManager requestWhenInUseAuthorization];
            
        }
        
    } else {
        
        [self.locationManager startUpdatingLocation];
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [manager startUpdatingLocation];
            break;
            
        default:
            break;
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    PFGeoPoint *geoPoint = [PFGeoPoint geoPoint];
    geoPoint.latitude = newLocation.coordinate.latitude;
    geoPoint.longitude = newLocation.coordinate.longitude;
    
    [self setLocationLabelFromGeoPoint:geoPoint];
    [self.pinButton setBackgroundImage:[UIImage imageNamed:@"location_gps_lg_on"] forState:UIControlStateNormal];
    [self.pinButton setBackgroundImage:[UIImage imageNamed:@"location_gps_lg_off"] forState:UIControlStateHighlighted];
    
    [SVProgressHUD dismiss];
    [self.locationManager stopUpdatingLocation];
    
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self dismissKeyboard];
    
    [self searchMapLocationForText:searchBar.text];
    [self.pinButton setBackgroundImage:[UIImage imageNamed:@"location_gps_lg_off"] forState:UIControlStateNormal];
    [self.pinButton setBackgroundImage:[UIImage imageNamed:@"location_gps_lg_on"] forState:UIControlStateHighlighted];
    
}

#pragma mark - Keyboard Methods

- (void)dismissKeyboard {
    
    [self.view endEditing:YES];
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    
    // Add tap gesture to dismiss keyboard
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(dismissKeyboard)];
    [self.tap setNumberOfTapsRequired:1];
    [self.navigationController.view addGestureRecognizer:self.tap];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    // Remove gesture recognizer
    [self.navigationController.view removeGestureRecognizer:self.tap];
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    self.tap = nil;
    
}

#pragma mark - Gesture Recognizer Methods

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
     [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UIAction"
                                                               action:@"handleLongPressGesture"
                                                                label:self.screenName
                                                                value:nil] build]];


    if (sender.state == UIGestureRecognizerStateBegan) {
        
        // Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
        CGPoint point = [sender locationInView:self.mapView];
        CLLocationCoordinate2D locationCoordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        
        PFGeoPoint *geoPoint = [PFGeoPoint geoPoint];
        geoPoint.latitude = locationCoordinate.latitude;
        geoPoint.longitude = locationCoordinate.longitude;
        
        [self setLocationLabelFromGeoPoint:geoPoint];
        
    }
    
}

@end
