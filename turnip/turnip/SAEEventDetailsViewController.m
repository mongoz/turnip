//
//  EventDetailsViewController.m
//  turnip
//
//  Created by Per on 4/23/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ParseErrorHandlingController.h"
#import "SAEEventDetailsViewController.h"
#import "ProfileViewController.h"
#import "SAEMessagingViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "Constants.h"
#import <Parse/Parse.h>
#import "SAEUtilityFunctions.h"

@interface SAEEventDetailsViewController ()

@property (nonatomic, strong) NSMutableArray *pageImages;
@property (nonatomic, strong) NSMutableArray *pageViews;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *accepted;

@property (nonatomic, assign) BOOL userIsAccepted;


@end

@implementation SAEEventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddress:) name:@"userIsAccepted" object:nil];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 30.0f, 30.0f)];
    
    UIImage *backImage = [SAEUtilityFunctions imageResize:[UIImage imageNamed:@"backNav"] andResizeTo:CGSizeMake(30, 30)];
    [backButton setBackgroundImage:backImage  forState:UIControlStateNormal];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backNavigation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    if (self.event) {
        self.title = [self.event valueForKey:@"title"];
        self.objectId = [self.event valueForKey:@"objectId"];
    }
    
    self.pageImages = [[NSMutableArray alloc] initWithCapacity:3];
    
    [self.scrollView layoutIfNeeded];
    [self.scrollView setNeedsLayout];
    [self downloadDetails];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ImageScroller

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    self.pageControl.currentPage = page;
    
    // Work out which pages we want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    // Load an individual page, first seeing if we've already loaded it
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
        newPageView.contentMode = UIViewContentModeScaleToFill;
        newPageView.frame = frame;
        [self.scrollView addSubview:newPageView];
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self loadVisiblePages];
}

#pragma mark - parse Download

- (void) downloadDetails {
    self.imageLoader.hidden = NO;
    [self.imageLoader startAnimating];
    
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    //query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [query includeKey:TurnipParsePostUserKey];
    [query includeKey:@"neighbourhood"];
    [query whereKey:TurnipParsePostIdKey equalTo:self.objectId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"Error in query!: %@", error);
        } else {
            if ([[object objectForKey:@"denied"] containsObject:[PFUser currentUser].objectId]) {
                NSLog(@"denied");
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    PFRelation *acceptedRelation = [object relationForKey:@"accepted"];
                    PFQuery *query = [acceptedRelation query];
                   // [query whereKey:TurnipParsePostIdKey equalTo:[PFUser currentUser].objectId];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        self.accepted = [[NSArray alloc] initWithArray:objects];
                        [self.tableView reloadData];
                        [self.goingButton setTitle:@([self.accepted count]).stringValue forState:UIControlStateNormal];
                        BOOL found = NO;
                    
                        for (PFUser *user in objects) {
                            if ([[user objectId] isEqual:[PFUser currentUser].objectId]) {
                                found = YES;
                                self.userIsAccepted = YES;
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"userIsAccepted" object:nil];
                                break;
                            }
                        }
                        
                        if (!found) {
                            PFRelation *requestRelation = [object relationForKey:@"requests"];
                            PFQuery *query = [requestRelation query];
                            [query whereKey:TurnipParsePostIdKey equalTo:[PFUser currentUser].objectId];
                            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                if ([objects count] == 0) {
                                    self.requestHolderImage.hidden = YES;
                                    
                                    if ([[[object objectForKey:TurnipParsePostUserKey] objectId] isEqual:[PFUser currentUser].objectId]) {
                                        self.requestButton.hidden = YES;
                                        self.messageButton.hidden = YES;
                                        
                                    } else {
                                        if ([[object objectForKey:TurnipParsePostPrivateKey] isEqual:@"False"]) {
                                            self.attendButton.hidden = NO;
                                        } else {
                                            self.requestButton.hidden = NO;
                                        }

                                    }
                                }
                            }];
                        } else {
                            self.requestHolderImage.hidden = YES;
                            self.requestButton.hidden = YES;
                            self.unattendButton.hidden = NO;
                        }
                          
                    }];
                });
            }
            self.data = [[NSArray alloc] initWithObjects:object, nil];
            [self downloadImages: object];
            [self updateUI: object];
        }
    }];
}


- (void) downloadImages: (PFObject *) data {
    // Set up the image we want to scroll & zoom and add it to the scroll view
    
    NSInteger imageCount =0;
    
    for (int i = 1; i <= 3; i++) {
        NSString *imageName = [NSString stringWithFormat:@"image%d",i];
        if ([data objectForKey:imageName] != nil) {
            imageCount++;
            NSURL *url = [NSURL URLWithString: [(PFFile *)[data objectForKey:imageName] url]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            op.responseSerializer = [AFImageResponseSerializer serializer];
            
            [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self.pageImages addObject: responseObject];
                
                // Load the initial set of pages that are on screen
                [self loadVisiblePages];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error %@", error);
            }];
            [op start];
            
        }
    }
    
    if ([[data objectForKey:TurnipParsePostUserKey] valueForKey:@"profileImage"] != nil) {
        NSURL *url = [NSURL URLWithString: [[data objectForKey:TurnipParsePostUserKey] valueForKey:@"profileImage"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.center = self.profileImage.center;
        [self.view addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        [self.profileImage setImageWithURLRequest:request
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      
                                      [activityIndicatorView removeFromSuperview];
                                      
                                      [weakSelf.profileImage setImage:image];
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      [activityIndicatorView removeFromSuperview];
                                      
                                      // do any other error handling you want here
                                  }];
    } else {
        [self downloadFacebookProfilePicture:[data[@"user"] objectForKey:@"facebookId"]];
    }
    
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * imageCount, pagesScrollViewSize.height);
    
    // Set up the page control
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = imageCount;
    
    // Set up the array to hold the views for each page
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < imageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
    self.imageLoader.hidden = YES;
    [self.imageLoader stopAnimating];
}

