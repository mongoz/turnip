//
//  SAEDetailsViewController.m
//  turnip
//
//  Created by Per on 9/17/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//
#import "Constants.h"
#import "SAEMessagingViewController.h"
#import "ProfileViewController.h"
#import "SAEDetailsViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "SAEAttendingTableViewController.h"

@interface SAEDetailsViewController ()

@end

@implementation SAEDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:self.event.title];
    
    [self.event.eventImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            [self.imageView setImage:image];
        }
    }];
    
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
   
    if ([[self.event valueForKey:@"host"] objectForKey:@"profileImage"] != nil) {
        NSURL *url = [NSURL URLWithString: [[self.event valueForKey:@"host"] objectForKey:@"profileImage"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.center = self.profileImageView.center;
        [self.view addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        
        __weak SAEDetailsViewController *weakself = self;
        [self.profileImageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              
                                              [activityIndicatorView removeFromSuperview];
                                              
                                              [weakself.profileImageView setImage:image];
                                          }
                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                              [activityIndicatorView removeFromSuperview];
                                              
                                          }];
    } else {
        [self downloadFacebookProfilePicture:[self.event.host objectForKey:@"facebookId"]];
    }

    self.hostLabel.text = [self.event.host valueForKey:@"firstName"];
    [self.attendingButton setTitle:[NSString stringWithFormat:@"Attending %lu", (unsigned long)[self.event.attendees count]] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
    
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [self.profileImageView addGestureRecognizer:recognizer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)attendButton:(id)sender {
    
    if (self.event.isPrivate) {
        [self requestToAttendEvent];
    } else {
        [self attendEvent];
    }
}

- (IBAction)attendingButton:(id)sender {
    [self performSegueWithIdentifier:@"attendingSegue" sender:nil];
}

- (IBAction)messageButton:(id)sender {
    [self performSegueWithIdentifier:@"messageSegue" sender:nil];
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
             self.profileImageView.image = [UIImage imageWithData:data];
         }
     }];
}

#pragma mark - attendParty

- (void) requestToAttendEvent {
    NSString *host = [[self.event valueForKey:@"host"] valueForKey:@"objectId"];
    NSArray *name = [[[PFUser currentUser] objectForKey:@"name"] componentsSeparatedByString: @" "];
    
    NSString *message = [NSString stringWithFormat:@"%@ Wants to go to your party", [name objectAtIndex:0]];
    
    [PFCloud callFunctionInBackground:@"requestEventPush"
                       withParameters:@{@"recipientId": host, @"message": message, @"eventId": self.event.objectId }
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"push sent");
                                    }
                                }];
    
}

- (void) attendEvent {
    PFObject *object = [PFObject objectWithoutDataWithClassName:TurnipParsePostClassName objectId:self.event.objectId];
    
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
            notification[@"eventTitle"] = self.event.title;
            
            [notification saveInBackground];
        }
    }];
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"profileSegue"]) {
         ProfileViewController *destViewController = segue.destinationViewController;
         destViewController.user = [self.event valueForKey:@"host"];
     }
     
     if ([segue.identifier isEqualToString:@"messageSegue"]) {
         SAEMessagingViewController *destViewController = segue.destinationViewController;
         destViewController.user = [self.event valueForKey:@"host"];
     }
     
     if ([segue.identifier isEqualToString:@"attendingSegue"]) {
         SAEAttendingTableViewController *destViewController = segue.destinationViewController;
         destViewController.attendees = self.event.attendees;
     }
     
 }

- (IBAction)backNavigationButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Utils
- (void) touch {
    [self performSegueWithIdentifier:@"profileSegue" sender:nil];
}
@end
