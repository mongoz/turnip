//
//  TeammateTableViewController.m
//  turnip
//
//  Created by Per on 2/24/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "TeammateTableViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>

#import "TeammateTableViewCell.h"

@interface TeammateTableViewController () <TeammateCellDelegate>

@property (nonatomic, assign) NSUInteger nbItems;
@property (nonatomic, strong) PFObject *event;

@property (nonatomic, assign) BOOL isClicked;

@end

@implementation TeammateTableViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.accepted = [[NSArray alloc] init];
    [self queryAccepted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
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
    
    NSArray *name = [[[self.accepted valueForKey:@"name"] objectAtIndex: indexPath.row] componentsSeparatedByString: @" "];
    NSString *label = [NSString stringWithFormat:@"%@", [name objectAtIndex:0]];
    
    cell.profileImage.image = [UIImage imageNamed:@"Placeholder.jpg"];
    
    [cell.imageSpinner setHidden:NO];
    [cell.imageSpinner startAnimating];
    
    //Download facebook image
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[self.accepted valueForKey:@"facebookId"] objectAtIndex:indexPath.row]]];
    
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
    
    
    cell.nameLabel.text = label;
    
    return cell;
}

#pragma mark - Parse query

- (void) queryAccepted {
    
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    if ([self.accepted count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query whereKey:TurnipParsePostUserKey equalTo: [PFUser currentUser]];
    
    [query selectKeys:@[TurnipParsePostIdKey, @"accepted"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error in geo query!: %@", error);
        } else {
            self.eventId = [[objects valueForKey:@"objectId"] objectAtIndex:0];
            for (PFObject *object in objects) {
                self.event = object;
                PFRelation *relation = [object relationForKey:@"accepted"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([objects count] == 0) {
                            NSLog(@"no requests");
                        } else {
                            self.accepted = [[NSArray alloc] initWithArray:objects];
                            self.nbItems = [self.accepted count];
                            [[self tableView] reloadData];
                        }
                    });
                }];
            }
        }
    }];
}

- (void) teammateCellAddWasTapped:(TeammateTableViewCell*) cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSArray *user = [[self.accepted objectAtIndex:indexPath.row] copy];
    
    if (!self.isClicked) {
        self.isClicked = YES;
        [cell.checkButton setImage:[UIImage imageNamed:@"teammate-pressed"] forState: UIControlStateNormal];
        
        [PFCloud callFunctionInBackground:@"teammateCloudCode"
                           withParameters:@{@"user": user , @"eventId": self.eventId, @"state": @"add"}
                                    block:^(NSString *success, NSError *error) {
                                        if (!error) {
                                            NSLog(@"user Added");
                                        }
                                    }];
        NSLog(@"clicked");
    } else {
        self.isClicked = NO;
        [cell.checkButton setImage:[UIImage imageNamed:@"add-teammate"] forState: UIControlStateNormal];
        NSLog(@"unclicked");
        
        [PFCloud callFunctionInBackground:@"teammateCloudCode"
                           withParameters:@{@"user": user , @"eventId": self.eventId, @"state": @"remove"}
                                    block:^(NSString *success, NSError *error) {
                                        if (!error) {
                                            NSLog(@"user removed");
                                        }
                                    }];

    }
}

@end
