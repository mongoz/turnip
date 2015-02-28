//
//  TurnipCustomTabBarViewController.m
//  turnip
//
//  Created by Per on 2/25/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "TurnipCustomTabBarViewController.h"

@interface TurnipCustomTabBarViewController ()

@end

@implementation TurnipCustomTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITabBar *tabBar = self.tabBar;
    
    UIImage *homeImage = [[UIImage imageNamed:@"homeBlk"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *hostImage = [[UIImage imageNamed:@"host"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *tabHome = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabHost = [tabBar.items objectAtIndex:1];
    
    tabHome = [tabHome initWithTitle:@"" image:homeImage selectedImage:homeImage];
    tabHost = [tabHost initWithTitle:@"" image:hostImage selectedImage:hostImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
