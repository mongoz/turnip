//
//  DetailViewController.m
//  turnip
//
//  Created by Per on 1/14/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "DetailViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface DetailViewController ()

@property (nonatomic, strong) TurnipEvent *data;

@end

@implementation DetailViewController

@synthesize event;
@synthesize objectId;

- (void) viewWillAppear:(BOOL)animated {
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.requestButton.enabled = NO;
    
    if (event != nil) {
        self.objectId = event.objectId;
        self.navigationItem.title = event.title;
    }
    self.profileImage.userInteractionEnabled = YES;
    
    self.imageView1.image = [UIImage imageNamed:@"Placeholder.jpg"]; // placeholder image
    self.imageView2.image = [UIImage imageNamed:@"Placeholder.jpg"]; // placeholder image
    self.imageView3.image = [UIImage imageNamed:@"Placeholder.jpg"]; // placeholder image
    
    [self downloadDetails];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) downloadDetails {
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
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
                    NSLog(@"relations: %lu", (unsigned long)[objects count]);
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

- (void) updateUI : (PFObject *) data {	
    
    self.navigationItem.title = [data objectForKey:TurnipParsePostTitleKey];
    
    self.aboutLabel.text = [data objectForKey:TurnipParsePostTextKey];
}

- (void) downloadImages: (PFObject *) data {
    
    if([data objectForKey:@"image1"] != nil) {
        self.imageView1.file = (PFFile *)[data objectForKey:@"image1"];; // remote image
        [self.imageView1 loadInBackground];
    }
    
    if([data objectForKey:@"image2"] != nil) {
        self.imageView2.file = (PFFile *)[data objectForKey:@"image2"];; // remote image
        [self.imageView2 loadInBackground];
    }
    
    if([data objectForKey:@"image3"] != nil) {
        self.imageView3.file = (PFFile *)[data objectForKey:@"image3"];; // remote image
        [self.imageView3 loadInBackground];
    }
    
    // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [data[@"user"] objectForKey:@"facebookId"]]];
    
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

- (IBAction)profileImageTapHandler:(UITapGestureRecognizer *)sender {

    [self performSegueWithIdentifier:@"profileSegue" sender: self.data.user];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"profileSegue"]) {
        ProfileViewController *destViewController = segue.destinationViewController;
        
        destViewController.user = sender;
    }
}
- (IBAction)requestButtonHandler:(id)sender {
    
    NSString *host = self.data.user.objectId;
    NSString *message = @"Hi I'd like to go to your event";
    
    self.requestButton.enabled = NO; 
    
    [PFCloud callFunctionInBackground:@"requestEventPush"
                       withParameters:@{@"recipientId": host, @"message": message, @"eventId": self.data.objectId}
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"push sent");                                   }
                                }];
}
@end
