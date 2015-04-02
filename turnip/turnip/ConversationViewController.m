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

@property (nonatomic, strong) NSArray *user;

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Conversation";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
    }
    return self;
}

- (PFQuery *)queryForTable {
    
    PFQuery *userAQuery = [PFQuery queryWithClassName:self.parseClassName];
    [userAQuery whereKey:@"userA" equalTo:[PFUser currentUser]];
    
    PFQuery *userBQuery = [PFQuery queryWithClassName:self.parseClassName];
    [userBQuery whereKey:@"userB" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[userAQuery, userBQuery]];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query includeKey:@"userA"];
    [query includeKey:@"userB"];
    [query orderByDescending:@"updatedAt"];
    return query;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *tableIdentifier = @"conversationCell";
    
    ConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[ConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    if ([[[object objectForKey:@"userA"] objectId] isEqual: [PFUser currentUser].objectId]) {
        [self configureCell:cell forRowAtIndexPath:indexPath andUser:[object objectForKey:@"userB"]];
    } else {
        [self configureCell:cell forRowAtIndexPath:indexPath andUser:[object objectForKey:@"userA"]];
    }
    
    return cell;
}

- (void)configureCell:(ConversationTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath andUser:(PFObject *)user {
    self.user = [[NSArray alloc] initWithObjects:user, nil];
    
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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"MMM d"];
    cell.dateLabel.text = [formatter stringFromDate:[user updatedAt]];

}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void) objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (error != nil) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"messageSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MessagingViewController *destViewController = segue.destinationViewController;
        
        destViewController.conversationId = [[self.objects valueForKey:@"objectId"] objectAtIndex:indexPath.row];
        destViewController.user = [self.user objectAtIndex:indexPath.row];
    }
}


#pragma mark - utils


@end
