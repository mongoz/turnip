//
//  SAERatingViewController.m
//  turnip
//
//  Created by Per on 7/16/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAERatingViewController.h"
#import "SAERatingViewCell.h"
#import "SAEUtilityFunctions.h"
#import "ParseErrorHandlingController.h"
#import <Parse/Parse.h>


@interface SAERatingViewController () <SAERatingViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation SAERatingViewController



- (void) viewDidLoad {
    [super viewDidLoad];
    [super setTitle:self.name];
    
    self.users = [[NSMutableArray alloc] init];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 30.0f, 30.0f)];
    
    UIImage *backImage = [SAEUtilityFunctions imageResize:[UIImage imageNamed:@"backNav"] andResizeTo:CGSizeMake(30, 30)];
    [backButton setBackgroundImage:backImage  forState:UIControlStateNormal];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backNavigation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.activityIndicator.color = [UIColor blackColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = self.activityIndicator;
    [self.activityIndicator startAnimating];
    [self queryAttended];
    
}

- (void) queryAttended {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Finished"];
    
    [query whereKey:@"objectId" equalTo:self.objectId];
    
    [query includeKey:@"user"];
    [query selectKeys:@[@"objectId", @"attended", @"user"]];
    
    [query getObjectInBackgroundWithId:self.objectId block:^(PFObject *object, NSError *error) {
        if (!error) {
            
            [self.users addObject:[object objectForKey:@"user"]];
            PFRelation *relation = [object relationForKey:@"attended"];
            PFQuery *query = [relation query];
            [query selectKeys:@[@"objectId", @"firstName", @"profileImage", @"rating", @"facebookId", @"upVoted", @"downVoted"]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    if ([self.activityIndicator isAnimating]) {
                        [self.activityIndicator stopAnimating];
                        self.activityIndicator.hidden = YES;
                    }
                    if ([objects count] > 0) {
                        
                        [self.users addObjectsFromArray:objects];
                    }
                    [self.tableView reloadData];
                } else {
                    [ParseErrorHandlingController handleParseError:error];
                }
            }];
        } else {
            [ParseErrorHandlingController handleParseError:error];
        }
    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.users count] > 1) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else if(![self.activityIndicator isAnimating]){
        // Display a message when the table is empty
        messageLabel.text = @"Nobody attended this party :(";
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
    return [self.users count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"userCell";
    SAERatingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[SAERatingViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    if(![[self.users valueForKey:@"objectId"] containsObject:[[PFUser currentUser] objectId]]) {
        cell.upVoteButton.enabled = NO;
        cell.downVoteButton.enabled = NO;
    }
    
    cell.nameLabel.text = [[self.users valueForKey:@"firstName"] objectAtIndex:indexPath.row];
    
    NSNumber *rating = [[self.users valueForKey:@"rating"] objectAtIndex:indexPath.row];
    
    if ([rating isEqual:[NSNull null]]) {
        cell.rating.text = @"0";
    } else {
       cell.rating.text = [rating stringValue];
    }
    
    if (![[[self.users valueForKey:@"upVoted"] objectAtIndex:indexPath.row] isEqual:[NSNull null] ] && [[[self.users valueForKey:@"upVoted"] objectAtIndex:indexPath.row] containsObject:[[PFUser currentUser] objectId]]) {
        cell.upVoteButton.enabled = NO;
    } else if (![[[self.users valueForKey:@"downVoted"] objectAtIndex:indexPath.row] isEqual:[NSNull null] ] && [[[self.users valueForKey:@"downVoted"] objectAtIndex:indexPath.row] containsObject:[[PFUser currentUser] objectId]]) {
        cell.downVoteButton.enabled = NO;
    }

    if (![[[self.users valueForKey:@"profileImage"] objectAtIndex:indexPath.row] isEqual:[NSNull null]] ) {
    
        NSURL *url = [NSURL URLWithString: [[self.users valueForKey:@"profileImage"] objectAtIndex:indexPath.row]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.profileImage.image = [UIImage imageWithData:data];
    } else {
        
        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[self.users valueForKey:@"facebookId"] objectAtIndex:indexPath.row]]];
        
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
    
    cell.delegate = self;
    return cell;
    
}

- (void)backNavigation {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Cell Delegates

- (void) ratingViewCellUpVoteTapped:(SAERatingViewCell *)cell {
    
    [self rateUserInCell:cell andDirection:@"up"];
    
}

- (void) ratingViewCellDownVoteTapped:(SAERatingViewCell *)cell {
    [self rateUserInCell:cell andDirection:@"down"];
    
}


- (void) rateUserInCell: (SAERatingViewCell *) cell andDirection:(NSString *) direction {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    PFUser *user = [PFUser objectWithoutDataWithClassName:@"_User" objectId:[[self.users valueForKey:@"objectId"] objectAtIndex:indexPath.row]];
    
    NSInteger rating = [cell.rating.text integerValue];
    
    if ([direction isEqualToString:@"up"]) {
        cell.upVoteButton.enabled = NO;
        cell.downVoteButton.enabled = YES;
        rating++;
        
        [PFCloud callFunctionInBackground:@"rateUser"
                           withParameters:@{@"userId": user.objectId, @"direction": @"up"}
                                    block:^(NSString *success, NSError *error) {
                                        if (error) {
                                            [ParseErrorHandlingController handleParseError:error];
                                        }
                                    }];
        
    } else if([direction isEqualToString:@"down"]) {
        cell.downVoteButton.enabled = NO;
        cell.upVoteButton.enabled = YES;
        
        rating--;
        
        [PFCloud callFunctionInBackground:@"rateUser"
                           withParameters:@{@"userId": user.objectId, @"direction": @"down"}
                                    block:^(NSString *success, NSError *error) {
                                        if (error) {
                                            [ParseErrorHandlingController handleParseError:error];
                                        }
                                    }];
    }
    
    cell.rating.text = [NSString stringWithFormat:@"%ld", (long)rating];
    
}

@end
