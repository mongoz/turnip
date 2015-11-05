//
//  SAEEventFeedViewController.m
//  turnip
//
//  Created by Per on 8/4/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEAttendingTableViewController.h"
#import "SAEHostSingleton.h"
#import "ProfileViewController.h"
#import "SAEEventFeedViewController.h"
#import "SAEEventFeedViewCell.h"
#import "SAEDetailsViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "SAEUtilityFunctions.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "ParseErrorHandlingController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Constants.h"
#import "SAEEvent.h"

@interface SAEEventFeedViewController () <SAEEventFeedViewCellDelegate>

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL firstTime;
@property (nonatomic, strong) SAEHostSingleton *hostedEvent;

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
    
    [self.activityIndicator startAnimating];
    [self queryEvents];
}


- (void) queryEvents {
    
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
                 NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                
                for (PFObject *event in objects) {
                    
                    PFRelation *relation = [event relationForKey:@"accepted"];
                    PFQuery *query2 = [relation query];
                    [query2 findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                        if (!error) {
                            
                            SAEEvent *newEvent = [[SAEEvent alloc] initWithImage:[event valueForKey:@"image1"]
                                                                        objectId:[event objectId]
                                                                           title:[event valueForKey:@"title"]
                                                                            date:[event valueForKey:@"date"]
                                                                            host:[event valueForKey:@"user"]
                                                                       attendees:users
                                                                       isPrivate:[[event valueForKey:@"private"] boolValue]];
                            
                           
                            [tempArray addObject:newEvent];
                            
                            counter++;
                            if ([objects count] == counter) {
                                // Sort array
                                [self sortEventArray:tempArray];
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

- (void) sortEventArray:(NSArray *) events {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.events = [events sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.events count] > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else {
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
    
    return imageSize.height + 125.0f; // Add 1.0f for the cell separator height
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
    
    cell.delegate = self;
    
    // Configure the cell
    PFFile *thumbnail = [[self.events objectAtIndex:indexPath.row] valueForKey:@"eventImage"];
    
    //Use a placeholder image before we have downloaded the real one.
    cell.eventImage.file = thumbnail;
    
    if ([[[self.events objectAtIndex:indexPath.row] valueForKey:@"host"] objectForKey:@"profileImage"] != nil) {
        NSURL *url = [NSURL URLWithString: [[[self.events objectAtIndex:indexPath.row] valueForKey:@"host"] objectForKey:@"profileImage"]];
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
        [self downloadFacebookProfilePicture:[[[self.events objectAtIndex:indexPath.row] valueForKey:@"host"] objectForKey:@"facebookId"] andForCell:cell];
    }
    
    cell.nameLabel.text = [[[self.events objectAtIndex:indexPath.row] valueForKey:@"host"] objectForKey:@"firstName"];
    
    NSInteger attendingCount = [[[self.events valueForKey:@"attendees"] objectAtIndex:indexPath.row] count];
    NSString *string = [NSString stringWithFormat:@"Attending %ld", (long)attendingCount];
    
    [cell.attendingButton setTitle:string forState:UIControlStateNormal];
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
    self.hostedEvent = [SAEHostSingleton sharedInstance];
    
    NSArray *tempArray = [[NSArray alloc] initWithArray:[self loadCoreData]];
    
    if ([tempArray count] != 0 ) {
        
        self.hostedEvent.title = [[tempArray valueForKey:@"title"] objectAtIndex:0];
        self.hostedEvent.address = [[tempArray valueForKey:@"location"] objectAtIndex:0];
        self.hostedEvent.text = [[tempArray valueForKey:@"text"] objectAtIndex:0];
        self.hostedEvent.isPrivate = [[[tempArray valueForKey:@"private"] objectAtIndex:0] boolValue];
        self.hostedEvent.isFree = [[[tempArray valueForKey:@"free"] objectAtIndex:0] boolValue];
        self.hostedEvent.neighbourhood = [[tempArray valueForKey:@"neighbourhood"] objectAtIndex:0];
        self.hostedEvent.host = [PFUser currentUser];
        self.hostedEvent.startDate = [[tempArray valueForKey:@"date"] objectAtIndex:0];
        self.hostedEvent.endDate = [[tempArray valueForKey:@"endDate"] objectAtIndex:0];
        self.hostedEvent.saved = YES;
        self.hostedEvent.price = [[tempArray valueForKey:@"price"] objectAtIndex:0];
        self.hostedEvent.objectId = [[tempArray valueForKey:@"objectId"] objectAtIndex:0];
        self.hostedEvent.eventImage = [[tempArray valueForKey:@"image"] objectAtIndex:0];
        
        if([self.hostedEvent.endDate isEqual:[NSNull null]]) {
            [self deleteFromCoreData: tempArray];
            
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
        else if ([self.hostedEvent.endDate timeIntervalSinceNow] < 0.0) {
            //Delete core data
            [self deleteFromCoreData: tempArray];
        }
    } else {
        PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
        
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        
        [query includeKey:@"neighbourhood"];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if(!error && ![object isEqual:[NSNull null]]) {
                
                self.hostedEvent.title = [object objectForKey:TurnipParsePostTitleKey];
                self.hostedEvent.address = [object objectForKey:TurnipParsePostAddressKey];
                self.hostedEvent.text = [object objectForKey:TurnipParsePostTextKey];
                self.hostedEvent.isPrivate = [[object objectForKey:TurnipParsePostPrivateKey] boolValue];
                self.hostedEvent.isFree = [[object objectForKey:TurnipParsePostPaidKey] boolValue];
                self.hostedEvent.neighbourhood = [[object objectForKey:@"neighbourhood"] valueForKey:@"name"];
                self.hostedEvent.host = [PFUser currentUser];
                self.hostedEvent.startDate = [object objectForKey:TurnipParsePostDateKey];
                self.hostedEvent.endDate = [object objectForKey:TurnipParsePostendDateKey];
                self.hostedEvent.saved = YES;
                self.hostedEvent.price = [object objectForKey:TurnipParsePostPriceKey];
                self.hostedEvent.objectId = [object objectId];
                
                PFFile *imageFile = [object objectForKey:TurnipParsePostImageOneKey];
                
                [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        self.hostedEvent.eventImage = [UIImage imageWithData:imageData];
                    }
                }];

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
    [dataRecord setValue: imageOne forKey:@"image"];
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

- (void) deleteFromCoreData: (NSArray *) event {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSError *error;
    for (NSManagedObject *managedObject in event) {
        [context deleteObject:managedObject];
    }
    
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    self.hostedEvent.saved = NO;
    NSLog(@"Event Deleted");
    
}

#pragma mark - EventFeedViewCellDelegate

- (void) eventFeedViewCellAttendButton:(SAEEventFeedViewCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *eventId = [[self.events objectAtIndex:indexPath.row] valueForKey:TurnipParsePostIdKey];
    BOOL isPrivate = [[[self.events objectAtIndex:indexPath.row] valueForKey:TurnipParsePostPrivateKey] boolValue];
    
    if (isPrivate) {
        //send request
        NSString *host = [[[self.events objectAtIndex:indexPath.row] valueForKey:@"host"] objectForKey:@"firstName"];
        NSString *message = [NSString stringWithFormat:@"%@ Wants to go to your party", [[PFUser currentUser] objectForKey:@"firstName"]];
        
        [PFCloud callFunctionInBackground:@"requestEventPush"
                           withParameters:@{@"recipientId": host, @"message": message, @"eventId": eventId }
                                    block:^(NSString *success, NSError *error) {
                                        if (!error) {
                                            NSLog(@"push sent");
                                        }
                                    }];
        
    } else {
        //get a ticket
        PFObject *object = [PFObject objectWithoutDataWithClassName:TurnipParsePostClassName objectId:eventId];
        
        PFRelation *relation = [object relationForKey:@"accepted"];
        [relation addObject:[PFUser currentUser]];
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"could not add to acceptedL %@", error);
            } else if(succeeded) {
                //add to notification class
                NSString *message = [NSString stringWithFormat:@"Your ticket for %@ (tap to view ticket)", self.navigationItem.title];
                
                PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
                notification[@"type"] = @"ticket";
                notification[@"notification"] = message;
                notification[@"event"] = object;
                notification[@"user"] = [PFUser currentUser];
                notification[@"eventTitle"] = self.navigationItem.title;
                
                [notification saveInBackground];
            }
        }];
    }
    
    cell.attendButton.enabled = NO;
    
}

- (void) eventFeedViewCellAttendingButton:(SAEEventFeedViewCell *)cell {
    [self performSegueWithIdentifier:@"attendingSegue" sender:nil];
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if ([segue.identifier isEqualToString:@"showDetailsSegue"]) {
        SAEDetailsViewController *destViewController = segue.destinationViewController;
        
        destViewController.event = [self.events objectAtIndex:indexPath.row];

    }
    
    if ([segue.identifier isEqualToString:@"profileViewSegue"]) {
        ProfileViewController *destViewController = segue.destinationViewController;
        
        destViewController.user = [[self.events objectAtIndex:indexPath.row] valueForKey:@"host"];
    }
    
    if([segue.identifier isEqualToString:@"attendingSegue"]) {
        SAEAttendingTableViewController *destViewController = segue.destinationViewController;
        destViewController.attendees = [[self.events objectAtIndex:indexPath.row] valueForKey:@"attendees"];
        
    }
}

#pragma mark - gestureRecognizer

- (IBAction)imageTapRecognizer:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"showDetailsSegue" sender:self];
}

- (IBAction)profileImageTapRecognizer:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"profileViewSegue" sender:self];
}
@end
