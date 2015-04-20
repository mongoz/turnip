//
//  RequestTableViewController.m
//  turnip
//
//  Created by Per on 2/3/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "RequestViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "MCSwipeTableViewCell.h"
#import "Constants.h"

@interface RequestViewController ()

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSArray *requesters;
@property (nonatomic, assign) NSUInteger nbItems;
@property (nonatomic, strong) MCSwipeTableViewCell *cellToDelete;
@property (nonatomic, strong) NSMutableArray *userDelete;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation RequestViewController

@synthesize tableView;

NSArray *fetchedObjects;

- (void) receiveRequestPush:(NSNotification *) notification {
    if ([[notification name] isEqualToString:TurnipPartyRequestPushNotification]){
        [self queryRequesters];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.requesters = [[NSArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRequestPush:)
                                                 name:TurnipPartyRequestPushNotification
                                               object:nil];
    [self queryRequesters];
    
    self.userDelete = [[NSMutableArray alloc] init];
    
    // Initialize the refresh control.
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(queryRequesters) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) queryRequesters {
    
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    if ([self.requesters count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:TurnipParsePostUserKey equalTo: [PFUser currentUser]];
    
    [query selectKeys:@[TurnipParsePostIdKey, TurnipParsePostTitleKey, @"requests"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error in request query!: %@", error);
        } else {
            if ([objects count] != 0) {
                self.eventId = [[objects valueForKey:@"objectId"] objectAtIndex:0];
                self.events = [[objects valueForKey:@"title"] objectAtIndex:0];
                for (PFObject *object in objects) {
                    PFRelation *relation = [object relationForKey:@"requests"];
                    PFQuery *query = [relation query];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.refreshControl endRefreshing];
                            if([objects count] != 0) {
                                self.requesters = [[NSArray alloc] initWithArray:objects];
                                self.nbItems = [self.requesters count];
                                [[self tableView] reloadData];
                            }
                        });
                    }];
                }
            }
        }
    }];
}

- (void) deleteRequester: (NSArray * ) requester {
    
    PFUser *user = [PFUser objectWithoutDataWithClassName:@"_User" objectId:[requester valueForKey:@"objectId"]];
    
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    [query getObjectInBackgroundWithId:self.eventId block:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"Error in query: %@", error);
        } else {
            if (object != nil) {
                [object addUniqueObject:[requester valueForKey:@"objectId"] forKey:@"denied"];
                
                PFRelation *relation = [object relationForKey:@"requests"];
                [relation removeObject:user];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Error in save %@",error);
                    } else {
                        NSLog(@"saved");
                    }
                }];
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.requesters count] > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else {
        // Display a message when the table is empty
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.nbItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"requestCell";
    
    MCSwipeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // Remove inset of iOS 7 separators.
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        // Setting the background color of the cell.
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(MCSwipeTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIView *checkView = [self viewWithImageName:@"check"];
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
    
    UIView *crossView = [self viewWithImageName:@"cross"];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 /255.0 blue:14.0 / 255.0 alpha:1.0];
    
    // Setting the default inactive state color to the tableView background color
    [cell setDefaultColor:self.tableView.backgroundView.backgroundColor];
    
    [cell setDelegate:self];
    
    NSLog(@"request: %@", [self.requesters objectAtIndex:indexPath.row]);
    
    NSArray *name = [[[self.requesters valueForKey:@"name"] objectAtIndex: indexPath.row] componentsSeparatedByString: @" "];
    NSString *age = @([self calculateAge:[[self.requesters valueForKey:@"birthday"] objectAtIndex:indexPath.row]]).stringValue;
    NSString *label = [NSString stringWithFormat:@"%@  %@", [name objectAtIndex:0], age];
    
    cell.profileImage.image = [UIImage imageNamed:@"Placeholder.jpg"];
    
    [cell.imageSpinner setHidden:NO];
    [cell.imageSpinner startAnimating];
    
    if (![[[self.requesters valueForKey:@"profileImage"] objectAtIndex:indexPath.row] isEqual:[NSNull null]] ) {
        NSURL *url = [NSURL URLWithString: [[self.requesters valueForKey:@"profileImage"] objectAtIndex:indexPath.row]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.profileImage.image = [UIImage imageWithData:data];
        [cell.imageSpinner setHidden:YES];
        [cell.imageSpinner stopAnimating];
    } else {
        //Download facebook image
        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[self.requesters valueForKey:@"facebookId"] objectAtIndex:indexPath.row]]];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        
        // Run network request asynchronously
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:
         ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
             if (connectionError == nil && data != nil) {
                 // Set the image in the header imageView
                 [cell.imageSpinner setHidden:YES];
                 [cell.imageSpinner stopAnimating];
                 cell.profileImage.image = [UIImage imageWithData:data];
             } else {
                 NSLog(@"connectionError: %@", connectionError);
             }
         }];
    }
    
    cell.personLabel.text = label;
    
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self deleteCell:cell];
        [self acceptUserRequest: [self.requesters objectAtIndex: indexPath.row]];
        [self.userDelete addObject: [self.requesters objectAtIndex:indexPath.row]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TurnipUserWasAcceptedNotification object:nil];
    }];
    
    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self deleteCell:cell];
        [self deleteRequester: [self.requesters objectAtIndex:indexPath.row]];
        [self.userDelete addObject:[self.requesters objectAtIndex:indexPath.row]];
    }];
    
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    tapped.numberOfTapsRequired = 1;
    [cell.profileImage addGestureRecognizer:tapped];
    cell.profileImage.userInteractionEnabled = YES;
}


