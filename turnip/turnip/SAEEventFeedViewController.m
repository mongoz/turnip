//
//  SAEEventFeedViewController.m
//  turnip
//
//  Created by Per on 8/4/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEEventFeedViewController.h"
#import "SAEEventFeedViewCell.h"
#import "SAEUtilityFunctions.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "ParseErrorHandlingController.h"
#import "Constants.h"

@interface SAEEventFeedViewController ()

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL firstTime;

@end

@implementation SAEEventFeedViewController

- (void) locationManagerDidUpdateLocation:(CLLocation *)location {
    self.currentLocation = location;
    if (self.firstTime) {
        self.firstTime = NO;
        [self queryEvents];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [[SAELocationManager sharedInstance] addLocationManagerDelegate: self];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[SAELocationManager sharedInstance] removeLocationManagerDelegate:self];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"turnip.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(queryEvents) forControlEvents:UIControlEventValueChanged];
    
    self.firstTime = YES;
    
    self.events = [[NSMutableArray alloc] init];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.activityIndicator.color = [UIColor blackColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = self.activityIndicator;
}

- (void) queryEvents {
    
    [self.activityIndicator startAnimating];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude
                                               longitude:self.currentLocation.coordinate.longitude];
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    if([self.events count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query selectKeys:@[TurnipParsePostTitleKey, TurnipParsePostPrivateKey, TurnipParsePostThumbnailKey, TurnipParsePostStartDateKey, TurnipParsePostIdKey, TurnipParsePostUserKey, TurnipParsePostLocationKey]];
    
    [query whereKey:@"location"
       nearGeoPoint:point
        withinMiles:TurnipPostMaximumSearchDistance];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            [ParseErrorHandlingController handleParseError:error];
        } else {
            if ([self.refreshControl isRefreshing]) {
                [self.refreshControl endRefreshing];
            }
            
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            
            if ([objects count] != 0) {
                for (NSArray *event in objects) {
                    NSLog(@"event: %@", event);
                }
            }
        }
    }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.events count] < 1) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        return 1;
    } else if(![self.activityIndicator isAnimating]){
        // Display a message when the table is empty
        messageLabel.text = @"No events nearby";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Arial-Bold" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
    }
    return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static SAEEventFeedViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"eventCell"];
    });
    
    return [self calculateHeightForCell:sizingCell];
}

- (CGFloat)calculateHeightForCell:(SAEEventFeedViewCell *) cell {
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    
    CGSize size = self.tableView.frame.size;
    
    cell.imageView.frame = CGRectMake(0, 0, size.width, size.width);
    
    CGSize imageSize = cell.imageView.frame.size;
    
    return imageSize.height + 55.0f; // Add 1.0f for the cell separator height
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"eventCell";
    SAEEventFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[SAEEventFeedViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
    cell.profileImage.clipsToBounds = YES;
    
    return cell;
    
}

#pragma mark - Navigation

@end
