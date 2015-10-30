//
//  SAETabBarViewController.m
//  turnip
//
//  Created by Per on 2/25/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "SAEHostSingleton.h"
#import "SAEHostDetailsViewController.h"
#import "SAETabBarViewController.h"
#import "Constants.h"

@interface SAETabBarViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong) SAEHostSingleton *event;
@property (nonatomic, strong) UIViewController *hostController;
@property (nonatomic, strong) UIViewController *currentViewController;

@end

@implementation SAETabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.event = [SAEHostSingleton sharedInstance];
    
    //[[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar_selected.png"]];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];

    [self setDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == TurnipTabHost && self.event.saved) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];
        SAEHostDetailsViewController *host =
        [storyboard instantiateViewControllerWithIdentifier:@"hostDetailsNav"];
        
        [self presentViewController:host
                           animated:NO
                         completion:nil];
    }
}
- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    self.currentViewController = tabBarController.selectedViewController;
    
    if ([self.currentViewController isEqual:viewController]) {
        return NO;
    }
   // && self.event.saved
    
    return YES;
}


@end
