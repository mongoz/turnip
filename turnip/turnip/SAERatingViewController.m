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
    
    [query getObjectInBackgroundWithId:self.objectId block:^(PFObject *object, NSError *error) {
        if (!error) {
            PFRelation *relation = [object relationForKey:@"attended"];
            PFQuery *query = [relation query];
            [query selectKeys:@[@"objectId", @"firstName", @"profileImage", @"rating", @"facebookId"]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    if ([self.activityIndicator isAnimating]) {
                        [self.activityIndicator stopAnimating];
                        self.activityIndicator.hidden = YES;
                    }
                    if ([objects count] > 0) {
                        
                        self.users = [[NSMutableArray alloc] initWithArray:objects];
                        [self.tableView reloadData];
                    }
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
    
    if([self.users count] > 0) {
        NSLog(@"sections");
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else if(![self.activityIndicator isAnimating]){
        // Display a message when the table is empty
        messageLabel.text = @"Noone attended this party :(";
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
    NSLog(@"coutn:%lu",(unsigned long)[self.users count]);
    return [self.users count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"userCell";
    SAERatingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[SAERatingViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    NSLog(@"%@", [self.users objectAtIndex:indexPath.row]);
    
    cell.nameLabel.text = [[self.users valueForKey:@"firstName"] objectAtIndex:indexPath.row];
    
    NSNumber *rating = [[self.users valueForKey:@"rating"] objectAtIndex:indexPath.row];
    
    if ([rating isEqual:[NSNull null]]) {
        cell.rating.text = @"0";
    } else {
       cell.rating.text = [rating stringValue];
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
    
    return cell;
    
}

- (void)backNavigation {
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Cell Delegates

- (void) ratingViewCellDownVoteTapped:(SAERatingViewCell *)cell {
    
}

- (void) ratingViewCellUpVoteTapped:(SAERatingViewCell *)cell {
    
}

@end
