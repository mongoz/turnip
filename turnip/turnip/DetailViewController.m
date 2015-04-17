//
//  DetailViewController.m
//  turnip
//
//  Created by Per on 1/14/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ScannerViewController.h"
#import "MessagingViewController.h"
#import "SWRevealViewController.h"
#import "DetailViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface DetailViewController ()

@property (nonatomic, strong) NSArray *accepted;
@property (nonatomic, assign) BOOL isFullscreen;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation DetailViewController

@synthesize event;

- (void) viewWillAppear:(BOOL)animated {
   if (self.host) {
        [self.navigationController.topViewController.navigationItem setHidesBackButton:YES];
        [self.tabBarController.tabBar setHidden:NO ];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.requestButton.enabled = NO;
    self.isFullscreen = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userWasAccepted:) name:TurnipUserWasAcceptedNotification object:nil];
    
    if (self.host) {
        self.deleted = NO;
        SWRevealViewController *revealViewController = self.revealViewController;
        if ( revealViewController )
        {
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
            
        }
        [self hostDetailSetupView];
        [self queryForAcceptedUsers];
    }
    
   else if (event != nil) {
       [self.navigationController.topViewController.navigationItem setRightBarButtonItem:nil];
        self.objectId = [event valueForKey:@"objectId"];
        self.navigationItem.title = [event valueForKey:@"title"];
        [self downloadDetails];
        self.profileImage.userInteractionEnabled = YES;
    }
}

- (void) userWasAccepted: (NSNotification *) note {
    [self queryForAcceptedUsers];
}

