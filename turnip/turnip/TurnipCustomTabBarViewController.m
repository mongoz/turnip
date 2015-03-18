//
//  TurnipCustomTabBarViewController.m
//  turnip
//
//  Created by Per on 2/25/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "TurnipCustomTabBarViewController.h"
#import "Constants.h"

@interface TurnipCustomTabBarViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong) UIViewController *hostController;
@property (nonatomic, strong) UIViewController *currentViewController;

@end

@implementation TurnipCustomTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UITabBar *tabBar = self.tabBar;
//    
//    UIImage *homeImage = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    UIImage *hostImage = [[UIImage imageNamed:@"Red-Solo-Cup"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    //UIImage *profileImage = [[UIImage imageNamed:@"profile"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    UIImage *notificationImage = [[UIImage imageNamed:@"notifications"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    
//    UITabBarItem *tabHome = [tabBar.items objectAtIndex: TurnipTabHome];
//    UITabBarItem *tabHost = [tabBar.items objectAtIndex: TurnipTabHost];
//    UITabBarItem *tabNotification = [tabBar.items objectAtIndex: TurnipTabNotification];
//   //UITabBarItem *tabProfile = [tabBar.items objectAtIndex: TurnipTabProfile];
//    
//    tabHome = [tabHome initWithTitle:@"Home" image:homeImage selectedImage:homeImage];
//    tabHost = [tabHost initWithTitle:@"Host" image:hostImage selectedImage:hostImage];
//    tabNotification = [tabNotification initWithTitle:@"Notifications" image:notificationImage selectedImage:notificationImage];
//  //  tabProfile = [tabProfile initWithTitle:@"Profile" image:profileImage selectedImage:profileImage];
    
    //[[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar_selected.png"]];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];

    [self setDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    self.currentViewController = tabBarController.selectedViewController;
    
    if ([self.currentViewController isEqual:viewController]) {
        return NO;
    }
    
    
    return YES;
}


@end
