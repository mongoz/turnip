//
//  ToSViewController.m
//  turnip
//
//  Created by Per on 3/16/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ToSViewController.h"
#import "ProfileViewController.h"
#import "Constants.h"

@interface ToSViewController ()

@end

@implementation ToSViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tosTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (IBAction)backNavigationButton:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ProfileViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"profileView"];
    [self.navigationController pushViewController:lvc animated:YES];
}
@end