- (void) updateUI: (PFObject *) data {
    
    self.attendingView.dynamic = NO;
    self.attendingView.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.attendingView.updateInterval = 5;
    
    CALayer *borderLayer = [CALayer layer];
    CGRect borderFrame = CGRectMake(-5, -5, (self.profileImage.frame.size.width + 10), (self.profileImage.frame.size.height + 10));
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setBorderWidth:5];
    [borderLayer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.profileImage.layer addSublayer:borderLayer];
    
    NSArray *name = [[[data objectForKey:TurnipParsePostUserKey] valueForKey:@"name"] componentsSeparatedByString: @" "];
    NSString *age = @([SAEUtilityFunctions calculateAge: [[data objectForKey:TurnipParsePostUserKey] valueForKey:@"birthday"]]).stringValue;
    [[data objectForKey:TurnipParsePostUserKey] valueForKey:@"birthday"];
    NSString *nameAge = [NSString stringWithFormat:@"%@ - %@", [name objectAtIndex:0], age];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString: nameAge];
    
    NSRange range = [nameAge rangeOfString:[name objectAtIndex:0]];
    
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.549 green:0 blue:0.102 alpha:1] range:range];
    
    [self.nameLabel setAttributedText:string];
    
   /// self.nameLabel.text = nameAge;
    self.aboutLabel.numberOfLines = 0;
    self.aboutLabel.text = [data objectForKey:TurnipParsePostTextKey];
    [self.aboutLabel sizeToFit];
    self.neighbourhoodLabel.text = [[data objectForKey:@"neighbourhood"] valueForKey:@"name"];
    
    self.dateLabel.text = [SAEUtilityFunctions convertDate: [data objectForKey:TurnipParsePostDateKey]];
   
    NSString *price = @"";
    NSString *open = @"";
    
    NSArray *address = [[data objectForKey:TurnipParsePostAddressKey] componentsSeparatedByString:@","];
    
    self.addressLabel.numberOfLines = 0;
    
    if ([[data objectForKey:TurnipParsePostPrivateKey] isEqual:@"True"]) {
        open  = @"Private";
       
        self.addressLabel.text = @"Address is private";

    } else if([[data objectForKey:TurnipParsePostPrivateKey] isEqual:@"False"]) {
        open = @"Public";
        self.addressLabel.text = [address objectAtIndex:0];
    }
    [self.addressLabel sizeToFit];
    
    if ([[data objectForKey:TurnipParsePostPaidKey] isEqual:@"True"]) {
        price = @"Free";
    } else if([[data objectForKey:TurnipParsePostPaidKey] isEqual:@"False"]) {
       price = [NSString stringWithFormat:@"$%@",[data objectForKey:TurnipParsePostPriceKey]];
    }
    
    self.privateLabel.text = [NSString stringWithFormat:@"%@, %@", open, price];
    
    
}

- (void) downloadFacebookProfilePicture: (NSString *) facebookId {
    
    // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
    
    // Run network request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil && data != nil) {
             // Set the image in the header imageView
             self.profileImage.image = [UIImage imageWithData:data];
         }
     }];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"profileSegue"]) {
        ProfileViewController *destViewController = segue.destinationViewController;
        destViewController.user = sender;
    }
    
    if ([segue.identifier isEqualToString:@"attendingProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ProfileViewController *destViewController = segue.destinationViewController;
        destViewController.user = [self.accepted objectAtIndex:indexPath.row];
    }

    
    
    
    if ([segue.identifier isEqualToString:@"messageSegue"]) {
        SAEMessagingViewController *destViewController = segue.destinationViewController;
        destViewController.user = [[self.data valueForKey:@"user"] objectAtIndex:0];
    }

}


#pragma mark - buttons

-(void) backNavigation {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)profileImageTap:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:@"profileSegue" sender: [[self.data valueForKey:@"user"] objectAtIndex:0]];
}

- (IBAction)messageButton:(id)sender {
}

