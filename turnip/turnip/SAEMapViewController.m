//
//  SAEMapViewController.m
//  Turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ParseErrorHandlingController.h"
#import "SAEMapViewController.h"
#import "SAEThrowViewController.h"
#import "SAEDetailsViewController.h"
#import "SAEFindViewController.h"
#import "Constants.h"
#import "SAEMapMarker.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>


@interface SAEMapViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) GMSMapView *mapView;

@property (nonatomic, assign) CGFloat currentZoom;
@property (nonatomic, assign) CGFloat oldZoom;

@property (nonatomic, strong) NSSet *markers;
@property (nonatomic, strong) NSSet *publicMarkers;

@property (nonatomic, assign) BOOL firstTimeLocation;
@property (nonatomic, assign) BOOL queryPublicEvents;

@property (nonatomic, strong) NSArray *currentEvent;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong) GMSPlacesClient *placesClient;


@end

@implementation SAEMapViewController


- (void) locationManagerDidUpdateLocation:(CLLocation *)location {
    self.currentLocation = location;
    
    GMSCameraUpdate *updateCamera = [GMSCameraUpdate setTarget: CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude)  zoom:11.5];
    
    if (self.firstTimeLocation == YES) {
        self.firstTimeLocation = NO;
        
        [self queryForAllEventsNearLocation:self.currentLocation];
        [self.mapView animateWithCameraUpdate:updateCamera];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [[SAELocationManager sharedInstance] addLocationManagerDelegate: self];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[SAELocationManager sharedInstance] removeLocationManagerDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkLocalEvent];
    [self checkNotificationCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventWasChanged:) name:TurnipPartyThrownNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventWasChanged:) name:TurnipEventDeletedNotification object:nil];
    
    UIImage *image = [UIImage imageNamed:@"turnip.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    self.firstTimeLocation = YES;
    self.queryPublicEvents = YES;
    
    [self InitGoogleMaps];
}

- (void) InitGoogleMaps {
    
    // create a GMSCameraPosition to display coordinates
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.5678118 longitude:-100.926294 zoom:5];
  //  UIEdgeInsets mapInsets = UIEdgeInsetsMake(0, 0, 40, 0);
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.rotateGestures = NO;
    self.mapView.settings.tiltGestures = NO;
    self.mapView.settings.consumesGesturesInView = NO;
   // self.mapView.settings.myLocationButton = YES;
    [self.mapView setMinZoom:3 maxZoom:14];
   // self.mapView.padding = mapInsets;
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
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                                               longitude:currentLocation.coordinate.longitude];
    
    PFQuery *publicQuery = [PFQuery queryWithClassName:@"Neighbourhoods"];
    [publicQuery whereKey:@"nrOfPublic" greaterThanOrEqualTo:@1];
    
    PFQuery *privateQuery = [PFQuery queryWithClassName:@"Neighbourhoods"];
    [privateQuery whereKey:@"nrOfPrivate" greaterThanOrEqualTo:@1];
    
    NSMutableArray *queryArray = [NSMutableArray arrayWithCapacity:2];
    [queryArray addObject:privateQuery];
    [queryArray addObject:publicQuery];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:queryArray];
    
    if([self.markers count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:@"coordinate"
       nearGeoPoint:point
        withinMiles:TurnipPostMaximumSearchDistance];
    
    [query selectKeys:@[@"coordinate", @"nrOfPublic", @"nrOfPrivate", @"name"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            [ParseErrorHandlingController handleParseError:error];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^ {
                 [self createMarkerObject:objects];
            });
        }
    }];
}

- (void) queryForAllPublicEventsOnScreen: (CLLocationCoordinate2D) northEast andSouthWest: (CLLocationCoordinate2D) southWest {
    
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    PFGeoPoint *NE = [PFGeoPoint geoPointWithLatitude:northEast.latitude longitude:northEast.longitude];
    PFGeoPoint *SW = [PFGeoPoint geoPointWithLatitude:southWest.latitude longitude:southWest.longitude];
    
    [query whereKey:@"location" withinGeoBoxFromSouthwest:SW toNortheast:NE];
    [query whereKey:@"private" equalTo:@"False"];
    
    [query selectKeys:@[TurnipParsePostLocationKey,TurnipParsePostIdKey, TurnipParsePostTitleKey, TurnipParsePostTextKey]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            [ParseErrorHandlingController handleParseError:error];
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
    
    [query whereKey:@"private" equalTo:@"False"];
    [query selectKeys:@[TurnipParsePostLocationKey,TurnipParsePostIdKey, TurnipParsePostTitleKey, TurnipParsePostTextKey]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            [ParseErrorHandlingController handleParseError:error];
        } else {
            [self createPublicMarkerObject:objects];
        }
    }];
    
}

