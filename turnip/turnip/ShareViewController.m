//
//  ShareViewController.m
//  turnip
//
//  Created by Per on 4/17/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ShareViewController.h"
#import "ProfileViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backNavigation:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ProfileViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"profileView"];
    [self.navigationController pushViewController:lvc animated:YES];
}

- (IBAction)facebookButton:(id)sender {
    FBSDKAppInviteContent *content = [[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/910852172311191"];
  
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://www.turnipapp.com/invite.png"];
    
    [FBSDKAppInviteDialog showWithContent:content delegate:self];
}

- (IBAction)emailButton:(id)sender {
    
    NSString *emailTitle = @"Come Join us on Turnip!";
    NSString *messageBody = @"You should checkout this new cool app: http://www.turnipapp.com";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:nil];
    
    if (mc != nil) {
         [self presentViewController:mc animated:YES completion:nil];
    }
}

- (IBAction)SMSbutton:(id)sender {
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningText = [[UIAlertView alloc] initWithTitle:@"error" message:@"Your device does not support SMS!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [warningText show];
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"Check out this new app: http://www.turnipapp.com"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    
    [self presentViewController:messageController animated:YES completion:nil];
    
}


#pragma mark -
#pragma mark FBAppInviteDelegate

- (void) appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"results: %@", results);
}

- (void) appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case  MessageComposeResultFailed: {
            UIAlertView *warningText = [[UIAlertView alloc] initWithTitle:@"error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [warningText show];
            break;
        }
            case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
            case MFMailComposeResultSaved:
            break;
            case MFMailComposeResultFailed:
            break;
            case MFMailComposeResultSent:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