- (void) hostDetailSetupView {
    
    // Initialize the refresh control.
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    
    self.messageButton.hidden = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(queryForAcceptedUsers) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    self.navigationController.navigationBar.topItem.title = [[self.yourEvent valueForKey:@"title"] objectAtIndex:0];
    self.objectId = [[self.yourEvent valueForKey:@"objectId"] objectAtIndex:0];
    self.requestButton.hidden = YES;
    self.backNavigationButton.hidden = YES;
    self.tableView.hidden = NO;
    
    self.nameLabel.text = [[PFUser currentUser] valueForKey:@"name"];
    self.aboutLabel.text = [[self.yourEvent valueForKey:@"text"] objectAtIndex:0];
    self.dateLabel.text = [self convertDate:[[self.yourEvent valueForKey:@"date"] objectAtIndex:0]];
    self.neighbourhoodLabel.text = [[self.yourEvent valueForKey:@"neighbourhood"] objectAtIndex:0];
    
    if ([[self.yourEvent valueForKey:@"image1"] objectAtIndex:0] != (id)[NSNull null]) {
        self.imageView1.image = [[self.yourEvent valueForKey:@"image1"] objectAtIndex:0];
    }
    
    if ([[self.yourEvent valueForKey:@"image2"] objectAtIndex:0] != (id)[NSNull null]) {
        self.imageView2.image = [[self.yourEvent valueForKey:@"image2"] objectAtIndex:0];
    }
    
    if ([[self.yourEvent valueForKey:@"image3"] objectAtIndex:0] != (id)[NSNull null]) {
        self.imageView3.image = [[self.yourEvent valueForKey:@"image3"] objectAtIndex:0];
    }
    
    
    if ([[[self.yourEvent valueForKey:@"private"] objectAtIndex:0] boolValue]) {
        self.openLabel.text = @"Private";
    } else {
        self.openLabel.text = @"Public";
    }

    if ([[[self.yourEvent valueForKey:@"free"] objectAtIndex:0] boolValue]) {
        self.freePaidLabel.text = @"Free";
    } else {
        self.freePaidLabel.text = [NSString stringWithFormat:@"$%@", [[self.yourEvent valueForKey:@"price"] objectAtIndex:0]];
    }
    
    [self downloadFacebookProfilePicture:[[PFUser currentUser] valueForKey:@"facebookId" ]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateUI : (PFObject *) data{
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(queryForAcceptedUsers) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    self.navigationItem.title = [data objectForKey:TurnipParsePostTitleKey];
    
    NSArray *name = [[[data objectForKey:TurnipParsePostUserKey] valueForKey:@"name"] componentsSeparatedByString: @" "];
    
    self.nameLabel.text = [name objectAtIndex:0];
    self.aboutLabel.text = [data objectForKey:TurnipParsePostTextKey];
    self.neighbourhoodLabel.text = [[data objectForKey:@"neighbourhood"] valueForKey:@"name"];
    
    self.dateLabel.text = [self convertDate:[data objectForKey:TurnipParsePostDateKey]];
    
    if ([[[data objectForKey:TurnipParsePostUserKey] objectId] isEqual:[PFUser currentUser].objectId]) {
        self.requestButton.hidden = YES;
        self.messageButton.hidden = YES;
        self.tableView.hidden = NO;
        [self queryForAcceptedUsers];
    }
    
    if ([[data objectForKey:TurnipParsePostPrivateKey] isEqual:@"True"]) {
        self.openLabel.text = @"Private";
    } else if([[data objectForKey:TurnipParsePostPrivateKey] isEqual:@"False"]) {
        self.openLabel.text = @"Public";
        self.requestButton.hidden = YES;
        NSLog(@"public");
        self.attendButton.hidden = NO;
    }
    
    if ([[data objectForKey:TurnipParsePostPaidKey] isEqual:@"True"]) {
        self.freePaidLabel.text = @"Free";
    } else if([[data objectForKey:TurnipParsePostPaidKey] isEqual:@"False"]) {
        self.freePaidLabel.text = [NSString stringWithFormat:@"$%@",[data objectForKey:TurnipParsePostPriceKey]];
    }
}

- (void) downloadImages: (PFObject *) data {

    if([data objectForKey:@"image1"] != nil) {
        self.imageView1.file = (PFFile *)[data objectForKey:@"image1"];; // remote image
        [self.imageView1 loadInBackground];
    } else {
        self.imageView1.hidden = YES;
    }
    
    if([data objectForKey:@"image2"] != nil) {
        self.imageView2.file = (PFFile *)[data objectForKey:@"image2"];; // remote image
        [self.imageView2 loadInBackground];
    } else {
        self.imageView2.hidden = YES;
    }
    
    if([data objectForKey:@"image3"] != nil) {
        self.imageView3.file = (PFFile *)[data objectForKey:@"image3"];; // remote image
        [self.imageView3 loadInBackground];
    } else {
        self.imageView3.hidden = YES;
    }
    if ([[data objectForKey:TurnipParsePostUserKey] valueForKey:@"profileImage"] != nil) {
        NSURL *url = [NSURL URLWithString: [[data objectForKey:TurnipParsePostUserKey] valueForKey:@"profileImage"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.profileImage.image = [UIImage imageWithData:data];
    } else {
        [self downloadFacebookProfilePicture:[data[@"user"] objectForKey:@"facebookId"]];
    }
}

#pragma mark -
#pragma mark tap gestures

- (IBAction)profileImageTapHandler:(UITapGestureRecognizer *)sender {

    [self performSegueWithIdentifier:@"profileSegue" sender: [[self.data valueForKey:@"user"] objectAtIndex:0]];
}

- (IBAction)image1TapHandler:(UITapGestureRecognizer *)sender {
    if (!self.isFullscreen && self.imageView1.image != nil) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            //save previous frame
            self.fullScreenImageView.hidden = NO;
            self.fullScreenImage.image = self.imageView1.image;
            if (![self.navigationController.navigationBar isHidden]) {
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            }
        }completion:^(BOOL finished){
            self.isFullscreen = YES;
        }];
    }
}

- (IBAction)image2TapHandler:(UITapGestureRecognizer *)sender {
    if (!self.isFullscreen && self.imageView2.image != nil) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            //save previous frame
            self.fullScreenImageView.hidden = NO;
            self.fullScreenImage.image = self.imageView2.image;
            
            if (![self.navigationController.navigationBar isHidden]) {
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            }
            
        }completion:^(BOOL finished){
            self.isFullscreen = YES;
        }];
    }

}

- (IBAction)image3TapHandler:(UITapGestureRecognizer *)sender {
    if (!self.isFullscreen && self.imageView3.image != nil) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            //save previous frame
            self.fullScreenImageView.hidden = NO;
            self.fullScreenImage.image = self.imageView3.image;
            if (![self.navigationController.navigationBar isHidden]) {
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            }
        }completion:^(BOOL finished){
            self.isFullscreen = YES;
        }];
    }
}

- (IBAction)fullScreenImageHandler:(UITapGestureRecognizer *)sender {
    if (self.isFullscreen) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            //save previous frame
            self.fullScreenImageView.hidden = YES;
            self.fullScreenImage.image = nil;
            
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            
        }completion:^(BOOL finished){
            self.isFullscreen = NO;
        }];
    }

}

#pragma mark -
#pragma mark button Handlers

- (IBAction)messageButton:(id)sender {
    //detailsToMessageSegue
}


