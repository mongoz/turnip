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
    if ([[[[[self tabBarController] tabBar] items] objectAtIndex: TurnipTabMessage] badgeValue] > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TurnipResetMessageBadgeCount object:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageRecived:) name:TurnipMessagePushNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSent:) name:TurnipMessageSentNotification object:nil];
    
    [self queryForTable];
    
    self.conversations = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryForTable {
    
    [self.conversations removeAllObjects];
    [self.activityIndicator startAnimating];
    
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
            __block NSInteger counter = 0;
                
                for (PFObject *object in objects) {
                    PFRelation *relation = [object relationForKey:@"messages"];
                    PFQuery *query = [relation query];
                    [query orderByDescending:@"createdAt"];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *message, NSError *error) {
                        if (!error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                               self.activityIndicator.hidden = YES;
                                [self.activityIndicator stopAnimating];
                                if([objects count] != 0) {
                                    PFUser  *user = [PFUser new];
                                    if ([[[object objectForKey:@"userA"] objectId] isEqual: [PFUser currentUser].objectId]) {
                                        user = [object objectForKey:@"userB"];
                                    } else {
                                        user = [object objectForKey:@"userA"];
                                    }
                                    [self.conversations addObject:@{ @"conversationId": [object objectId],
                                                                     @"date": [object updatedAt],
                                                                     @"latestMessage": [message objectForKey:@"message"],
                                                                     @"user": user
                                                                     }];
                                    counter++;
                                    if ([objects count] == counter) {
                                        NSLog(@"done");
                                        [self.tableView reloadData];
                                    }
                                }
                            });
                        }
                    }];
                }
            } else {
                self.activityIndicator.hidden = YES;
                [self.activityIndicator stopAnimating];
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
    cell.messageLabel.text = [[self.conversations valueForKey:@"latestMessage"] objectAtIndex:indexPath.row];
    
    NSArray *name = [[[[self.conversations valueForKey:@"user"] valueForKey:@"name"] objectAtIndex:indexPath.row] componentsSeparatedByString: @" "];
    cell.titleLabel.text = [name objectAtIndex:0];
    

    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[[self.conversations valueForKey:@"user"] valueForKey:@"facebookId"] objectAtIndex:indexPath.row]]];
    
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
    
    NSDate *date = [[self.conversations valueForKey:@"date"] objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if ([self isDateToday:date]) {
        [formatter setDateFormat:@"h:mm a"];
    } else {
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"MMM d"];
    }
    cell.dateLabel.text = [formatter stringFromDate:date];

    
    return cell;
    
}



#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"messageSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MessagingViewController *destViewController = segue.destinationViewController;
        
        destViewController.conversationId = [[self.conversations valueForKey:@"conversationId"] objectAtIndex:indexPath.row];
        destViewController.user = [[self.conversations valueForKey:@"user"] objectAtIndex:indexPath.row];
    }
}

#pragma mark -
#pragma mark Notifications

- (void) messageRecived:(NSNotification *) note {
    [self queryForTable];
}

- (void) messageSent:(NSNotification *) note {
    [self queryForTable];
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
