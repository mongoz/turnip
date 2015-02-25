//
//  TeammateTableViewController.m
//  turnip
//
//  Created by Per on 2/24/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "TeammateTableViewController.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface TeammateTableViewController ()

@end

@implementation TeammateTableViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"object: %@", self.eventId);
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
    
    [query whereKey:TurnipParsePostIdKey equalTo: self.eventId ];

    
    return query;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.accepted count];
}
- (void) objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    PFRelation *relation = [[self.objects objectAtIndex:0] relationForKey:@"accepted"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] == 0) {
            NSLog(@"no Accepted");
        } else {
            NSLog(@"found :%@", [objects valueForKey:@"name"]);
            
            self.accepted = [[NSArray alloc] initWithArray:objects];
        }
    }];
    
    NSLog(@"%@", self.accepted);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *tableIdentifier = @"teammateCell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    NSLog(@"accapted %@", [object objectForKey:@"accepted"]);

    
    //NSLog(@"object : %@", object);
    
    return cell;
}

@end