- (IBAction)requestButton:(id)sender {
    
    NSString *host = [[[self.data valueForKey:@"user"] valueForKey:@"objectId"] objectAtIndex:0];
    NSArray *name = [[[PFUser currentUser] objectForKey:@"name"] componentsSeparatedByString: @" "];
    
    NSString *message = [NSString stringWithFormat:@"%@ Wants to go to your party", [name objectAtIndex:0]];
    
    self.requestButton.enabled = NO;
    self.requestButton.hidden = YES;
    self.requestHolderImage.hidden = NO;
    
    [PFCloud callFunctionInBackground:@"requestEventPush"
                       withParameters:@{@"recipientId": host, @"message": message, @"eventId": [[self.data valueForKey:TurnipParsePostIdKey] objectAtIndex:0] }
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"push sent");
                                    }
                                }];

}

- (IBAction)nextImageButton:(id)sender {
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f))+1;
    self.pageControl.currentPage = page;
    
    if (page == self.pageImages.count) {
        page = 0;
    }
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    [self loadVisiblePages];

}

- (IBAction)goingButton:(id)sender {

    if (self.userIsAccepted || [[[[self.data valueForKey:@"user"] valueForKey:@"objectId"] objectAtIndex:0] isEqual:[PFUser currentUser].objectId]) {
        self.attendingView.hidden = NO;
        [self.attendingView setNeedsDisplay];
        [self.scrollView setScrollEnabled:NO];
    }
}

- (IBAction)closeAttendingViewButton:(id)sender {
    self.attendingView.hidden = YES;
}

- (IBAction)attendButton:(id)sender {
    
    PFObject *object = [PFObject objectWithoutDataWithClassName:TurnipParsePostClassName objectId:[[self.data valueForKey:@"objectId"] objectAtIndex:0]];
    
    PFRelation *relation = [object relationForKey:@"accepted"];
    [relation addObject:[PFUser currentUser]];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"could not add to acceptedL %@", error);
        } else if(succeeded) {
            //add to notification class
            NSString *message = [NSString stringWithFormat:@"Your ticket for %@ (tap to view ticket)", self.navigationItem.title];
            
            PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
            notification[@"type"] = @"ticket";
            notification[@"notification"] = message;
            notification[@"event"] = object;
            notification[@"user"] = [PFUser currentUser];
            notification[@"eventTitle"] = self.navigationItem.title;
            
            [notification saveInBackground];
            
            self.attendButton.hidden = YES;
            self.unattendButton.hidden = NO;
        }
    }];

}

- (IBAction)unattendButton:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    [query getObjectInBackgroundWithId:[[self.data valueForKey:TurnipParsePostIdKey] objectAtIndex:0] block:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"Error in query: %@", error);
        } else {
            if (object != nil) {
                PFRelation *relation = [object relationForKey:@"accepted"];
                [relation removeObject:[PFUser currentUser]];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        NSLog(@"Error in save %@",error);
                    } else {
                        NSLog(@"saved");
                        self.unattendButton.hidden = YES;
                        self.requestButton.hidden = NO;
                        
                        NSInteger index = [self.accepted indexOfObject:[PFUser currentUser]];
                        
                        NSLog(@"accepted: %lu", (unsigned long)index);
                    }
                }];
            }
        }
    }];
    
    
    PFQuery *queryNotification = [PFQuery queryWithClassName:@"Notifications"];
    
    [queryNotification whereKey:@"event" equalTo:[[self.data valueForKey:TurnipParsePostIdKey] objectAtIndex:0]];
    [queryNotification whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [queryNotification findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [object deleteEventually];
            }
        } else {
            [ParseErrorHandlingController handleParseError:error];
        }
    }];
    
}

#pragma mark - TableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.accepted count] > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else {
        // Display a message when the table is empty
        messageLabel.text = @"";
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
    return [self.accepted count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"acceptedCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    NSArray *name = [[[self.accepted valueForKey:@"name"] objectAtIndex:indexPath.row] componentsSeparatedByString: @" "];
    NSString *age = @([SAEUtilityFunctions calculateAge: [[self.accepted valueForKey:@"birthday"] objectAtIndex:indexPath.row]]).stringValue;
    [[self.accepted valueForKey:@"birthday"] objectAtIndex:indexPath.row];
    NSString *nameAge = [NSString stringWithFormat:@"%@ - %@", [name objectAtIndex:0], age];

    
    cell.textLabel.text = nameAge;
    cell.imageView.image = [UIImage imageNamed:@"profile"];
    
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[self.accepted valueForKey:@"facebookId"] objectAtIndex:indexPath.row]]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
    
    // Run network request asynchronously
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError == nil && data != nil) {
             // Set the image in the header imageView
             cell.imageView.image = [UIImage imageWithData:data];
         }
     }];
    
    return cell;
}

#pragma mark - Notifications 

- (void)showAddress:(NSNotification *)notification {
    if (self.userIsAccepted) {
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setHour:-2];
        
        NSDate *showDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[[self.data valueForKey:TurnipParsePostDateKey] objectAtIndex:0] options:0];

        self.addressLabel.numberOfLines = 0;
        if(showDate >= [NSDate date]) {
            self.addressLabel.text = [[self.data valueForKey:TurnipParsePostAddressKey] objectAtIndex:0];
        } else {
           NSString *address = [NSString stringWithFormat:@"Address will be shown %@", [SAEUtilityFunctions convertDate: showDate]];
            self.addressLabel.text = address;
        }
        
        [self.addressLabel sizeToFit];
    }
}


@end
