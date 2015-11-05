//
//  SAEAttendingTableViewController.m
//  turnip
//
//  Created by Per on 10/30/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEAttendingTableViewController.h"
#import "ProfileViewController.h"
#import "SAEUtilityFunctions.h"

@interface SAEAttendingTableViewController ()

@end

@implementation SAEAttendingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Attending";
    
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 30.0f, 30.0f)];
    UIImage *backImage = [SAEUtilityFunctions imageResize:[UIImage imageNamed:@"backNav"] andResizeTo:CGSizeMake(30, 30)];
    [backButton setBackgroundImage:backImage  forState:UIControlStateNormal];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backNavigation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.attendees count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attendingCell" forIndexPath:indexPath];
    
    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width / 2;
    cell.imageView.clipsToBounds = YES;
    CGSize itemSize = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (![[[self.attendees valueForKey:@"profileImage"] objectAtIndex:indexPath.row] isEqual:[NSNull null]] ) {
        NSURL *url = [NSURL URLWithString: [[self.attendees valueForKey:@"profileImage"] objectAtIndex:indexPath.row]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.imageView.image = [UIImage imageWithData:data];
    } else {
        //Download facebook image
        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", [[self.attendees valueForKey:@"facebookId"] objectAtIndex:indexPath.row]]];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
        
        // Run network request asynchronously
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:
         ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
             if (connectionError == nil && data != nil) {
                 // Set the image in the header imageView
                 cell.imageView.image = [UIImage imageWithData:data];
             } else {
                 NSLog(@"connectionError: %@", connectionError);
             }
         }];
    }
    
    cell.textLabel.text = [[self.attendees valueForKey:@"firstName"] objectAtIndex:indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"profileSegue" sender:nil];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if([segue.identifier isEqualToString:@"profileSegue"]) {
        ProfileViewController *destViewController = segue.destinationViewController;
        
        destViewController.user = [self.attendees objectAtIndex:indexPath.row];
    }
}

- (void)backNavigation {
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
