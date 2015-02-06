//
//  MapViewController.m
//  turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "MapViewController.h"
#import "ThrowViewController.h"
#import "FindViewController.h"
#import "DetailViewController.h"
#import "Constants.h"
#import "MapMarker.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

@interface MapViewController ()
<ThrowViewControllerDataSource, FindViewControllerDataSource>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic,strong)  CLPlacemark *placemark;
@property (strong)            CLGeocoder *geocoder;
@property (strong, nonatomic) GMSMapView *mapView;


@property (nonatomic, strong) NSSet *markers;
@property (nonatomic, strong) NSSet *publicMarkers;

@property (nonatomic, assign) BOOL firstTimeLocation;

@end

@implementation MapViewController

- (void)presentThrowViewController {
    UINavigationController *navController = [self.tabBarController.viewControllers objectAtIndex: 2];
    ThrowViewController *viewController = [navController.viewControllers objectAtIndex:0];
    viewController.dataSource = self;

}

- (void)presentFindViewController {
    UINavigationController *navController = [self.tabBarController.viewControllers objectAtIndex:1];
    FindViewController *viewController = [navController.viewControllers objectAtIndex: 0];
    
    viewController.dataSource = self;
}

- (CLLocation *) currentLocationForFindViewController:(FindViewController *)controller {
    return self.currentLocation;
}

- (CLLocation *) currentLocationForThrowViewController:(ThrowViewController *)controller {
    return self.currentLocation;
}

- (CLPlacemark *) currentPlacemarkForThrowViewController:(ThrowViewController *)controller {
    return self.placemark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
       
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        // Being compiled with a Base SDK of iOS 8 or later
        // Now do a runtime check to be sure the method is supported
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [_locationManager requestWhenInUseAuthorization];
            [_locationManager startUpdatingLocation];
        }
#else
        // Being compiled with a Base SDK of iOS 7.x or earlier
        // No such method - do something else as needed
#endif
        
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Set a movement threshold for new events.
        _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    }
    
    self.firstTimeLocation = YES;
    
    [self InitGoogleMaps];
    
}

- (void) InitGoogleMaps {
    
    UIEdgeInsets mapInsects = UIEdgeInsetsMake(0, 0, 40, 0);
    
    // create a GMSCameraPosition to display coordinates
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.5678118 longitude:-100.926294 zoom:5];
    
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMinZoom:3 maxZoom:14];
    self.mapView.padding = mapInsects;
    self.mapView.delegate = self;
    self.view = self.mapView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Fetch all parties
- (void) queryForAllEventsNearLocation: (CLLocation *) currentLocation {
    
    PFQuery *query = [PFQuery queryWithClassName:@"MapMarkers"];
    
    if([self.markers count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                                               longitude:currentLocation.coordinate.longitude];
    [query includeKey:@"neighbourhood"];
    [query whereKey:@"location"
        nearGeoPoint:point
        withinMiles:TurnipPostMaximumSearchDistance];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error in geo query!: %@", error);
        } else {
            [self createMarkerObject:objects];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentFindViewController];
            });
        }
    }];
}

- (void) queryForAllPublicEventsOnScreen: (CLLocationCoordinate2D) northEast andSouthWest: (CLLocationCoordinate2D) southWest {
    
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    PFGeoPoint *NE = [PFGeoPoint geoPointWithLatitude:northEast.latitude longitude:northEast.longitude];
    PFGeoPoint *SW = [PFGeoPoint geoPointWithLatitude:southWest.latitude longitude:southWest.longitude];
    
    [query whereKey:@"location" withinGeoBoxFromSouthwest:SW toNortheast:NE];
    [query whereKey:@"public" equalTo:@"True"];
    
    [query selectKeys:@[TurnipParsePostLocationKey,TurnipParsePostIdKey, TurnipParsePostTitleKey, TurnipParsePostTextKey]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error in geo query!: %@", error);
        } else {
           [self createPublicMarkerObject:objects];
        }
    }];
}

- (void) queryForAllNearbyPublicEvents: (CLLocation *) currentLocation {
    
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                                               longitude:currentLocation.coordinate.longitude];
    
    [query whereKey:TurnipParsePostLocationKey
       nearGeoPoint:point
        withinMiles:TurnipPostMaximumSearchDistance];
    
    [query whereKey:@"public" equalTo:@"True"];
    [query selectKeys:@[TurnipParsePostLocationKey,TurnipParsePostIdKey, TurnipParsePostTitleKey, TurnipParsePostTextKey]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error in geo query!: %@", error);
        } else {
            [self createPublicMarkerObject:objects];
        }
    }];
    
}