- (void) imageTapped: (UITapGestureRecognizer *) gesture {
    CGPoint point = [gesture locationInView:self.tableView];
    
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:point];
    [self performSegueWithIdentifier:@"requestToProfileSegue" sender: [self.requesters objectAtIndex:path.row]];
    
}

- (void) deleteCell: (MCSwipeTableViewCell *) cell {
    NSParameterAssert(cell);
    
    _nbItems--;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) acceptUserRequest: (NSArray *) user {
    //send push to current user
    
    NSString *userId = [user valueForKey:@"objectId"];
    NSString *userEvent = self.eventId;
    NSString *message = [NSString stringWithFormat:@"You have been accepted to %@ (tap to view ticket)", self.events];
    
    [PFCloud callFunctionInBackground:@"acceptEventPush"
                       withParameters:@{@"recipientId": userId, @"message": message, @"eventId": userEvent, @"eventTitle": self.events}
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"push sent");
                                    }
                                }];
    
}

- (int) calculateAge: (NSString *) birthday {
    
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    int time = [todayDate timeIntervalSinceDate:[dateFormatter dateFromString: birthday]];
    int allDays = (((time / 60) / 60) / 24);
    int days = allDays % 365;
    int years = (allDays - days) / 365;
    
    return years;
}

- (UIView *) viewWithImageName: (NSString *) imageName {
    UIImage *image = [UIImage imageNamed: imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"requestToProfileSegue"]) {
        ProfileViewController *destViewController = segue.destinationViewController;
        
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        destViewController.user = sender;
    }
}

#pragma mark -
#pragma mark MCSwipeTableViewCell Delegates

- (void) deniedButtonWasTapped:(MCSwipeTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self deleteCell:cell];
    [self.userDelete addObject: [self.requesters objectAtIndex:indexPath.row]];
    [self deleteRequester: [self.requesters objectAtIndex:indexPath.row]];
}

- (void) acceptButtonWasTapped:(MCSwipeTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self deleteCell:cell];
    [self acceptUserRequest: [self.requesters objectAtIndex: indexPath.row]];
    [self.userDelete addObject: [self.requesters objectAtIndex:indexPath.row]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TurnipUserWasAcceptedNotification object:nil];

}


@end
