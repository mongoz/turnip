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
    
    UITabBar *tabBar = self.tabBar;
    
    UIImage *homeImage = [[UIImage imageNamed:@"homeBlk"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *hostImage = [[UIImage imageNamed:@"host"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *profileImage = [[UIImage imageNamed:@"profileBlk"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *notificationImage = [[UIImage imageNamed:@"notificationBlk"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *tabHome = [tabBar.items objectAtIndex: TurnipTabHome];
    UITabBarItem *tabHost = [tabBar.items objectAtIndex: TurnipTabHost];
    UITabBarItem *tabNotification = [tabBar.items objectAtIndex: TurnipTabNotification];
    UITabBarItem *tabProfile = [tabBar.items objectAtIndex: TurnipTabProfile];
    
    tabHome = [tabHome initWithTitle:@"" image:homeImage selectedImage:homeImage];
    tabHost = [tabHost initWithTitle:@"" image:hostImage selectedImage:hostImage];
    tabNotification = [tabNotification initWithTitle:@"" image:notificationImage selectedImage:notificationImage];
    tabProfile = [tabProfile initWithTitle:@"" image:profileImage selectedImage:profileImage];

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
