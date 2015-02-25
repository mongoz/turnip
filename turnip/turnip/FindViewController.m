//
//  FindViewController.m
//  turnip
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

- (void) viewWillAppear:(BOOL)animated {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

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
        self.parseClassName = @"Events";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = TurnipParsePostTitleKey;
        
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
    
    [query selectKeys:@[TurnipParsePostTitleKey, TurnipParsePostLocationKey, TurnipParsePostThumbnailKey, TurnipParsePostPrivateKey, TurnipParsePostPublicKey, @"date"]];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude: self.currentLocation.coordinate.latitude longitude: self.currentLocation.coordinate.longitude];
    [query whereKey:TurnipParsePostLocationKey nearGeoPoint:point withinMiles: TurnipPostMaximumSearchDistance];
    
    return query;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *tableIdentifier = @"eventCell";
    
    FindTableCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[FindTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd hh:mm a";
    
    // Configure the cell
    PFFile *thumbnail = [object objectForKey: TurnipParsePostThumbnailKey];
    UIImage *placeholder = [UIImage imageNamed:@"Placeholder.jpg"];
    
    //Use a placeholder image before we have downloaded the real one.
    cell.eventImageView.image = placeholder;
    cell.eventImageView.file = thumbnail;
    
    cell.titleLabel.text = [object objectForKey: TurnipParsePostTitleKey];
    cell.distanceLabel.text = [self distanceFromCurrLocation: [object objectForKey: @"location" ]];
    cell.dateLabel.text = [dateFormatter stringFromDate: [object objectForKey:@"date"]];
    
    if ([[object objectForKey:TurnipParsePostPrivateKey] isEqualToString:@"False"]) {
        cell.statusImage.image = [UIImage imageNamed:@"green.png"];
    }
    if ([[object objectForKey:TurnipParsePostPrivateKey] isEqualToString:@"True"]) {
        cell.statusImage.image = [UIImage imageNamed:@"red.png"];
    }
    
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
    
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
    
    CLLocationDistance meters = [self.currentLocation distanceFromLocation: destinationLocation];
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    NSNumber *mile = [NSNumber numberWithDouble: [self metersToMiles:meters]];
    
    NSString *stringMile = [fmt stringFromNumber:mile];
    
    return stringMile;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEventDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *destViewController = segue.destinationViewController;
        
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        TurnipEvent *event = [[TurnipEvent alloc] initWithPFObject:object];
        
        destViewController.event = event;
    }
}

-(double) metersToMiles:(double) meters {
    return meters * 0.000621371;
}

@end