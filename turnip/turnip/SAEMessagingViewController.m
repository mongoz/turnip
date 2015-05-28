//
//  SAEMessagingViewController.m
//  turnip
//
//  Created by Per on 3/16/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "SAEMessagingViewController.h"
#import "ProfileViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>

@interface SAEMessagingViewController () <AMBubbleTableDataSource, AMBubbleTableDelegate>

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) UIImage *sentProfile;
@property (nonatomic, strong) UIImage *recievedProfile;

@property (nonatomic, strong) NSString *outgoingId;
@property (nonatomic, strong) NSString *incommingId;

@property (nonatomic, strong) NSMutableArray* data;

@end

@implementation SAEMessagingViewController


- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] postNotificationName:TurnipResetMessageBadgeCount object:nil];
    [self setDataSource:self];
    [self setDelegate:self];
    
    NSArray *name = [[self.user valueForKey:@"name"] componentsSeparatedByString: @" "];
    
    self.outgoingId = [[PFUser currentUser] objectForKey:@"facebookId"];
    [self downloadProfileImage: self.outgoingId];
    
    
    if ([self.user valueForKey:@"profileImage"] != nil) {
        NSURL *url = [NSURL URLWithString: [self.user valueForKey:@"profileImage"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.recievedProfile = [UIImage imageWithData:data];
    } else {
        self.incommingId = [self.user valueForKey:@"facebookId"];
        [self downloadProfileImage: self.incommingId];
    }
    
    [self setTitle:[name objectAtIndex:0]];

    self.messages = [[NSMutableArray alloc] init];
    self.recipientId = [self.user valueForKey:@"objectId"];
    
    // Set a style
    [self setTableStyle:AMBubbleTableStyleFlat];
    
    [self setBubbleTableOptions:@{AMOptionsBubbleDetectionType: @(UIDataDetectorTypeAll),
                                  AMOptionsBubblePressEnabled: @NO,
                                  AMOptionsBubbleSwipeEnabled: @NO,
                                  AMOptionsButtonTextColor: [UIColor colorWithRed:1.0f green:1.0f blue:184.0f/256 alpha:1.0f]}];
    
    // Call super after setting up the options
    [super viewDidLoad];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageRecived:) name:TurnipMessagePushNotification object:nil];
    
    if (self.conversationId == nil) {
        [self getMessages];
    } else {
       [self getMessagesFromConversation];
   }
}

#pragma mark - 
#pragma mark Message handler

- (void) getMessages {
    
    PFQuery *first = [PFQuery queryWithClassName:@"Conversation"];
    
    PFUser *user = [PFUser objectWithoutDataWithClassName:@"_User" objectId:[self.user valueForKey:@"objectId"]];
    
    [first whereKey:@"userA" equalTo:[PFUser currentUser]];
    [first whereKey:@"userB" equalTo:user];
    
    PFQuery *second = [PFQuery queryWithClassName:@"Conversation"];
    [second whereKey:@"userB" equalTo:[PFUser currentUser]];
    [second whereKey:@"userA" equalTo:user];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[first,second]];
    [query includeKey:@"userA"];
    [query includeKey:@"userB"];
    query.limit = 20;
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"error in getMessage: %@", error);
        } else {
            if (object != nil) {
                self.conversationId = object.objectId;
                PFRelation *relation = [object relationForKey:@"messages"];
                PFQuery *query = [relation query];
                [query orderByAscending:@"createdAt"];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (error) {
                        NSLog(@"error in relation query: %@", error);
                    }
                    else if ([objects count] == 0) {
                        NSLog(@"nothing found");
                    } else {
                       [self buildMessageArray:objects];
                    }
                }];
            }
        }
    }];
}

- (void) getMessagesFromConversation {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    [query includeKey:@"userA"];
    [query includeKey:@"userB"];
    query.limit = 20;
    
    [query getObjectInBackgroundWithId:self.conversationId block:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"error in convo query: %@", error);
        } else {
            if (object != nil) {
                if ([[[object objectForKey:@"userA"] objectId] isEqual:[PFUser currentUser].objectId]) {
                     self.user = [NSArray arrayWithObject:[object objectForKey:@"userB"]];
                } else {
                    self.user = [NSArray arrayWithObject:[object objectForKey:@"userA"]];
                }
               
                PFRelation *relation = [object relationForKey:@"messages"];
                PFQuery *query = [relation query];
                [query orderByAscending:@"createdAt"];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (error) {
                        NSLog(@"error in relation query: %@", error);
                    }
                    else if ([objects count] == 0) {
                        NSLog(@"nothing found");
                    } else {
                        [self buildMessageArray:objects];
                    }
                }];
            }
        }
    }];
}

