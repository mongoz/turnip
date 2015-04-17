//
//  NotificationViewController.m
//  turnip
//
//  Created by Per on 2/5/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "NotificationViewController.h"
#import "TicketViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Constants.h"
#import <Parse/Parse.h>
#import <CoreText/CoreText.h>
#import "ScannerViewController.h"

@interface NotificationViewController ()

@property (nonatomic, assign) NSUInteger nbItems;
@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) PFImageView *image;

@end

@implementation NotificationViewController

NSArray *fetchedObjects;

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if ([[[[[self tabBarController] tabBar] items] objectAtIndex: TurnipTabNotification] badgeValue] > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TurnipResetBadgeCountNotification object:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    }
    
    // Initialize the refresh control.
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(queryNotifications) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    [self queryNotifications];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.notifications count];
}

- (NotificationTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"noteCell";
    
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[NotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    [cell.imageSpinner setHidden: NO];
    [cell.imageSpinner startAnimating];
    
    
    NSString *title = [[self.notifications valueForKey:@"eventTitle"] objectAtIndex: indexPath.row];
    NSString *notification = [[self.notifications valueForKey:@"notification"] objectAtIndex:indexPath.row];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString: notification];

    NSRange range = [notification rangeOfString:title];
    
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    
    [cell.noteTextLabel setAttributedText:string];

    
    PFFile *file = [[[self.notifications valueForKey:@"event"] valueForKey:@"thumbnail"] objectAtIndex:indexPath.row];
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            cell.noteImageView.image = image;
            [cell.imageSpinner setHidden: YES];
            [cell.imageSpinner stopAnimating];
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
    if ([[[self.notifications valueForKey:@"type"] objectAtIndex:indexPath.row] isEqualToString:@"ticket"]) {
        [self performSegueWithIdentifier:@"ticketSegue" sender:self];
    } else if([[[self.notifications valueForKey:@"type"] objectAtIndex:indexPath.row] isEqualToString:@"teammate"]) {
        [self performSegueWithIdentifier:@"scannerSegue" sender:self];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.notifications count] > 0) {
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

#pragma mark - Parse queries

- (void) queryNotifications {
    PFQuery *query = [PFQuery queryWithClassName: @"Notifications"];
    
    if ([self.notifications count] == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query includeKey:@"event"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            NSLog(@"Error in geo query!: %@", error);
        } else {
             [self.refreshControl endRefreshing];
            if([objects count] != 0) {
                self.notifications = [[NSArray alloc] initWithArray:objects];
                [self.tableView reloadData];
            }
        }
    }];
}


#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"ticketSegue"]) {
        TicketViewController *destViewController = segue.destinationViewController;
        
        NSString *title = [[[self.notifications valueForKey:@"event"] valueForKey:@"title"] objectAtIndex: indexPath.row];
        NSString *objectId = [[[self.notifications valueForKey:@"event"] valueForKey:@"objectId"] objectAtIndex: indexPath.row];
        NSDate *date = [[[self.notifications valueForKey:@"event"] valueForKey:@"date"] objectAtIndex: indexPath.row];
        NSString *address = [[[self.notifications valueForKey:@"event"] valueForKey:@"address"] objectAtIndex: indexPath.row];
        
        destViewController.ticketTitle = title;
        destViewController.objectId = objectId;
        destViewController.date = date;
        destViewController.address = address;
    }
    
    if ([segue.identifier isEqualToString:@"scannerSegue"]) {
        ScannerViewController *destViewController = segue.destinationViewController;
        
        destViewController.eventId = [[[self.notifications valueForKey:@"event"] valueForKey:@"objectId"] objectAtIndex: indexPath.row];
    }
}

@end
