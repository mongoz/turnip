//
//  SAEHostDetailsViewController.m
//  turnip
//
//  Created by Per on 10/10/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "Constants.h"
#import "SAEHostSingleton.h"
#import "SAEHostDetailsViewController.h"
#import <UIImageView+AFNetworking.h>
#import "TeammateViewController.h"
#import "ScannerViewController.h"
#import "EditViewController.h"
#import "RequestViewController.h"
#import "SAEEventFeedViewController.h"
#import "SAETabBarViewController.h"

@interface SAEHostDetailsViewController ()

@property (nonatomic, strong) SAEHostSingleton *event;
@property (nonatomic, strong) NSArray *attendees;

@end

@implementation SAEHostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.event = [SAEHostSingleton sharedInstance];
    
    [self setTitle:self.event.title];
    
    [self.imageView setImage:self.event.eventImage];
    [self downloadAttendees];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Parse

- (void) downloadAttendees {
    PFQuery *query = [PFQuery queryWithClassName: TurnipParsePostClassName];
    
    if ([self.attendees count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query getObjectInBackgroundWithId: self.event.objectId block:^(PFObject *object, NSError *error) {
        if(error) {
            NSLog(@"Error in query!: %@", error);
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                PFRelation *relation = [object relationForKey:@"accepted"];
                PFQuery *query = [relation query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if([objects count] == 0) {
                        [self.attendingButton setTitle:@"0" forState:UIControlStateNormal];
                    } else {
                        self.attendees = [[NSArray alloc] initWithArray:objects];
                        [self.attendingButton setTitle:@([self.attendees count]).stringValue forState:UIControlStateNormal];
                    }
                }];
            });
        }
    }];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"scannerSegue"]) {
        ScannerViewController *scannerController = segue.destinationViewController;
        scannerController.eventId = self.event.objectId;
    }
    
    if ([segue.identifier isEqualToString:@"addTeammateSegue"]) {
        TeammateViewController *teammateController = segue.destinationViewController;
        teammateController.eventId = self.event.objectId;
        teammateController.attending = self.attendees;
    }
    
    if ([segue.identifier isEqualToString:@"editEventSegue"]) {
        EditViewController *editController = segue.destinationViewController;
       // editController.currentEvent = self.event;
    }
}

#pragma mark - button handlers

- (IBAction)backNavigation:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    SAETabBarViewController *feed =
    [storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    
    [self presentViewController:feed
                       animated:NO
                     completion:nil];
}

- (IBAction)scannerButton:(id)sender {
    [self performSegueWithIdentifier:@"scannerSegue" sender:nil];
}

- (IBAction)teammateButton:(id)sender {
    [self performSegueWithIdentifier:@"addTeammateSegue" sender:nil];
}

- (IBAction)editButton:(id)sender {
    [self performSegueWithIdentifier:@"editEventSegue" sender:nil];
}

- (IBAction)requestButton:(id)sender {
    [self performSegueWithIdentifier:@"requestViewSegue" sender:nil];
}

- (IBAction)attendingButton:(id)sender {
}
@end