- (void) createConversation: (PFObject *) message {
    
    PFObject *conversation = [PFObject objectWithClassName:@"Conversation"];
    
    conversation[@"userA"] = [PFUser currentUser];
    conversation[@"userB"] = [PFUser objectWithoutDataWithClassName:@"_User" objectId:[self.user valueForKey:@"objectId"]];
    
    PFRelation *relation = [conversation relationForKey:@"messages"];
    [relation addObject:message];
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error in convo:%@", error);
        } if (succeeded) {
            self.conversationId = [conversation objectId];
        }
    }];
}

- (void) addMessageToConversation: (PFObject *) message {
    PFObject *conversation = [PFObject objectWithoutDataWithClassName:@"Conversation" objectId:self.conversationId];
    
    PFRelation *relation = [conversation relationForKey:@"messages"];
    [relation addObject:message];
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error:%@", error);
        } else if (succeeded) {
            NSLog(@"success");
            [self reloadTableScrollingToBottom:YES];
        }
    }];
}

- (void) downloadProfileImage:(NSString *) facebookId {
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];

    // Run network request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil && data != nil) {
             if ([facebookId isEqual:self.outgoingId]) {
                 self.sentProfile = [UIImage imageWithData:data];
             } else {
                 self.recievedProfile = [UIImage imageWithData:data];
             }
         }
     }];
}

#pragma mark -
#pragma mark Notifications

- (void) messageRecived:(NSNotification *) note {
    NSDictionary *dict = [note object];
    
    UIImage *profile = self.recievedProfile;
    
    NSString *text = [[dict objectForKey:@"aps"] objectForKey:@"alert"];
    
    NSArray *message = [text componentsSeparatedByString: @": "];
    
    NSString *from = [dict objectForKey:@"from"];
    
    if([from isEqualToString: [[self.user valueForKey:@"objectId"] objectAtIndex:0]]) {
        [self.messages addObject:@{ @"text": [message objectAtIndex:1],
                                    @"date": [NSDate date],
                                    @"type": @(AMBubbleCellReceived),
                                    @"avatar": profile
                                    }];
        
        [self reloadTableScrollingToBottom:YES];
    }
}

#pragma mark -
#pragma mark utils


#pragma mark - AMBubbleTableDataSource

- (NSInteger)numberOfRows
{
    return self.messages.count;
}

- (AMBubbleCellType)cellTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages[indexPath.row][@"type"] intValue];
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.row][@"text"];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.row][@"date"];
}

- (UIImage*)avatarForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.messages[indexPath.row][@"avatar"];
}

#pragma mark - AMBubbleTableDelegate

-(void) avatarTapAtIndexPath:(NSIndexPath *)indexPath {
    NSString *type = [[self.messages valueForKey:@"type"] objectAtIndex:indexPath.row];
    
    if ([type isEqual:@1]) {
        [self performSegueWithIdentifier:@"showProfile" sender:[PFUser currentUser]];
    } else {
        [self performSegueWithIdentifier:@"showProfile" sender:[self.user objectAtIndex:0]];
    }
}

- (void)didSendText:(NSString*)text
{
    PFObject *message = [PFObject objectWithClassName:@"Messages"];
    UIImage *profile = self.sentProfile;
    
    NSArray *name = [[[PFUser currentUser] valueForKey:@"name"] componentsSeparatedByString: @" "];

    message[@"user"] = [PFUser currentUser];
    message[@"message"] = text;
    
    NSString *pushMessage = [NSString stringWithFormat:@"%@: %@",[name objectAtIndex:0],text];
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        } if (succeeded) {
            // send push notification
            [PFCloud callFunctionInBackground:@"messagePush"
                               withParameters:@{@"recipientId": self.recipientId, @"message": pushMessage}
                                        block:^(NSString *success, NSError *error) {
                                            if (!error) {
                                                NSLog(@"push sent");
                                            }
                                        }];
            
            if (self.conversationId == 0) {
                [self createConversation:message];
            } else {
                [self addMessageToConversation:message];
            }
        }
    }];
    
    [self.messages addObject:@{ @"text": text,
                                @"date": [NSDate date],
                                @"type": @(AMBubbleCellSent),
                                @"avatar": profile
                                }];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];

    [super reloadTableScrollingToBottom:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:TurnipMessageSentNotification object:nil];
}

- (void) buildMessageArray: (NSArray *) data {
    
    UIImage *profile = [UIImage imageNamed:@"profile"];
    
    int type = 0;
    
    
    for (NSDictionary *message in data) {
        if ([[[message valueForKey:@"user"] objectId] isEqual:[PFUser currentUser].objectId]) {
            type = AMBubbleCellSent;
            profile = self.sentProfile;
        } else {
            type = AMBubbleCellReceived;
            profile = self.recievedProfile;
        }
        [self.messages addObject:@{ @"text": [message valueForKey:@"message"],
                                    @"date": [message valueForKey:@"createdAt"],
                                    @"type": @(type),
                                    @"avatar": profile
                                    }];
    }
    [self reloadTableScrollingToBottom:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showProfile"]) {
        ProfileViewController *destViewController = segue.destinationViewController;
        destViewController.user = sender;
    }
    
}


- (IBAction)backNavigation:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
