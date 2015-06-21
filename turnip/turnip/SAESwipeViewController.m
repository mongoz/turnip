//
//  SAESwipeViewController.m
//  turnip
//
//  Created by Per on 6/9/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAESwipeViewController.h"
#import "ParseErrorHandlingController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "Constants.h"

#define API_KEY @"AIzaSyCuVECTfnjZxMh8OdQgzOV4rClLfROUpOU"

//static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
//static const CGFloat ChoosePersonButtonVerticalPadding = -40.f;


@interface SAESwipeViewController()

@property (nonatomic, strong) NSString *neighbourhood;
@property (nonatomic, strong) NSMutableArray *event;
@property (nonatomic, assign) BOOL firstTime;

@end


@implementation SAESwipeViewController

- (void) locationManagerDidUpdateLocation:(CLLocation *)location {
    self.currentLocation = location;
    if (self.firstTime) {
        self.firstTime = NO;
        [self queryForAllEventsNearLocation:self.currentLocation];
    }

}

- (void) viewWillAppear:(BOOL)animated {
    [[SAELocationManager sharedInstance] addLocationManagerDelegate: self];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[SAELocationManager sharedInstance] removeLocationManagerDelegate:self];
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.firstTime = YES;
    
    self.event = [[NSMutableArray alloc] init];
    
    UIImage *image = [UIImage imageNamed:@"turnip.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
}

- (void) setupCardViews {
    
    // Display the first ChoosePersonView in front. Users can swipe to indicate
    // whether they like or dislike the person displayed.
    self.frontCardView = [self popEventViewWithFrame:[self frontCardViewFrame]];
    [self.view addSubview:self.frontCardView];
    
    // Display the second ChoosePersonView in back. This view controller uses
    // the MDCSwipeToChooseDelegate protocol methods to update the front and
    // back views after each user swipe.
    self.backCardView = [self popEventViewWithFrame:[self backCardViewFrame]];
    [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
    
    // Add buttons to programmatically swipe the view left or right.
    // See the `nopeFrontCardView` and `likeFrontCardView` methods.
//    [self constructNopeButton];
//    [self constructLikedButton];
}

#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentEvent.title);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"You noped %@.", self.currentEvent.title);
    } else {
        NSLog(@"You liked %@.", self.currentEvent.title);
        NSString *host = [_currentEvent.host valueForKey:@"objectId"];
        NSArray *name = [[[PFUser currentUser] objectForKey:@"name"] componentsSeparatedByString: @" "];
        
        NSString *message = [NSString stringWithFormat:@"%@ Wants to go to your party", [name objectAtIndex:0]];
        
        NSLog(@"host: %@",host);
        
        //    [PFCloud callFunctionInBackground:@"requestEventPush"
        //                       withParameters:@{@"recipientId": host, @"message": message, @"eventId": _currentEvent.eventId }
        //                                block:^(NSString *success, NSError *error) {
        //                                    if (!error) {
        //                                        NSLog(@"push sent");
        //                                    }
        //                                }];
    }
    
    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popEventViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(SAEChooseEventView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    self.currentEvent = frontCardView.event;
}


