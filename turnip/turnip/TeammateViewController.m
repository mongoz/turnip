//
//  TeammateTableViewController.m
//  turnip
//
//  Created by Per on 2/24/15.
//  Copyright (c) 2015 Per. All rights reserved.
//
#import "ParseErrorHandlingController.h"
#import "TeammateViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import "SAEUtilityFunctions.h"
#import "TeammateTableViewCell.h"

@interface TeammateViewController () <TeammateCellDelegate>

@property (nonatomic, assign) NSUInteger nbItems;
@property (nonatomic, strong) PFObject *event;

@property (nonatomic, strong) NSMutableArray *currentTeammate;
@property (nonatomic, strong) NSMutableArray *users;

@property (nonatomic, assign) BOOL isClicked;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TeammateViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add a Teammate";
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 30.0f, 30.0f)];
    
    UIImage *backImage = [SAEUtilityFunctions imageResize: [UIImage imageNamed:@"backNav"] andResizeTo:CGSizeMake(30, 30)];
    [backButton setBackgroundImage:backImage  forState:UIControlStateNormal];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backNavigation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.currentTeammate = [[NSMutableArray alloc] init];
    self.users = [[NSMutableArray alloc] initWithCapacity:[self.accepted count]];
    
    // Initialize the refresh control.
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(queryTeammate) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    [self buildUsersArray];
    [self queryTeammate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.users count] > 0) {
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

- (TeammateTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *tableIdentifier = @"teammateCell";
    
    TeammateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[TeammateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    cell.delegate = self;
    
    NSArray *name = [[[self.users valueForKey:@"name"] objectAtIndex: indexPath.row] componentsSeparatedByString: @" "];
    NSString *label = [NSString stringWithFormat:@"%@", [name objectAtIndex:0]];
    
    [cell.imageSpinner setHidden:NO];
    [cell.imageSpinner startAnimating];
    
    if (![[[self.users valueForKey:@"profileImage"] objectAtIndex:indexPath.row] isEqualToString:@"nil"]) {
        NSURL *url = [NSURL URLWithString: [self.users valueForKey:@"profileImage"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.profileImage.image = [UIImage imageWithData:data];
    } else {
        // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[self.users valueForKey:@"facebookId"] objectAtIndex:indexPath.row]]];
        
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

             }
         }];
    }
    
    if ([[[self.users valueForKey:@"isTeammate"] objectAtIndex:indexPath.row] isEqualToString:@"YES"]) {
        [cell.checkButton setImage:[UIImage imageNamed:@"teammateselect"] forState: UIControlStateNormal];
        self.isClicked = YES;
    }
    
    
    cell.nameLabel.text = label;
    
    return cell;
}

#pragma mark - Parse query

- (void) queryTeammate {
    
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    if ([self.accepted count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:TurnipParsePostUserKey equalTo: [PFUser currentUser]];
    
    [query selectKeys:@[TurnipParsePostIdKey, TurnipParsePostTitleKey, @"teammate"]];
    
    [query getObjectInBackgroundWithId:self.eventId block:^(PFObject *object, NSError *error) {
        if(error) {
            NSLog(@"Error in geo query!: %@", error);
        } else {
            if (object != nil) {
                self.event = object;
                PFRelation *relation = [object relationForKey:@"teammate"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.refreshControl endRefreshing];
                        if([objects count] == 0) {
                            NSLog(@"no requests");
                        } else {
                            
                            for (NSString *object in objects) {
                                [self.currentTeammate addObject: [object valueForKey:@"objectId"]];
                                
                                if([[self.users valueForKey:@"objectId"] indexOfObject:[object valueForKey:@"objectId"]] != NSNotFound) {
                                    NSInteger indexValue = [[self.users valueForKey:@"objectId"] indexOfObject:[object valueForKey:@"objectId"]];
                                    
                                    NSMutableDictionary *mutableObject=[NSMutableDictionary dictionaryWithDictionary:self.users[indexValue]];
                                    [mutableObject setObject:@"YES" forKey:@"isTeammate"];
                                    [self.users replaceObjectAtIndex:indexValue withObject:mutableObject];
                                }
                            }
                            self.nbItems = [self.users count];
                            [self.tableView reloadData];
                            
                        }
                    });
                }];
            }
        }
    }];
}


- (void) teammateCellAddWasTapped:(TeammateTableViewCell*) cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *userId = [[self.users valueForKey:@"objectId"] objectAtIndex: indexPath.row];
    
    if (!self.isClicked) {
        self.isClicked = YES;
        [cell.checkButton setImage:[UIImage imageNamed:@"teammateselect"] forState: UIControlStateNormal];
        
        [self.currentTeammate addObject:userId];
        
    } else {
        self.isClicked = NO;
        [cell.checkButton setImage:nil forState: UIControlStateNormal];
                
        [self.currentTeammate removeObject: userId];
    }
}
-(void) backNavigation {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addButton:(id)sender {
    
    [PFCloud callFunctionInBackground:@"teammateCloudCode1"
                       withParameters:@{@"teammate": self.currentTeammate, @"eventName": [self.event objectForKey:@"title"], @"eventId": self.eventId}
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"user Added");
                                    }
                                }];
}

#pragma mark - utils


- (void) buildUsersArray {
    NSString *image;
    
    for (NSString *user in self.accepted) {
        
        if([user valueForKey:@"profileImage"] == nil) {
            image = @"nil";
        } else {
            image = [user valueForKey:@"profileImage"];
        }
        
        [self.users addObject:@{@"name": [user valueForKey:@"name"],
                                @"objectId": [user valueForKey:@"objectId"],
                                @"profileImage": image,
                                @"facebookId":[user valueForKey:@"facebookId"],
                                @"isTeammate": @"NO"}
         ];
    }
}
@end