- (IBAction)attendButton:(id)sender {
    
    PFObject *object = [PFObject objectWithoutDataWithClassName:TurnipParsePostClassName objectId:self.objectId];
    
    PFRelation *relation = [object relationForKey:@"accepted"];
    [relation addObject:[PFUser currentUser]];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"could not add to accepted");
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

- (IBAction)requestButtonHandler:(id)sender {
    
    NSString *host = [[[self.data valueForKey:@"user"] valueForKey:@"objectId"] objectAtIndex:0];
    NSArray *name = [[[PFUser currentUser] objectForKey:@"name"] componentsSeparatedByString: @" "];

    NSString *message = [NSString stringWithFormat:@"%@ Wants to go to your party", [name objectAtIndex:0]];
    
    self.requestButton.enabled = NO;
    
    [PFCloud callFunctionInBackground:@"requestEventPush"
                       withParameters:@{@"recipientId": host, @"message": message, @"eventId": [[self.data valueForKey:TurnipParsePostIdKey] objectAtIndex:0] }
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"push sent");
                                    }
                                }];
}

#pragma mark - TableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.accepted count] > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else {
        // Display a message when the table is empty
        messageLabel.text = @"You have no person going to your party. Please pull down to refresh.";
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
    return [self.accepted count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"acceptedCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }

    cell.textLabel.text = [[self.accepted valueForKey:@"name"] objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"profile"];
    
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[self.accepted valueForKey:@"facebookId"] objectAtIndex:indexPath.row]]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
    
    // Run network request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil && data != nil) {
             // Set the image in the header imageView
             cell.imageView.image = [UIImage imageWithData:data];
         }
     }];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
}

#pragma mark - Parse queries

- (void) queryForAcceptedUsers {
    PFQuery *query = [PFQuery queryWithClassName: TurnipParsePostClassName];
    
    if ([self.accepted count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query getObjectInBackgroundWithId: self.objectId block:^(PFObject *object, NSError *error) {
        if(error) {
            NSLog(@"Error in query!: %@", error);
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                PFRelation *relation = [object relationForKey:@"accepted"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [self.refreshControl endRefreshing];
                    if([objects count] == 0) {
                    } else {
                        self.accepted = [[NSArray alloc] initWithArray:objects];
                        [[self tableView] reloadData];
                    }
                }];
            });
        }
    }];
}

- (void) downloadDetails {
    
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [query includeKey:TurnipParsePostUserKey];
    [query includeKey:@"neighbourhood"];
    [query whereKey:TurnipParsePostIdKey equalTo:self.objectId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"Error in query!: %@", error);
        } else {
            if ([[object objectForKey:@"denied"] containsObject:[PFUser currentUser].objectId]) {
                NSLog(@"denied");
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    PFRelation *acceptedRelation = [object relationForKey:@"accepted"];
                    PFQuery *query = [acceptedRelation query];
                    [query whereKey:TurnipParsePostIdKey equalTo:[PFUser currentUser].objectId];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if ([objects count] == 0) {
                            PFRelation *requestRelation = [object relationForKey:@"requests"];
                            PFQuery *query = [requestRelation query];
                            [query whereKey:TurnipParsePostIdKey equalTo:[PFUser currentUser].objectId];
                            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                if ([objects count] == 0) {
                                    self.requestButton.enabled = YES;
                                }
                            }];
                        } else {
                            self.requestButton.hidden = YES;
                            // Initialize the refresh control.
                            self.accepted = [[NSArray alloc] initWithArray:objects];
                            [[self tableView] reloadData];
                            self.tableView.hidden = NO;
                        }
                    }];
                });
            }
            self.data = [[NSArray alloc] initWithObjects:object, nil];
            [self downloadImages: object];
            [self updateUI: object];

        }
    }];
}

- (void) downloadFacebookProfilePicture: (NSString *) facebookId {
    
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
             self.profileImage.image = [UIImage imageWithData:data];
         }
     }];
}

#pragma mark -
#pragma mark NavigationBar items

- (IBAction)backNavigationButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sideMenuButton:(id)sender {
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController rightRevealToggleAnimated:YES];
}

#pragma mark -
#pragma mark utils

- (NSString *) convertDate: (NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSLocale *locale = [NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    
    [dateFormatter setDoesRelativeDateFormatting:YES];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

#pragma mark -
#pragma mark Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"profileSegue"]) {
        
        ProfileViewController *destViewController = segue.destinationViewController;
        
        destViewController.user = sender;
    }
    
    if ([segue.identifier isEqualToString:@"detailsToMessageSegue"]) {
        MessagingViewController *destViewController = segue.destinationViewController;
        destViewController.user = [[self.data valueForKey:@"user"] objectAtIndex:0];
    }
}


@end
