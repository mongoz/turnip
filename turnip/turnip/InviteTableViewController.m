//
//  InviteTableViewController.m
//  turnip
//
//  Created by Per on 4/15/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "InviteTableViewController.h"
#import "ProfileViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface InviteTableViewController ()

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;

@end

@implementation InviteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    if (self.contacts) {
        return self.contacts.count;
    } else {
       return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    NSDictionary *contactInfoDict = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [contactInfoDict objectForKey:@"firstName"], [contactInfoDict objectForKey:@"lastName"]];
    return cell;
}

 
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) showAddressBook {
    self.addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [self.addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:self.addressBookController animated:YES completion:nil];
}

- (IBAction)backNavigation:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ProfileViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"profileView"];
    [self.navigationController pushViewController:lvc animated:YES];
}

- (IBAction)FBInviteButton:(id)sender {
    FBSDKAppInviteContent *content = [[FBSDKAppInviteContent alloc] initWithAppLinkURL:[NSURL URLWithString:@"https://fb.me/910852172311191"]];
    
    content.previewImageURL = [NSURL URLWithString:@"http://www.turnipapp.com/invite.png"];
    
    [FBSDKAppInviteDialog showWithContent:content delegate:self];
}

#pragma mark -
#pragma mark FBAppInviteDelegate

- (void) appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"results: %@", results);
}

- (void) appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}

@end
