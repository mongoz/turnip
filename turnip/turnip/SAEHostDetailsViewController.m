//
//  HostDetailsViewController.m
//  turnip
//
//  Created by Per on 4/21/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "SAEHostDetailsViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import <UIImageView+AFNetworking.h>
#import "TeammateViewController.h"
#import "ScannerViewController.h"
#import "EditViewController.h"
#import "SAEUtilityFunctions.h"

@interface SAEHostDetailsViewController ()

@property (nonatomic, strong) NSMutableArray *pageImages;
@property (nonatomic, strong) NSMutableArray *pageViews;

@property (nonatomic, strong) NSArray *accepted;

@end

@implementation SAEHostDetailsViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventWasUpdated:) name:TurnipPartyUpdateNotification object:nil];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 30.0f, 30.0f)];
    
    UIImage *backImage = [SAEUtilityFunctions imageResize:[UIImage imageNamed:@"backNav"] andResizeTo:CGSizeMake(30, 30)];
    [backButton setBackgroundImage:backImage  forState:UIControlStateNormal];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backNavigation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.title = [self.event valueForKey:@"title"];
    
    self.pageImages = [[NSMutableArray alloc] initWithCapacity:3];
    
    // Set up the content size of the scroll view
    
    [self queryForAcceptedUsers];
    [self updateUI: self.event];
    
    [self.scrollView layoutIfNeeded];
    [self.scrollView setNeedsLayout];
    [self drawImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateUI: (NSArray *) event {
    
    CALayer *borderLayer = [CALayer layer];
    CGRect borderFrame = CGRectMake(-5, -5, (self.profileImage.frame.size.width + 10), (self.profileImage.frame.size.height + 10));
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setBorderWidth:5];
    [borderLayer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.profileImage.layer addSublayer:borderLayer];
    
    NSArray *name = [[[PFUser currentUser] objectForKey:@"name"] componentsSeparatedByString: @" "];
    NSString *age = @([SAEUtilityFunctions calculateAge: [[PFUser currentUser] objectForKey:@"birthday"]]).stringValue;
    [[PFUser currentUser] objectForKey:@"birthday"];
    
    NSString *nameAge = [NSString stringWithFormat:@"%@ - %@", [name objectAtIndex:0], age];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString: nameAge];
    
    NSRange range = [nameAge rangeOfString:[name objectAtIndex:0]];
    
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.549 green:0 blue:0.102 alpha:1] range:range];
    
    [self.nameLabel setAttributedText:string];

    self.addressLabel.numberOfLines = 0;
    self.addressLabel.text = [event valueForKey:@"location"];
    [self.addressLabel sizeToFit];
    
    self.aboutLabel.numberOfLines = 0;
    self.aboutLabel.text = [event valueForKey:TurnipParsePostTextKey];
    [self.aboutLabel sizeToFit];
    
    self.neighbourhoodLabel.text = [event valueForKey:@"neighbourhood"];
    
    self.dateLabel.text = [SAEUtilityFunctions convertDate: [event valueForKey:TurnipParsePostDateKey]];
    
    
    NSString *price = @"";
    NSString *open = @"";
    
    if ([[event valueForKey:TurnipParsePostPrivateKey] boolValue]) {
        open  = @"Private";
    } else {
        open = @"Public";
    }
    
    if ([[event valueForKey:TurnipParsePostPaidKey] boolValue]) {
        price = @"Free";
    } else {
        price = [NSString stringWithFormat:@"$%@",[event valueForKey:TurnipParsePostPriceKey]];
    }
    
    self.privateLabel.text = [NSString stringWithFormat:@"%@, %@", open, price];
    
}