- (SAEChooseEventView *)popEventViewWithFrame:(CGRect)frame {
    if ([self.event count] == 0) {
        return nil;
    }
    
    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 100.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y - (state.thresholdRatio * 10.f),
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };
    
    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    SAEChooseEventView *eventView = [[SAEChooseEventView alloc] initWithFrame:frame
                                                                    event: self.event[0]
                                                                    options:options];
    [self.event removeObjectAtIndex:0];
    return eventView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 30.f;
    CGFloat bottomPadding = 170.f;
    return CGRectMake(horizontalPadding,
                      topPadding,
                      CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      CGRectGetHeight(self.view.frame) - bottomPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 10,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

//// Create and add the "nope" button.
//- (void)constructNopeButton {
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    UIImage *image = [UIImage imageNamed:@"nope"];
//    button.frame = CGRectMake(ChoosePersonButtonHorizontalPadding,
//                              CGRectGetMaxY(self.frontCardView.frame) + ChoosePersonButtonVerticalPadding,
//                              image.size.width,
//                              image.size.height);
//    [button setImage:image forState:UIControlStateNormal];
//    [button setTintColor:[UIColor colorWithRed:247.f/255.f
//                                         green:91.f/255.f
//                                          blue:37.f/255.f
//                                         alpha:1.f]];
//    [button addTarget:self
//               action:@selector(nopeFrontCardView)
//     forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
//}
//
//// Create and add the "like" button.
//- (void)constructLikedButton {
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    UIImage *image = [UIImage imageNamed:@"liked"];
//    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChoosePersonButtonHorizontalPadding,
//                              CGRectGetMaxY(self.frontCardView.frame) + ChoosePersonButtonVerticalPadding,
//                              image.size.width,
//                              image.size.height);
//    [button setImage:image forState:UIControlStateNormal];
//    [button setTintColor:[UIColor colorWithRed:29.f/255.f
//                                         green:245.f/255.f
//                                          blue:106.f/255.f
//                                         alpha:1.f]];
//    [button addTarget:self
//               action:@selector(likeFrontCardView)
//     forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
//}
//
//#pragma mark Control Events
//
//// Programmatically "nopes" the front card view.
//- (void)nopeFrontCardView {
//    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
//}
//
//// Programmatically "likes" the front card view.
//- (void)likeFrontCardView {
//    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
//}

- (IBAction)ignoreButton:(id)sender {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

- (IBAction)requestButton:(id)sender {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
    


}

#pragma mark - Parse

- (void) queryForAllEventsNearLocation: (CLLocation *) currentLocation {
    [self.activityIndicator startAnimating];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                                               longitude:currentLocation.coordinate.longitude];
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    if([self.event count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query selectKeys:@[TurnipParsePostTitleKey, TurnipParsePostPrivateKey, TurnipParsePostThumbnailKey, TurnipParsePostStartDateKey, TurnipParsePostIdKey, TurnipParsePostUserKey, TurnipParsePostLocationKey]];
    
    [query whereKey:@"location"
       nearGeoPoint:point
        withinMiles:TurnipPostMaximumSearchDistance];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            [ParseErrorHandlingController handleParseError:error];
        } else {
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
             self.backgroundLabel.hidden = NO;
            
            if ([objects count] != 0) {
                for (NSArray *event in objects) {
                    SAESwipeEvent *temp = [[SAESwipeEvent alloc] initWithTitle: [event valueForKey:@"title"] image: [event valueForKey:@"thumbnail"] host:[event valueForKey:@"user"] eventId:[event valueForKey:@"objectId"]];
                    [self.event addObject:temp];
                }
                [self setupCardViews];
            }
        }
    }];
}

- (void) queryForEventsInNeighbourhood {
    
}

- (void) getCurrentNeighbourhood {
    
    NSString *coords = [NSString stringWithFormat:@"%f, %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    
    // https://maps.googleapis.com/maps/api/geocode/json?address=2200%20colorado%20ave&components=administrative_area:Los%20angeles%20county|country:US&key=AIzaSyCuVECTfnjZxMh8OdQgzOV4rClLfROUpOU
    NSString *urlAsString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%@&key=%@", coords, API_KEY ];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            NSError *localError;
            NSMutableArray *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            NSString *neighbourhood;
            NSString *locality;
            NSString *adminArea;
        
            
            for (NSArray *data in [[[jsonDict valueForKey:@"results"] valueForKey:@"address_components"] objectAtIndex:0]) {
                if ([[[data valueForKey:@"types"] objectAtIndex:0] isEqualToString:@"locality"]) {
                    locality = [data valueForKey:@"long_name"];
                }
                
                if ([[[data valueForKey:@"types"] objectAtIndex:0] isEqualToString:@"neighborhood"]) {
                    neighbourhood = [data valueForKey:@"long_name"];
                }
                
                if ([[[data valueForKey:@"types"] objectAtIndex:0] isEqualToString:@"administrative_area_level_2"]) {
                    adminArea = [data valueForKey:@"long_name"];
                }
                if (neighbourhood == nil && [[[data valueForKey:@"types"] objectAtIndex:0] isEqualToString:@"sublocality_level_1"]) {
                    neighbourhood = [data valueForKey:@"long_name"];
                }
            }
            //            NSLog(@"----------------------------------");
            NSLog(@"neigbourhood: %@", neighbourhood);
            NSLog(@"locality: %@", locality);
            NSLog(@"adminArea: %@", adminArea);
            //            NSLog(@"----------------------------------");
            
//            if([locality isEqualToString:@"Los Angeles"]) {
//                self.neighbourhood = neighbourhood;
//            } else if ([neighbourhood isEqualToString:localityString]) {
//                self.neighbourhood = neighbourhood;
//            } else if([adminArea isEqualToString: @"Los Angeles County"]) {
//                self.neighbourhood = locality;
//            } else {
//                self.neighbourhood = neighbourhood;
//            }
            
            //  NSLog(@"self.neigh %@", self.neighbourhood);
        }
    }];

    

}

@end
