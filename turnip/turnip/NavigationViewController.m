//
//  NavigationViewController.m
//  turnip
//
//  Created by Per on 2/5/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "NavigationViewController.h"
#import "TicketViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface NavigationViewController ()

@property (nonatomic, assign) NSUInteger nbItems;
@property (nonatomic, strong) NSMutableArray *notifications;

@end

@implementation NavigationViewController

NSArray *fetchedObjects;

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.tabBarItem setBadgeValue: nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TicketInfo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    fetchedObjects = [context executeFetchRequest:fetchRequest error: &error];
    
    if([fetchedObjects count] > 0) {
        self.notifications = [fetchedObjects copy];
    } else {
        NSLog(@"derp");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.notifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"noteCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    
    //cell.textLabel.text = [[fetchedObjects valueForKey:@"title"] objectAtIndex: indexPath.row];
    cell.textLabel.text = @"Accepted to event";
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
    
    [self performSegueWithIdentifier:@"ticketSegue" sender:self];
}


#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ticketSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TicketViewController *destViewController = segue.destinationViewController;
        
        NSString *title = [[self.notifications valueForKey:@"title"] objectAtIndex:indexPath.row];
        NSString *objectId = [[self.notifications valueForKey:@"objectId"] objectAtIndex:indexPath.row];
        NSDate *date = [[self.notifications valueForKey:@"date"] objectAtIndex:indexPath.row];
        NSString *address = [[self.notifications valueForKey:@"address"] objectAtIndex: indexPath.row];
        
        destViewController.ticketTitle = title;
        destViewController.objectId = objectId;
        destViewController.date = date;
        destViewController.address = address;
    }
}

@end
