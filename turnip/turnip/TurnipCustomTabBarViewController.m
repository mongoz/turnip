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
