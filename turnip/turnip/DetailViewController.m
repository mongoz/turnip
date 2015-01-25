//
//  DetailViewController.m
//  partay
//
//  Created by Per on 1/14/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "DetailViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface DetailViewController ()

@property (nonatomic, strong) TurnipEvent *data;

@end

@implementation DetailViewController

@synthesize event;
@synthesize objectId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (event != nil) {
        self.objectId = event.objectId;
        self.titleLabel.text = event.title;
        self.navigationItem.title = event.title;
    }
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
    PFQuery *query = [PFQuery queryWithClassName:PartayParsePostClassName];
    
    [query getObjectInBackgroundWithId: self.objectId block:^(PFObject *object, NSError *error) {
        if(error) {
            NSLog(@"Error in query!: %@", error);
        }else {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                [self downloadImages : object];
                [self updateUI : object];
            });
        }
    }];
}

- (void) updateUI : (PFObject *) data {
    //self.titleLabel.text = [data objectForKey:PartayParsePostTitleKey];
    
    self.navigationItem.title = [data objectForKey:PartayParsePostTitleKey];
    
    self.aboutLabel.text = [data objectForKey:PartayParsePostTextKey];
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
}

@end
