//
//  SAEDetailsViewController.m
//  turnip
//
//  Created by Per on 9/17/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEDetailsViewController.h"

@interface SAEDetailsViewController ()

@end

@implementation SAEDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)attendButton:(id)sender {
}


- (IBAction)messageButton:(id)sender {
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)backNavigationButton:(id)sender {
}
@end
