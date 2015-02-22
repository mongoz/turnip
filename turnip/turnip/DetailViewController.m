//
//  DetailViewController.m
//  turnip
//
//  Created by Per on 1/14/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ScannerViewController.h"
#import "SWRevealViewController.h"
#import "DetailViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize event;

- (void) viewWillAppear:(BOOL)animated {
    
    if(self.deleted) {
        [self performSegueWithIdentifier:@"unwindToThrow" sender:self];
    }
    
    [self.tabBarController.tabBar setHidden:NO ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.requestButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventWasDeleted:) name:@"eventDeletedNotification" object:nil];
     
    if (self.host) {
        self.deleted = NO;
        SWRevealViewController *revealViewController = self.revealViewController;
        if ( revealViewController )
        {
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(toggleSideMenu:)];
            self.navigationController.navigationBar.topItem.rightBarButtonItem = rightButton;
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
            
        }
        [self hostDetailSetupView];
    }
    
   else if (event != nil) {
       self.deleted = NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.objectId = event.objectId;
        self.navigationItem.title = event.title;
        [self downloadDetails];
        self.profileImage.userInteractionEnabled = YES;
    } else {
        NSLog(@"nothing found");
    }
}

- (void)eventWasDeleted:(NSNotification *)note {
    self.deleted = YES;
    self.host = NO;
    [self viewWillAppear:YES];
}

-(IBAction)toggleSideMenu:(id)sender
{
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController rightRevealToggleAnimated:YES];
}

- (void) hostDetailSetupView {
    self.navigationController.navigationBar.topItem.title = [[self.yourEvent valueForKey:@"title"] objectAtIndex:0];
    self.requestButton.hidden = YES;
    self.headerView.hidden = NO;
    
    self.titleLabel.text = [[self.yourEvent valueForKey:@"title"] objectAtIndex:0];
    self.nameLabel.text = [[PFUser currentUser] valueForKey:@"name"];
    
    self.aboutLabel.text = [[self.yourEvent valueForKey:@"text"] objectAtIndex:0];
    
    if ([[self.yourEvent valueForKey:@"image1"] objectAtIndex:0] != (id)[NSNull null]) {
        self.imageView1.image = [[self.yourEvent valueForKey:@"image1"] objectAtIndex:0];
    }
    
    if ([[self.yourEvent valueForKey:@"image2"] objectAtIndex:0] != (id)[NSNull null]) {
        self.imageView2.image = [[self.yourEvent valueForKey:@"image2"] objectAtIndex:0];
    }
    
    if ([[self.yourEvent valueForKey:@"image3"] objectAtIndex:0] != (id)[NSNull null]) {
        self.imageView3.image = [[self.yourEvent valueForKey:@"image3"] objectAtIndex:0];
    }
    
    
    if ([[[self.yourEvent valueForKey:@"private"] objectAtIndex:0] boolValue]) {
        self.openLabel.text = @"Private";
    } else {
        self.openLabel.text = @"Public";
    }

    if ([[[self.yourEvent valueForKey:@"free"] objectAtIndex:0] boolValue]) {
        self.freePaidLabel.text = @"Free";
    } else {
        self.freePaidLabel.text = @"Paid";
    }
    
    [self downloadFacebookProfilePicture:[[PFUser currentUser] valueForKey:@"facebookId" ]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) downloadDetails {
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
 
    [query includeKey:TurnipParsePostUserKey];
    [query whereKey:@"requests" equalTo:[PFUser currentUser]];
    [query getObjectInBackgroundWithId: self.objectId block:^(PFObject *object, NSError *error) {
        if(error) {
            NSLog(@"Error in query!: %@", error);
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                PFRelation *relation = [object relationForKey:@"requests"];
                PFQuery *query = [relation query];
                [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if([objects count] == 0) {
                        self.requestButton.enabled = YES;
                    }
                }];
                
                self.data = [[TurnipEvent alloc] initWithPFObject:object];
                [self downloadImages : object];
                [self updateUI : object];
                
            });
        }
    }];
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

- (void) updateUI : (PFObject *) data {	
    
    self.navigationItem.title = [data objectForKey:TurnipParsePostTitleKey];
    
    //self.titleLabel.text = [data objectForKey:TurnipParsePostTitleKey];
    self.aboutLabel.text = [data objectForKey:TurnipParsePostTextKey];
}

- (void) downloadImages: (PFObject *) data {
    
    if([data objectForKey:@"image1"] != nil) {
        self.imageView1.file = (PFFile *)[data objectForKey:@"image1"];; // remote image
        [self.imageView1 loadInBackground];
    } else {
        self.imageView1.hidden = YES;
    }
    
    if([data objectForKey:@"image2"] != nil) {
        self.imageView2.file = (PFFile *)[data objectForKey:@"image2"];; // remote image
        [self.imageView2 loadInBackground];
    } else {
        self.imageView2.hidden = YES;
    }
    
    if([data objectForKey:@"image3"] != nil) {
        self.imageView3.file = (PFFile *)[data objectForKey:@"image3"];; // remote image
        [self.imageView3 loadInBackground];
    } else {
        self.imageView3.hidden = YES;
    }
    
    [self downloadFacebookProfilePicture:[data[@"user"] objectForKey:@"facebookId"]];

}

- (IBAction)profileImageTapHandler:(UITapGestureRecognizer *)sender {

    [self performSegueWithIdentifier:@"profileSegue" sender: self.data.user];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"profileSegue"]) {
        ProfileViewController *destViewController = segue.destinationViewController;
    
        destViewController.user = sender;
    }
}
- (IBAction)sidemenuButtonHandler:(id)sender {
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController rightRevealToggleAnimated:YES];
}

- (IBAction)requestButtonHandler:(id)sender {
    
    NSString *host = self.data.user.objectId;
    
    NSArray *name = [[[PFUser currentUser] objectForKey:@"name"] componentsSeparatedByString: @" "];

    NSString *message = [NSString stringWithFormat:@"%@ Wants to go to your party", [name objectAtIndex:0]];
    
    self.requestButton.enabled = NO; 
    
    [PFCloud callFunctionInBackground:@"requestEventPush"
                       withParameters:@{@"recipientId": host, @"message": message, @"eventId": self.data.objectId}
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"push sent");
                                    }
                                }];
}

@end