- (void) createPublicMarkerObject: (NSArray *) objects {
    NSMutableSet *mutableSet = [[NSMutableSet alloc] init];
    
    for (NSDictionary *object in objects) {
        MapMarker *public = [[MapMarker alloc] init];
        
        public.objectId = [object valueForKey:@"objectId"];
        public.title = object[TurnipParsePostTitleKey];
        public.snippet = object[TurnipParsePostTextKey];
        
        PFGeoPoint *geoPoint = object[TurnipParsePostLocationKey];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        public.position = coordinate;
        public.appearAnimation = 1;
        public.map = nil;
        public.draggable = YES;

        [mutableSet addObject: public];
    }
    self.publicMarkers = [mutableSet copy];
    [self drawPublicMarkers];

}

- (void) createMarkerObject: (NSArray *) objects {
    NSMutableSet *mutableSet = [[NSMutableSet alloc] initWithCapacity: [objects count]];
    
    for (NSDictionary *object in objects) {
        MapMarker *newMarker = [[MapMarker alloc] init];
        
        newMarker.objectId = object[TurnipParsePostIdKey];
        newMarker.title = [object[@"neighbourhood"] objectForKey:@"name"];
        
        NSString *snippet = [NSString stringWithFormat:@"Private: %@ Public %@", object[@"nrOfPrivate"], object[@"nrOfPublic"]];
        newMarker.snippet = snippet;
        
        PFGeoPoint *geoPoint = object[TurnipParsePostLocationKey];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        newMarker.position = coordinate;
        newMarker.appearAnimation = 1;
        newMarker.map = nil;
        newMarker.draggable = YES;
        
        [mutableSet addObject: newMarker];
    }
    
    self.markers = [mutableSet copy];

}

- (void) drawPublicMarkers {
    for (MapMarker *marker in self.publicMarkers) {
        if(marker.map == nil) {
            marker.map = self.mapView;
        }
    }
}

- (void) drawMarkers {
    
    for (MapMarker *marker in self.markers) {
        if (marker.map == nil) {
            marker.map = self.mapView;
        }
    }
}

-(void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    GMSVisibleRegion visibleRegion = self.mapView.projection.visibleRegion;
    CGFloat currentZoom = self.mapView.camera.zoom;
    
    NSLog(@"zoom: %f", currentZoom);
    
    GMSCoordinateBounds *bounds =
    [[GMSCoordinateBounds alloc] initWithRegion: visibleRegion];
    
    if (currentZoom >= 13) {
        
        [self.mapView clear];
        [self queryForAllPublicEventsOnScreen: bounds.northEast andSouthWest: bounds.southWest];

    } else {
       // [self.mapView clear];
        [self drawMarkers];
    }
    
    
}

//- (UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
//    UIView *infoWindow =[[UIView alloc] init];
//
//    //info window setup
//    //title label setup
//    //snippet label setup
//
//    return infoWindow;
//}

/*
 *   Called after a marker's info window has been tapped.
 */
- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(MapMarker *)marker {
    
    if (marker.objectId == nil) {
       [self performSegueWithIdentifier:@"mapToListSegue" sender: self];
    } else {
        [self performSegueWithIdentifier:@"mapToDetailsSegue" sender: marker.objectId];
    }
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods and helpers


// The CoreLocation object CLLocationManager, has a delegate method that is called
// when the location changes. This is where we will post the notification
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
    
    GMSCameraUpdate *updateCamera = [GMSCameraUpdate setTarget: CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude)  zoom:11.5];
    
    [self.mapView animateWithCameraUpdate:updateCamera];
    
    
    if (self.firstTimeLocation == YES) {
        self.firstTimeLocation = NO;
        [self presentThrowViewController];
        [self reverseGeocode:[locations lastObject]];
        [self queryForAllEventsNearLocation:self.currentLocation];
    }
}


- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
           self.placemark = [placemarks lastObject];
            NSLog(@"placemark: %@", [placemarks lastObject]);
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            [_locationManager startUpdatingLocation];
        }
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied");
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add text here" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"kCLAuthorizationStatusNotDetermined");
        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"kCLAuthorizationStatusRestricted");
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            [_locationManager startUpdatingLocation];
        }
            break;
    }
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mapToDetailsSegue"]) {
        
        NSString *id = sender;
        
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = segue.destinationViewController;
                    NSLog(@"Sender: %@", sender);
            
            DetailViewController *details = [navController.viewControllers objectAtIndex: 1];
            
            details.objectId = id;
        }
        
         DetailViewController *destViewController = segue.destinationViewController;
        destViewController.objectId = id;
    }

}

// Look for new Events
- (IBAction)updateButtonHandler:(id)sender {
    [self.mapView clear];
    [self reverseGeocode:self.currentLocation];
    [self queryForAllEventsNearLocation: self.currentLocation];
    [self drawMarkers];
}
@end
