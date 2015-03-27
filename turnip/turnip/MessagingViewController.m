//
//  MessagingViewController.m
//  turnip
//
//  Created by Per on 3/16/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "MessagingViewController.h"
#import "MessagingTableViewCell.h"
#import "Constants.h"
#import <Parse/Parse.h>

@interface MessagingViewController ()

@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, assign) BOOL *exists;
@property (nonatomic, strong) PFUser *recipient;
@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSString *outgoingId;
@property (nonatomic, strong) NSString *incommingId;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation MessagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
      self.offscreenCells = [NSMutableDictionary dictionary];
    
    if (self.user != nil) {
        [self getMessages];
    } else if (self.conversationId != nil) {

        [self getMessagesFromConversation];
    }
    
    self.messageField.delegate = self;
    
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
     [self.messageField resignFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        CGRect bkgndRect = _activeField.superview.frame;
        bkgndRect.size.height += kbSize.height;
        [_activeField.superview setFrame:bkgndRect];
        [_scrollView setContentOffset:CGPointMake(0.0, _activeField.frame.origin.y-kbSize.height + 40) animated:YES];

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
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
                        self.messages = [[NSMutableArray alloc] initWithArray:objects];
                        [self.tableView reloadData];
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
                        self.messages = [[NSMutableArray alloc] initWithArray:objects];
                        [self.tableView reloadData];
                    }
                }];
            }
        }
    }];
}

- (void) createConversation: (PFObject *) message {
    
    PFObject *conversation = [PFObject objectWithClassName:@"Conversation"];
    
    conversation[@"userA"] = [PFUser currentUser];
    conversation[@"userB"] = self.recipient;
    
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

- (void) sendMessage {
    
    PFObject *message = [PFObject objectWithClassName:@"Messages"];
    
    message[@"user"] = [PFUser currentUser];
    message[@"message"] = self.messageField.text;
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        } if (succeeded) {
            // send push notification
            if ([self.messages count] == 0) {
                [self createConversation:message];
            } else {
                [self addMessageToConversation:message];
            }
        }
    }];
}

#pragma mark - TableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.messages count] > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else {
        // Display a message when the table is empty
        messageLabel.text = @"You have no messages";
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
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"messageCell";
    
    MessagingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[MessagingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    [self configureBasicCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureBasicCell:(MessagingTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if([[[[self.messages valueForKey:@"user"] objectAtIndex:indexPath.row] objectId] isEqual:[PFUser currentUser].objectId]) {
        [self downloadProfileImage:self.outgoingId forTableViewCell:cell];
        [cell.otherText setTextAlignment:NSTextAlignmentRight];
        [cell.dateLabel setTextAlignment:NSTextAlignmentRight];
    } else {
        [self downloadProfileImage:self.incommingId forTableViewCell:cell];
        [cell.otherText setTextAlignment:NSTextAlignmentLeft];
        [cell.dateLabel setTextAlignment:NSTextAlignmentLeft];
    }
    
    [cell.otherText sizeToFit];
    cell.otherText.text = [[self.messages valueForKey:@"message"] objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MMM d, H:mm a"];
    
    cell.dateLabel.text = [formatter stringFromDate: [[self.messages valueForKey:@"createdAt"] objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static MessagingTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    //Dirty hack try and find a better soloution;
    return size.height + 5.0f; // Add 1.0f for the cell separator height
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}


- (IBAction)sendButton:(id)sender {
    [self sendMessage];
}

- (void) downloadProfileImage:(NSString *) facebookId forTableViewCell:(MessagingTableViewCell *) cell {
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
    
    // Run network request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil && data != nil) {
             if ([facebookId isEqual:self.outgoingId]) {
                 cell.outgoingImage.image = [UIImage imageWithData:data];
             } else {
                 cell.otherImage.image = [UIImage imageWithData:data];
             }
         }
     }];
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

@end
