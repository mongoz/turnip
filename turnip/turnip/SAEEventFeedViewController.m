//
//  SAEEventFeedViewController.m
//  turnip
//
//  Created by Per on 8/4/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEEventFeedViewController.h"
#import "SAEEventDetailsViewController.h"
#import "SAEEventFeedViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "SAEUtilityFunctions.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "ParseErrorHandlingController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Constants.h"

@interface SAEEventFeedViewController ()

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL firstTime;
@property (nonatomic, strong) NSArray *currentEvent;

@end

@implementation SAEEventFeedViewController

- (void) locationManagerDidUpdateLocation:(CLLocation *)location {
    self.currentLocation = location;
    if (self.firstTime) {
        self.firstTime = NO;
        [self queryEvents];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [[SAELocationManager sharedInstance] addLocationManagerDelegate: self];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[SAELocationManager sharedInstance] removeLocationManagerDelegate:self];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"turnip.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(queryEvents) forControlEvents:UIControlEventValueChanged];
    
    self.firstTime = YES;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.activityIndicator.color = [UIColor blackColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = self.activityIndicator;
    
    [self checkLocalEvent];
    [self queryEvents];
}


- (void) queryEvents {
    
    [self.activityIndicator startAnimating];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude
                                               longitude:self.currentLocation.coordinate.longitude];
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    [query includeKey:@"user"];
    
    [query whereKey:@"location"
       nearGeoPoint:point
        withinMiles:TurnipPostMaximumSearchDistance];
    
     __block NSInteger counter = 0;
    
    [query orderByAscending:TurnipParsePostDateKey];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            [ParseErrorHandlingController handleParseError:error];
        } else {
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            
            if ([objects count] != 0) {
                self.events = [[NSMutableArray alloc] initWithCapacity:[objects count]];
                
                for (PFObject *event in objects) {
                    
                    PFRelation *relation = [event relationForKey:@"accepted"];
                    PFQuery *query2 = [relation query];
                    [query2 findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                        if (!error) {
                            [self.events addObject:@{ @"event": event,
                                                      @"users": users
                                                      }];
                            counter++;
                            if ([objects count] == counter) {
                                
                                // Sort array
                                [self sortEventArray];
                                [self.tableView reloadData];
                            }
                        } else {
                            [ParseErrorHandlingController handleParseError:error];
                        }
                    }];
                }
            }
        }
    }];
}

- (void) sortEventArray {
    NSLog(@"events :%@", self.events);
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [self.events sortedArrayUsingDescriptors:sortDescriptors];
    NSLog(@"-0------------");
    NSLog(@"sorted :%@", sortedArray);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.events count] > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else if(![self.activityIndicator isAnimating]){
        // Display a message when the table is empty
        messageLabel.text = @"No events nearby";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Arial-Bold" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
    }
    return 0;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showEventDetailsSeque" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static SAEEventFeedViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    });
    
    return [self calculateHeightForCell:sizingCell];
}

- (CGFloat)calculateHeightForCell:(SAEEventFeedViewCell *) cell {
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    
    CGSize size = self.tableView.frame.size;
    
    cell.imageView.frame = CGRectMake(0, 0, size.width, size.width);
    
    CGSize imageSize = cell.imageView.frame.size;
    
    return imageSize.height + 55.0f; // Add 1.0f for the cell separator height
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"eventCell";
    SAEEventFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[SAEEventFeedViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    
    // Configure the cell
    PFFile *thumbnail = [[[self.events valueForKey:@"event"] objectAtIndex:indexPath.row] valueForKey:TurnipParsePostImageOneKey];
    
    //Use a placeholder image before we have downloaded the real one.
    cell.eventImage.file = thumbnail;
    
    if ([[[[self.events valueForKey:@"event"] objectAtIndex:indexPath.row] valueForKey:@"user"] objectForKey:@"profileImage"] != nil) {
        NSURL *url = [NSURL URLWithString: [[[[self.events valueForKey:@"event"] objectAtIndex:indexPath.row] valueForKey:@"user"] objectForKey:@"profileImage"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.center = cell.profileImage.center;
        [self.view addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        
        
        __weak SAEEventFeedViewCell *weakCell = cell;
        [cell.profileImage setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              
                                              [activityIndicatorView removeFromSuperview];
                                              
                                              [weakCell.profileImage setImage:image];
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                              [activityIndicatorView removeFromSuperview];
                                              
                                          }];
    } else {
        [self downloadFacebookProfilePicture:[[[[self.events valueForKey:@"event"] objectAtIndex:indexPath.row] valueForKey:@"user"] objectForKey:@"facebookId"] andForCell:cell];
    }
    
    cell.nameLabel.text = [[[[self.events valueForKey:@"event"] objectAtIndex:indexPath.row] valueForKey:@"user"] objectForKey:@"firstName"];
    
    NSInteger attendingCount = [[[self.events valueForKey:@"users"] objectAtIndex:indexPath.row] count];
    
    cell.attendingLabel.text = [NSString stringWithFormat:@"%ld attending", (long)attendingCount];
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
    cell.profileImage.clipsToBounds = YES;
    
    [cell.eventImage loadInBackground];
    
    return cell;
    
}

- (void) downloadFacebookProfilePicture: (NSString *) facebookId andForCell:(SAEEventFeedViewCell *) cell {
    
    // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
    
    // Run network request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil && data != nil) {
             // Set the image in the header imageView
             cell.profileImage.image = [UIImage imageWithData:data];
         }
     }];
}

#pragma mark - core Data

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

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEventDetailsSeque"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        SAEEventDetailsViewController *destViewController = segue.destinationViewController;
        
        destViewController.event = [[self.events valueForKey:@"event"] objectAtIndex:indexPath.row];

    }
}

@end
