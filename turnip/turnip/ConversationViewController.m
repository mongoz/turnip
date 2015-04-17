//
//  ConversationViewController.m
//  turnip
//
//  Created by Per on 3/23/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ConversationViewController.h"
#import "ConversationTableViewCell.h"
#import "MessagingViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface ConversationViewController ()

@property (nonatomic, strong) NSMutableArray *user;
@property (nonatomic, strong) NSMutableArray *conversations;

@end

@implementation ConversationViewController

- (void) viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:TurnipResetMessageBadgeCount object:nil];
    [self queryForTable];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageRecived:) name:TurnipMessagePushNotification object:nil];
    
    self.user = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryForTable {
    
    PFQuery *userAQuery = [PFQuery queryWithClassName:@"Conversation"];
    [userAQuery whereKey:@"userA" equalTo:[PFUser currentUser]];
    
    PFQuery *userBQuery = [PFQuery queryWithClassName:@"Conversation"];
    [userBQuery whereKey:@"userB" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[userAQuery, userBQuery]];
    
    [query includeKey:@"userA"];
    [query includeKey:@"userB"];
    [query orderByDescending:@"updatedAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count] != 0) {
                self.conversations = [[NSMutableArray alloc] initWithArray:objects];
                for (PFObject *object in objects) {
                    PFRelation *relation = [object relationForKey:@"messages"];
                    PFQuery *query = [relation query];
                    [query orderByDescending:@"createdAt"];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if (!error) {
                            NSLog(@"object: %@", object);
                        }
                    }];
                }
                [self.tableView reloadData];
            }
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.conversations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"conversationCell";
    ConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[ConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    cell.titleLabel.text = @"test";
    
    if ([[[[self.conversations valueForKey:@"userA"] valueForKey:@"objectId"] objectAtIndex:indexPath.row] isEqual: [PFUser currentUser].objectId]) {
        [self configureCell:cell forRowAtIndexPath:indexPath andUser:[[self.conversations valueForKey:@"userB"] objectAtIndex:indexPath.row]];
    } else {
        [self configureCell:cell forRowAtIndexPath:indexPath andUser:[[self.conversations valueForKey:@"userA"] objectAtIndex:indexPath.row]];
    }
    
    return cell;
    
}

- (void)configureCell:(ConversationTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath andUser:(PFObject *)user {
    
    [self.user insertObject:user atIndex:indexPath.row];
    
    NSArray *name = [[user objectForKey:@"name"] componentsSeparatedByString: @" "];
    cell.titleLabel.text = [name objectAtIndex:0];
    // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [user objectForKey:@"facebookId"]]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
    
    // Run network request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil && data != nil) {
             cell.profileImage.image = [UIImage imageWithData:data];
         }
     }];
    
    NSDate *date = [[self.conversations valueForKey:@"updatedAt"] objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if ([self isDateToday:date]) {
        [formatter setDateFormat:@"h:mm a"];
    } else {
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"MMM d"];
    }
    cell.dateLabel.text = [formatter stringFromDate:date];
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"messageSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MessagingViewController *destViewController = segue.destinationViewController;
        
        destViewController.conversationId = [[self.conversations valueForKey:@"objectId"] objectAtIndex:indexPath.row];
        destViewController.user = [self.user objectAtIndex:indexPath.row];
    }
}

#pragma mark -
#pragma mark Notifications

- (void) messageRecived:(NSNotification *) note {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark utils 

-(BOOL) isDateToday:(NSDate *) messageDate {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:messageDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if ([today isEqualToDate:otherDate]) {
        return YES;
    } else {
        return NO;
    }
}

@end
