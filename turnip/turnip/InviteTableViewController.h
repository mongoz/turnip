//
//  InviteTableViewController.h
//  turnip
//
//  Created by Per on 4/15/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface InviteTableViewController : UITableViewController <FBSDKAppInviteDialogDelegate, ABPeoplePickerNavigationControllerDelegate>

- (IBAction)backNavigation:(id)sender;
- (IBAction)FBInviteButton:(id)sender;
@end
