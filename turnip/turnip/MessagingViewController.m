//
//  MessagingViewController.m
//  turnip
//
//  Created by Per on 3/16/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "MessagingViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>

@interface MessagingViewController () <AMBubbleTableDataSource, AMBubbleTableDelegate>

@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, assign) BOOL *exists;
@property (nonatomic, strong) PFUser *recipient;
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSString *outgoingId;
@property (nonatomic, strong) NSString *incommingId;

@property (nonatomic, strong) NSMutableArray* data;

@end

@implementation MessagingViewController

- (void)viewDidLoad {
    // Dummy data
    [self setDataSource:self]; // Weird, uh?
    [self setDelegate:self];
    
    NSArray *name = [[self.user valueForKey:@"name"] componentsSeparatedByString: @" "];

    [self setTitle:[name objectAtIndex:0]];
    
    NSLog(@"self.user: %@", self.user);
    
    // Set a style
    [self setTableStyle:AMBubbleTableStyleFlat];
    
    [self setBubbleTableOptions:@{AMOptionsBubbleDetectionType: @(UIDataDetectorTypeAll),
                                  AMOptionsBubblePressEnabled: @NO,
                                  AMOptionsBubbleSwipeEnabled: @NO,
                                  AMOptionsButtonTextColor: [UIColor colorWithRed:1.0f green:1.0f blue:184.0f/256 alpha:1.0f]}];
    
    // Call super after setting up the options
    [super viewDidLoad];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    //[self reloadTableScrollingToBottom:YES];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageRecived:) name:TurnipMessagePushNotification object:nil];
    
    if (self.user != nil) {
        [self getMessages];
    } else if (self.conversationId != nil) {

        [self getMessagesFromConversation];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - 
#pragma mark Message handler

- (void) getMessages {
    
    PFQuery *first = [PFQuery queryWithClassName:@"Conversation"];
    
    [first whereKey:@"userA" equalTo:[PFUser currentUser]];
    [first whereKey:@"userB" equalTo:self.user];
    
    PFQuery *second = [PFQuery queryWithClassName:@"Conversation"];
    [second whereKey:@"userB" equalTo:[PFUser currentUser]];
    [second whereKey:@"userA" equalTo:self.user];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[first,second]];
    [query includeKey:@"userA"];
    [query includeKey:@"userB"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"error in getMessage: %@", error);
        } else {
            if (object != nil) {
                [self getFacebookId:object];
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
    
    [query getObjectInBackgroundWithId:self.conversationId block:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"error in convo query: %@", error);
        } else {
            if (object != nil) {
                [self getFacebookId:object];
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
    conversation[@"userB"] = self.user;
    
    PFRelation *relation = [conversation relationForKey:@"messages"];
    [relation addObject:message];
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error in convo:%@", error);
        } if (succeeded) {
            self.conversationId = [conversation objectId];
            [self.messages addObject:message];
            [self.tableView reloadData];
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
            [self.messages addObject:message];
            [self.tableView reloadData];
        }
    }];
}

//- (void) sendMessage {
//    PFObject *message = [PFObject objectWithClassName:@"Messages"];
//    
//    message[@"user"] = [PFUser currentUser];
//    message[@"message"] = self.messageField.text;
//    
//    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (error) {
//            NSLog(@"error: %@", error);
//        } if (succeeded) {
//            // send push notification
//            
//            
//            [PFCloud callFunctionInBackground:@"messagePush"
//                               withParameters:@{@"recipientId": [[self.user valueForKey:@"objectId"] objectAtIndex:0], @"message": self.messageField.text}
//                                        block:^(NSString *success, NSError *error) {
//                                            if (!error) {
//                                                NSLog(@"push sent");
//                                            }
//                                        }];
//            
//            
//            if ([self.messages count] == 0) {
//                [self createConversation:message];
//            } else {
//                [self addMessageToConversation:message];
//            }
//            self.messageField.text = @"";
//        }
//    }];
//}

#pragma mark - TableView Delegates

//- (void) downloadProfileImage:(NSString *) facebookId forTableViewCell:(MessagingTableViewCell *) cell {
//    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
//    
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
//    
//    // Run network request asynchronously
//    [NSURLConnection sendAsynchronousRequest:urlRequest
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:
//     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//         if (connectionError == nil && data != nil) {
//             if ([facebookId isEqual:self.outgoingId]) {
//                 cell.outgoingImage.image = [UIImage imageWithData:data];
//             } else {
//                 cell.otherImage.image = [UIImage imageWithData:data];
//             }
//         }
//     }];
//}

#pragma mark -
#pragma mark Notifications

- (void) messageRecived:(NSNotification *) note {
    NSDictionary *dict = [note object];
    
    NSLog(@"Alert %@", [[dict objectForKey:@"aps"] objectForKey:@"alert"]);
    
    NSString *text = [[dict objectForKey:@"aps"] objectForKey:@"alert"];
    
    [self.messages addObject:@{ @"text": text,
                                @"date": [NSDate date],
                                @"type": @(AMBubbleCellReceived)
                                }];
    
    [self reloadTableScrollingToBottom:YES];
}


#pragma mark -
#pragma mark utils

- (void) getFacebookId: (PFObject *) object {
    if ([[[object objectForKey:@"userA"] objectId] isEqual:[PFUser currentUser].objectId]) {
        self.outgoingId = [[object objectForKey:@"userA"] objectForKey:@"facebookId"];
        self.incommingId = [[object objectForKey:@"userB"] objectForKey:@"facebookId"];
        
    } else {
        self.outgoingId = [[object objectForKey:@"userB"] objectForKey:@"facebookId"];
        self.incommingId = [[object objectForKey:@"userA"] objectForKey:@"facebookId"];
    }
}

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

- (void)didSendText:(NSString*)text
{
    NSLog(@"User wrote: %@", text);
    
    [self.messages addObject:@{ @"text": text,
                            @"date": [NSDate date],
                            @"type": @(AMBubbleCellSent)
                            }];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.data.count - 1) inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    // Either do this:
    // [self scrollToBottomAnimated:YES];
    // or this:
    [super reloadTableScrollingToBottom:YES];
}


- (void) buildMessageArray: (NSArray *) data {
    
    //NSLog(@"data: %@", data);
    self.messages = [[NSMutableArray alloc] initWithCapacity:[data count]];
    
    int type = 0;
    
    for (NSDictionary *message in data) {
        if ([[[message valueForKey:@"user"] objectId] isEqual:[PFUser currentUser].objectId]) {
            type = AMBubbleCellSent;
        } else {
            type = AMBubbleCellReceived;
        }
        
        [self.messages addObject:@{ @"text": [message valueForKey:@"message"],
                                    @"date": [message valueForKey:@"createdAt"],
                                    @"type": @(type),
                                    @"avatar": [UIImage imageNamed:@"profile"]
                                    }];
        
    }
    [self reloadTableScrollingToBottom:YES];
}


@end