- (void) createPublicMarkerObject: (NSArray *) objects {
    NSMutableSet *mutableSet = [[NSMutableSet alloc] init];
    
    for (NSDictionary *object in objects) {
        SAEMapMarker *public = [[SAEMapMarker alloc] init];
        
        public.objectId = [object valueForKey:@"objectId"];
        public.title = object[TurnipParsePostTitleKey];
        public.snippet = object[TurnipParsePostTextKey];
        
        PFGeoPoint *geoPoint = object[TurnipParsePostLocationKey];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        public.position = coordinate;
        public.appearAnimation = 1;
        public.map = nil;
        public.icon = [UIImage imageNamed:@"locationpin"];
      //  public.draggable = YES;

        [mutableSet addObject: public];
    }
    self.publicMarkers = [mutableSet copy];
    [self drawPublicMarkers];

}

- (void) createMarkerObject: (NSArray *) objects {
    NSMutableSet *mutableSet = [[NSMutableSet alloc] initWithCapacity: [objects count]];
    
    for (NSDictionary *object in objects) {
        SAEMapMarker *newMarker = [[SAEMapMarker alloc] init];
        newMarker.objectId = nil;
        newMarker.userData = [object valueForKey:@"objectId"];
        newMarker.title = object[@"name"];
        
        NSString *snippet = [NSString stringWithFormat:@"Private: %@ Public %@", object[@"nrOfPrivate"], object[@"nrOfPublic"]];
        newMarker.snippet = snippet;
        
        PFGeoPoint *geoPoint = object[@"coordinate"];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        newMarker.position = coordinate;
        newMarker.appearAnimation = 1;
        newMarker.icon = [UIImage imageNamed:@"locationpin"];
        newMarker.map = nil;
      //  newMarker.draggable = YES;
        
        [mutableSet addObject: newMarker];
    }
    
    self.markers = [mutableSet copy];
    [self drawMarkers];

}

- (void) drawPublicMarkers {
    for (SAEMapMarker *marker in self.publicMarkers) {
        if(marker.map == nil) {
            marker.map = self.mapView;
        }
    }
}

- (void) drawMarkers {
    
    for (SAEMapMarker *marker in self.markers) {
        if (marker.map == nil) {
            marker.map = self.mapView;
        }
    }
}

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    
    self.currentZoom = self.mapView.camera.zoom;
    
    if (self.oldZoom > self.currentZoom && self.currentZoom < 13) {
        [self.mapView clear];
        NSLog(@"draw marker");
        [self drawMarkers];
    }else if (self.oldZoom < self.currentZoom && self.currentZoom >= 13) {
        [self.mapView clear];
        if (self.queryPublicEvents) {
            NSLog(@"query Public");
            [self queryForAllNearbyPublicEvents: self.currentLocation];
            self.queryPublicEvents = NO;
        } else {
            NSLog(@"draw public");
            [self drawPublicMarkers];
        }
    }
    self.oldZoom = self.currentZoom;
}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    return NO;
}

/*
 *   Called after a marker's info window has been tapped.
 */
- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(SAEMapMarker *)marker {
    
    if (marker.objectId == nil) {
        [self performSegueWithIdentifier:@"mapToListSegue" sender: marker];
    } else {
        [self performSegueWithIdentifier:@"mapToDetailsSegue" sender: marker];
    }
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods and helpers


//- (void)reverseGeocode:(CLLocation *)location {
//    NSLog(@"location :%@", location);
//    
//    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//        if (error) {
//            NSLog(@"Error %@", error.description);
//        } else {
//            self.placemark = [placemarks lastObject];
//            NSLog(@"Locality: %@", self.placemark.locality);
//            NSLog(@"placemark: %@", self.placemark.subAdministrativeArea);
//        }
//    }];
//}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mapToDetailsSegue"]) {
        
        NSString *objectId = [sender valueForKey:@"objectId"];
        
        SAEDetailsViewController *destViewController = segue.destinationViewController;
       // destViewController.objectId = objectId;
        destViewController.title = [sender valueForKey:@"title"];
    }
    
    if ([segue.identifier isEqualToString:@"mapToListSegue"]) {
        SAEFindViewController *destViewController = [segue destinationViewController];
        destViewController.currentLocation = self.currentLocation;
        destViewController.neighbourhoodId = [sender valueForKey:@"userData"];
        destViewController.neighbourhoodName = [sender valueForKey:@"title"];
    }
}

// Look for new Events
- (IBAction)updateButtonHandler:(id)sender {
    
    [self.mapView clear];
    [self queryForAllEventsNearLocation: self.currentLocation];
}

- (IBAction)feedButtonHandler:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Notifications
- (void)eventWasChanged:(NSNotification *)note {
    [self.mapView clear];
    [self queryForAllEventsNearLocation: self.currentLocation];
}

#pragma mark -
#pragma mark Core Data

