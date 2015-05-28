//
//  ParseErrorHandlingController.m
//  turnip
//
//  Created by Per on 5/5/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ParseErrorHandlingController.h"
#import <Parse/Parse.h>

@implementation ParseErrorHandlingController

+ (void)handleParseError:(NSError *)error {
    if (![error.domain isEqualToString:PFParseErrorDomain]) {
        return;
    }
    
    switch (error.code) {
        case kPFErrorInvalidSessionToken: {
            [self _handleInvalidSessionTokenError];
            break;
        }

         //   ... // Other Parse API Errors that you want to explicitly handle.
    }
}

+ (void)_handleInvalidSessionTokenError {
    [PFUser logOut];

    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UIViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    [topController presentViewController:lvc animated:YES completion:nil];
}

@end