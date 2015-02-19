//
//  DetailSidebarTableViewController.m
//  turnip
//
//  Created by Per on 2/18/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "DetailSidebarTableViewController.h"
#import "ScannerViewController.h"

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
    
    NSLog(@"event: %@", self.event);
    
    menuItems = @[@"title" , @"edit", @"delete" ,@"teammate", @"scanner"];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(50, 0, 0, 0)];
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
    
}


#pragma mark - Delete methods

- (void) deleteFromParse {
    
}

- (void) deleteFromCoreData {
    
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
    
}



@end
