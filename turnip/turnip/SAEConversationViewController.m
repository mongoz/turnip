//
//  SAEConversationViewController.m
//  turnip
//
//  Created by Per on 3/23/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "SAEConversationViewController.h"
#import "SAEConversationTableViewCell.h"
#import "SAEMessagingViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface SAEConversationViewController ()

@property (nonatomic, strong) NSMutableArray *user;
@property (nonatomic, strong) NSMutableArray *conversations;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation SAEConversationViewController

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
    
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.activityIndicator.color = [UIColor blackColor];
    
    self.tableView.backgroundView = self.activityIndicator;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.activityIndicator startAnimating];
    
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
                    
                    //Should change this to do in background instead with callback
                    dispatch_async(dispatch_get_main_queue(), ^{
                        PFObject *message = [query getFirstObject];
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
                                [self.tableView reloadData];
                            }
                        }
                    });
                }
            } else {
                self.activityIndicator.hidden = YES;
                [self.activityIndicator stopAnimating];
                [self numberOfSectionsInTableView:self.tableView];
            }
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.conversations count] > 0) {
        self.tableView.backgroundView = nil;
        return 1;
    } else if(![self.activityIndicator isAnimating]){
        // Display a message when the table is empty
        messageLabel.text = @"You currently have no active conversations.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Arial-Bold" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
    }
    return 0;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.conversations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"conversationCell";
    SAEConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[SAEConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    cell.titleLabel.text = @"test";
    cell.messageLabel.text = [[self.conversations valueForKey:@"latestMessage"] objectAtIndex:indexPath.row];
    
    NSArray *name = [[[[self.conversations valueForKey:@"user"] valueForKey:@"name"] objectAtIndex:indexPath.row] componentsSeparatedByString: @" "];
    cell.titleLabel.text = [name objectAtIndex:0];
    
    if (![[[[self.conversations valueForKey:@"user" ] valueForKey:@"profileImage"] objectAtIndex:indexPath.row] isEqual:[NSNull null]] ) {
        NSURL *url = [NSURL URLWithString: [[[self.conversations valueForKey:@"user" ] valueForKey:@"profileImage"] objectAtIndex:indexPath.row]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.profileImage.image = [UIImage imageWithData:data];
    } else {
        
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
    }
    

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
        SAEMessagingViewController *destViewController = segue.destinationViewController;
        
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