- (NSArray *) loadCoreData {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"YourEvents" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [[NSArray alloc] initWithArray:[context executeFetchRequest:fetchRequest error: &error]];
    
    if ([fetchedObjects count] == 0) {
        return nil;
    } else {
        return fetchedObjects;
    }
}

- (void) deleteFromCoreData {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSError *error;
    for (NSManagedObject *managedObject in self.currentEvent) {
        [context deleteObject:managedObject];
    }
    
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Event Deleted");
    
}

- (void) saveToCoreData:(PFObject *) postObject {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSURL *url = [NSURL URLWithString: [[postObject objectForKey:@"image1"] valueForKey:@"url"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *imageOne = [UIImage imageWithData:data];
    
    url = [NSURL URLWithString: [[postObject objectForKey:@"image2"] valueForKey:@"url"]];
    data = [NSData dataWithContentsOfURL:url];
    UIImage *imageTwo = [UIImage imageWithData:data];
    
    url = [NSURL URLWithString: [[postObject objectForKey:@"image3"] valueForKey:@"url"]];
    data = [NSData dataWithContentsOfURL:url];
    UIImage *imageThree = [UIImage imageWithData:data];
    
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"YourEvents"
                                   inManagedObjectContext: context];
    
    [dataRecord setValue: [postObject objectForKey:TurnipParsePostTitleKey] forKey:@"title"];
    [dataRecord setValue: postObject.objectId forKey:@"objectId"];
    [dataRecord setValue: [postObject objectForKey:TurnipParsePostAddressKey] forKey:@"location"];
    [dataRecord setValue: [postObject objectForKey:TurnipParsePostTextKey] forKey:@"text"];
    [dataRecord setValue: [postObject objectForKey:TurnipParsePostPriceKey] forKey:@"price"];
    [dataRecord setValue: [postObject objectForKey:TurnipParsePostDateKey] forKey:@"date"];
    [dataRecord setValue: [postObject objectForKey:@"endDate"] forKey:@"endDate"];
    [dataRecord setValue: imageOne forKey:@"image1"];
    [dataRecord setValue: imageTwo forKey:@"image2"];
    [dataRecord setValue: imageThree forKey:@"image3"];
    [dataRecord setValue: [[postObject objectForKey:@"neighbourhood"] valueForKey:@"name"] forKey:@"neighbourhood"];
    
    BOOL privateBool = [[postObject objectForKey:TurnipParsePostPrivateKey] boolValue];
    BOOL paidBool = [[postObject objectForKey:TurnipParsePostPaidKey] boolValue];
    
    NSNumber *privateAsNumber = [NSNumber numberWithBool: privateBool];
    [dataRecord setValue: privateAsNumber forKey:@"private"];
    
    NSNumber *freeAsNumber = [NSNumber numberWithBool: paidBool];
    [dataRecord setValue: freeAsNumber forKey:@"free"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Event saved");
    
}

- (void) checkLocalEvent {
    _currentEvent = [[NSArray alloc] initWithArray:[self loadCoreData]];
    
    if ([_currentEvent count] != 0 ) {
        NSDate *endDate = [[_currentEvent valueForKey:@"endDate"] objectAtIndex:0];
        if([endDate isEqual:[NSNull null]]) {
            [self deleteFromCoreData];
            
            PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
            
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            
            [query includeKey:@"neighbourhood"];
            
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error && ![object isEqual:[NSNull null]]) {
                    //Save to core data
                    [self saveToCoreData:object];
                } else {
                    [ParseErrorHandlingController handleParseError:error];
                }
            }];
        }
         else if ([[[_currentEvent valueForKey:@"endDate"] objectAtIndex:0] timeIntervalSinceNow] < 0.0) {
            //Delete core data
            [self deleteFromCoreData];
        }
    } else {
        PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
        
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        
        [query includeKey:@"neighbourhood"];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if(!error && ![object isEqual:[NSNull null]]) {
                //Save to core data
                [self saveToCoreData:object];
            } else {
                [ParseErrorHandlingController handleParseError:error];
            }
        }];
    }
}


#pragma mark - Parse

- (void) checkNotificationCount {
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    //[query whereKey:@"objectId" equalTo:[PFUser currentUser]];
    
    [query selectKeys:@[@"nrOfNotifications", @"nrOfMessages"]];
    
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if(!error) {
            NSString *notes = [[object objectForKey:@"nrOfNotifications"] stringValue];
            NSString *messages = [[object objectForKey:@"nrOfMessages"] stringValue];
            
            if (![notes isEqualToString:@"0"]) {
                [[[[[self tabBarController] tabBar] items] objectAtIndex: TurnipTabNotification] setBadgeValue:notes];
            }
            
            if (![messages isEqualToString:@"0"]) {
                [[[[[self tabBarController] tabBar] items] objectAtIndex: TurnipTabMessage] setBadgeValue:messages];
            }

        } else {
            [ParseErrorHandlingController handleParseError:error];
        }
    }];
}

@end