- (void) drawImages {
    // Set up the image we want to scroll and add it to the scroll view
    
    for (int i = 1; i <= 3; i++) {
        NSString *imageName = [NSString stringWithFormat:@"image%d",i];
        if ([self.event valueForKey:imageName] != nil) {
            
            [self.pageImages addObject: [self.event valueForKey:imageName]];
        }
    }

    
    if ([[PFUser currentUser] valueForKey:@"profileImage"] != nil) {
        NSURL *url = [NSURL URLWithString: [[PFUser currentUser] valueForKey:@"profileImage"]];
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
        [self downloadFacebookProfilePicture:[[PFUser currentUser] objectForKey:@"facebookId"]];
    }
    
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height);
    
    // Set up the page control
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = self.pageImages.count;
    
    // Set up the array to hold the views for each page
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.pageImages.count; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
    
    [self loadVisiblePages];
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

- (void) queryForAcceptedUsers {
    PFQuery *query = [PFQuery queryWithClassName: TurnipParsePostClassName];
    
    if ([self.accepted count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query getObjectInBackgroundWithId: [self.event valueForKey:@"objectId"] block:^(PFObject *object, NSError *error) {
        if(error) {
            NSLog(@"Error in query!: %@", error);
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                PFRelation *relation = [object relationForKey:@"accepted"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                   // [self.refreshControl endRefreshing];
                    if([objects count] == 0) {
                        [self.goingButton setTitle:@"0" forState:UIControlStateNormal];
                    } else {
                        self.accepted = [[NSArray alloc] initWithArray:objects];
                        [[self tableView] reloadData];
                        [self.goingButton setTitle:@([self.accepted count]).stringValue forState:UIControlStateNormal];
                    }
                }];
            });
        }
    }];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"scannerSegue"]) {
        ScannerViewController *scannerController = segue.destinationViewController;
        scannerController.eventId = [self.event valueForKey:@"objectId"] ;
    }
    
    if ([segue.identifier isEqualToString:@"addTeammateSegue"]) {
        TeammateViewController *teammateController = segue.destinationViewController;
        teammateController.eventId = [self.event valueForKey:@"objectId"];
        teammateController.accepted = [[NSMutableArray alloc] initWithArray:self.accepted];
    }
    
    if ([segue.identifier isEqualToString:@"editEventSegue"]) {
        EditViewController *editController = segue.destinationViewController;
        editController.currentEvent = self.event;
    }

}


- (IBAction)deleteButton:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Are you sure you want to delete this.  This action cannot be undone" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
    [alert show];
}

- (IBAction)editButton:(id)sender {
}

- (IBAction)teammateButton:(id)sender {
}

- (IBAction)scannerButton:(id)sender {
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

-(void) backNavigation {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    [self presentViewController:mvc animated:YES completion:nil];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //delete it
        [self deleteFromParse];
        [self deleteFromCoreData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TurnipEventDeletedNotification object:nil];
        [self performSegueWithIdentifier:@"unwindToThrow" sender:self];
        
    }
}

#pragma mark - Delete methods

- (void) deleteFromParse {
    PFObject *object = [PFObject objectWithoutDataWithClassName:@"Events" objectId: [self.event valueForKey:@"objectId"] ];
    [object deleteInBackground];
}

- (void) deleteFromCoreData {

    NSArray *temp = [[NSArray alloc] initWithObjects:self.event, nil];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSError *error;
    for (NSManagedObject *managedObject in temp) {
        [context deleteObject:managedObject];
    }
    
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Event Deleted");
    
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
        newPageView.contentMode = UIViewContentModeScaleAspectFill;
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

    cell.textLabel.text = [[self.accepted valueForKey:@"name"] objectAtIndex:indexPath.row];
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

- (void) eventWasUpdated: (NSNotification *) note {
    NSArray *event = [[NSArray alloc] initWithArray:[self loadCoreData]];
    
    [self updateUI: [event objectAtIndex:0]];
}

#pragma mark - Core Data

- (NSArray *) loadCoreData {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"YourEvents" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [[NSArray alloc] initWithArray:[context executeFetchRequest:fetchRequest error: &error]];
    
    if ([fetchedObjects count] == 0) {
        return nil;
    } else {
        
        return fetchedObjects;
    }
}


@end
