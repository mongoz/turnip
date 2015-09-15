//
//  SAEHostAccessoriesViewController.m
//  turnip
//
//  Created by Per on 9/13/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEHostAccessoriesViewController.h"
#import "SAEUtilityFunctions.h"

#define titleSize 58
#define descriptionSize 18

@interface SAEHostAccessoriesViewController ()

@property (nonatomic, strong) SAEHostSingleton *event;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *descriptionFont;
@property (nonatomic, strong) NSString *choosenFont;
@property (nonatomic, strong) UIColor *textColor;

@end

@implementation SAEHostAccessoriesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.event = [SAEHostSingleton sharedInstance];
    
    self.textColor = [UIColor blackColor];
    self.titleFont = [UIFont systemFontOfSize: titleSize];
    self.descriptionFont = [UIFont systemFontOfSize: descriptionSize];
    
    
    self.event.startDate = [NSDate date];
    
   [self buildEventDescription];
    
    [self.hostImageView setImage:self.event.eventImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) buildEventDescription {
    
    
    NSString *title = [NSString stringWithFormat:@"%@\n", self.event.title];
    NSString *details = [NSString stringWithFormat:@"%@ \n %@ \n Price: %@ \n", [self convertDate:self.event.startDate], self.event.text, self.event.price];
    
    if (!self.event.isPrivate) {
        details = [details stringByAppendingString: self.event.address];
    }
    
    self.titleLabel.textColor = self.textColor;
    self.titleLabel.font = self.titleFont;
    self.descriptionLabel.textColor = self.textColor;
    self.descriptionLabel.font = self.descriptionFont;
    
    self.titleLabel.text = title;
    self.descriptionLabel.text = details;
    
}

- (NSString *) convertDate:(NSDate *) date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE MMMM dd, hh:mm a"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backNavigationButtonHandler:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)finishButtonHandler:(id)sender {
}

- (IBAction)fontButton:(id)sender {
}

- (IBAction)frameButton:(id)sender {
}

- (IBAction)textColorButton:(id)sender {
}
@end
