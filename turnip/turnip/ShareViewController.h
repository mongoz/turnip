//
//  ShareViewController.h
//  turnip
//
//  Created by Per on 4/17/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface ShareViewController : UIViewController <FBSDKAppInviteDialogDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

- (IBAction)emailButton:(id)sender;
- (IBAction)SMSbutton:(id)sender;
- (IBAction)facebookButton:(id)sender;

- (IBAction)backNavigation:(id)sender;
@end
