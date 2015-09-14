//
//  SidebarTableViewController.m
//  turnip
//
//  Created by Per on 1/29/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "SidebarTableViewController.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface SidebarTableViewController ()

@end


@implementation SidebarTableViewController {
    NSArray *menuItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menuItems = @[@"editProfile", @"tos", @"contact", @"invite", @"payment", @"signout"];
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
    
    if (indexPath.row == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName: TurnipEditUserProfileNotification object:nil];
        [self.revealViewController revealToggleAnimated:YES];
    }
    
    if (indexPath.row == 2) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.turnipapp.com/#support"]];
    }
    
    if (indexPath.row == 5) {
        [PFUser logOut];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"loginView"];
        [self presentViewController:lvc animated:YES completion:nil];

    }
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
     UINavigationController *destViewController = (UINavigationController *) segue.destinationViewController;
     destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
     
 }


@end
