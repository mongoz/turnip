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

@end

@implementation RequestViewController

@synthesize tableView;

NSArray *fetchedObjects;

- (void) receiveRequestPush:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"requestPush"]){
        NSLog(@"reload page");
       // [self loadCoreData];
        [self.tableView reloadData];
    }
       
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

//- (void) viewWillDisappear:(BOOL)animated {
//    
//    NSLog(@"delete: %@", self.userDelete);
//    
//    [PFCloud callFunctionInBackground:@"deleteRelatedUsers"
//                       withParameters:@{@"deleteArray": self.userDelete}
//                                block:^(NSString *success, NSError *error) {
//                                    if (!error) {
//                                        NSLog(@"user Deleted");
//                                    }
//                                }];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.requesters = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRequestPush:)
                                                 name:@"requestPush"
                                               object:nil];
    [self queryRequesters];
    
    self.userDelete = [[NSMutableArray alloc] init];
    
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
    
    [query selectKeys:@[TurnipParsePostIdKey, @"requests"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error in geo query!: %@", error);
        } else {
            self.eventId = [objects[0] objectId];
            for (PFObject *object in objects) {
                PFRelation *relation = [object relationForKey:@"requests"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([objects count] == 0) {
                            NSLog(@"no requests");
                        } else {
                            self.requesters = [[NSArray alloc] initWithArray:objects];
                            self.nbItems = [self.requesters count];
                            [[self tableView] reloadData];
                        }
                    });
                }];
            }
        }
    }];
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
    
    // Setting the default inactive state color to the tableView background color
    [cell setDefaultColor:self.tableView.backgroundView.backgroundColor];
    
    [cell setDelegate:self];
    
    NSArray *name = [[[self.requesters valueForKey:@"name"] objectAtIndex: indexPath.row] componentsSeparatedByString: @" "];
    NSString *age = @([self calculateAge:[[self.requesters valueForKey:@"birthday"] objectAtIndex:indexPath.row]]).stringValue;
    NSString *label = [NSString stringWithFormat:@"%@  %@", [name objectAtIndex:0], age];
    
    cell.imageView.image = [UIImage imageNamed:@"Placeholder.jpg"];
    
    [cell.imageSpinner setHidden:NO];
    [cell.imageSpinner startAnimating];
    
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
             NSLog(@"image");
             [cell.imageSpinner setHidden:YES];
             [cell.imageSpinner stopAnimating];
             cell.imageView.image = [UIImage imageWithData:data];
         } else {
             NSLog(@"connectionError: %@", connectionError);
         }
     }];

    
    cell.textLabel.text = label;
    
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self deleteCell:cell];
        [self acceptUserRequest: [self.requesters objectAtIndex: indexPath.row]];
        [self.userDelete addObject: [self.requesters objectAtIndex:indexPath.row]];
    }];
    
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    tapped.numberOfTapsRequired = 1;
    [cell.imageView addGestureRecognizer:tapped];
    cell.imageView.userInteractionEnabled = YES;
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
    NSString *message = @"sure thing brah";
    
    [PFCloud callFunctionInBackground:@"acceptEventPush"
                       withParameters:@{@"recipientId": userId, @"message": message, @"eventId": userEvent}
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
    
    return  years;
}

- (void) swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    NSLog(@"did start swiping");
}

- (void) swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    NSLog(@"did end swiping");
}

- (UIView *) viewWithImageName: (NSString *) imageName {
    UIImage *image = [UIImage imageNamed: imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

#pragma mark core data handlers.

- (void) loadCoreData {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"RequesterInfo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    fetchedObjects = [context executeFetchRequest:fetchRequest error: &error];
    
    if([fetchedObjects count] > 0) {
        _nbItems = [fetchedObjects count];
    } else {
        
    }
}


- (void) deleteObjectFromCoreData: (NSMutableArray * ) user {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"RequesterInfo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"objectId = %@", [user valueForKey:@"objectId"]];
    [fetchRequest setPredicate: searchFilter];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:fetchRequest error: &error];
    
    for (NSManagedObject *managedObject in array) {
        [context deleteObject:managedObject];
    }
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Data updated");
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"requestToProfileSegue"]) {
        ProfileViewController *destViewController = segue.destinationViewController;
        
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        destViewController.user = sender;
    }
}



@end
