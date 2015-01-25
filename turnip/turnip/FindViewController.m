//
//  FindViewController.m
//  partay
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "FindViewController.h"
#import "DetailViewController.h"
#import "FindTableCell.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "TurnipEvent.h"
#import "Constants.h"

@interface FindViewController ()

@end

@implementation FindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Posts";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"title";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
    }
    return self;
}

- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    if([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    CLLocation *currentLocation = [self.dataSource currentLocationForFindViewController:self];
    [query selectKeys:@[PartayParsePostTitleKey, PartayParsePostLocationKey, PartayParsePostThumbnailKey]];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude: currentLocation.coordinate.longitude];
    [query whereKey:PartayParsePostLocationKey nearGeoPoint:point withinMiles: PartayPostMaximumSearchDistance];
    
    return query;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *simpleTableIdentifier = @"PartayCell";
    
    FindTableCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[FindTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    
    // Configure the cell
    PFFile *thumbnail = [object objectForKey: PartayParsePostThumbnailKey];
    UIImage *placeholder = [UIImage imageNamed:@"placeholder.jpg"];
    
    //Use a placeholder image before we have downloaded the real one.
    cell.eventImageView.image = placeholder;
    cell.eventImageView.file = thumbnail;
    
    cell.titleLabel.text = [object objectForKey: PartayParsePostTitleKey];
    cell.distanceLabel.text = [self distanceFromCurrLocation: [object objectForKey: @"location" ]];
    
    [cell.eventImageView loadInBackground];
    
    return cell;
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void) objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    if (error != nil) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
}

//Calculate the distance from current location to the destination Partay
//Returns a NSString
- (NSString *) distanceFromCurrLocation : (PFGeoPoint *) point {
    
    CLLocation *currentLocation = [self.dataSource currentLocationForFindViewController:self];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
    
    CLLocationDistance meters = [currentLocation distanceFromLocation: destinationLocation];
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    NSNumber *mile = [NSNumber numberWithDouble: PartayMetersToMiles(meters)];
    
    NSString *stringMile = [fmt stringFromNumber:mile];
    
    return stringMile;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPartayDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *destViewController = segue.destinationViewController;
        
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        TurnipEvent *event = [[TurnipEvent alloc] initWithPFObject:object];
        
        destViewController.event = event;
        
    }
}


@end