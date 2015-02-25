//
//  DetailSidebarTableViewController.m
//  turnip
//
//  Created by Per on 2/18/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Constants.h"
#import "DetailSidebarTableViewController.h"
#import "ScannerViewController.h"
#import "TeammateTableViewController.h"

@interface DetailSidebarTableViewController ()

@end

@implementation DetailSidebarTableViewController {
    NSArray *menuItems;
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (void) viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menuItems = @[@"edit", @"delete" ,@"teammate", @"scanner"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Are you sure you want to delete this.  This action cannot be undone" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
}

#pragma mark - Delete methods

- (void) deleteFromParse {
    PFObject *object = [PFObject objectWithoutDataWithClassName:@"Events" objectId: [[self.event valueForKey:@"objectId"] objectAtIndex:0]];
    [object deleteInBackground];
}

- (void) deleteFromCoreData {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSError *error;
    for (NSManagedObject *managedObject in self.event) {
        [context deleteObject:managedObject];
    }
    
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Event Deleted");
   
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController *) segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    
    if ([segue.identifier isEqualToString:@"scannerSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        ScannerViewController *scannerController = [navController childViewControllers].firstObject;
        scannerController.eventId = [[self.event valueForKey:@"objectId"] objectAtIndex:0];
    }
    
    if ([segue.identifier isEqualToString:@"teammateSegue"]) {
        TeammateTableViewController *teammateController = segue.destinationViewController;
        teammateController.eventId = [[self.event valueForKey:@"objectId"] objectAtIndex:0];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //delete it
        [self deleteFromParse];
        [self deleteFromCoreData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TurnipEventDeletedNotification object:nil];
    }
}



@end
