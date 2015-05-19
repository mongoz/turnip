//
//  SAEFindViewController.m
//  Turnip
//
//  Created by Per on 1/4/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "SAEFindViewController.h"
#import "SAEEventDetailsViewController.h"
#import "SAEFindTableCell.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "Constants.h"
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "ParseErrorHandlingController.h"

@interface SAEFindViewController ()

@property (nonatomic, strong) PFObject *neighbourhood;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSMutableArray *days;
@property (nonatomic, strong) NSMutableDictionary *groupedEvents;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation SAEFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = self.neighbourhoodName;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 30.0f, 30.0f)];
    
    UIImage *backImage = [self imageResize:[UIImage imageNamed:@"backNav"] andResizeTo:CGSizeMake(30, 30)];
    [backButton setBackgroundImage:backImage  forState:UIControlStateNormal];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backNavigation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.activityView.color = [UIColor blackColor];
    
    self.tableView.backgroundView = self.activityView;
    [self.activityView startAnimating];
    
    self.days = [[NSMutableArray alloc] init];
    self.groupedEvents = [[NSMutableDictionary alloc] init];
    
    [self queryEvents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) queryEvents {
    
    PFObject *obj = [PFObject objectWithoutDataWithClassName:@"Neighbourhoods" objectId:self.neighbourhoodId];
    
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
//    if([self.events count] == 0) {
//        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//    }
    
    [query selectKeys:@[TurnipParsePostTitleKey, TurnipParsePostLocationKey, TurnipParsePostThumbnailKey, TurnipParsePostPrivateKey, TurnipParsePostPublicKey, @"date"]];
    
    [query whereKey:@"neighbourhood" equalTo:obj];
    [query orderByAscending:@"date"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [ParseErrorHandlingController handleParseError:error];
        } else {
            if ([objects count] > 0) {
                self.events = [[NSArray alloc] initWithArray:objects];
                [self groupEventsIntoDays];
                [self.activityView stopAnimating];
                self.activityView.hidden = YES;
                [self.tableView reloadData];
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id key = [self.days objectAtIndex:section];
    
    NSArray *tableViewCellsForSection = [self.groupedEvents objectForKey:key];
    return tableViewCellsForSection.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier = @"eventCell";
    
    SAEFindTableCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[SAEFindTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh:mm a";
    
    id key = [self.days objectAtIndex:indexPath.section];
    NSArray *sectionItems = [[NSArray alloc] initWithArray:[self.groupedEvents objectForKey:key]];
    
    // Configure the cell
    PFFile *thumbnail = [[sectionItems valueForKey:TurnipParsePostThumbnailKey] objectAtIndex: indexPath.row];
    
    //Use a placeholder image before we have downloaded the real one.
    cell.eventImageView.file = thumbnail;
  
    cell.titleLabel.text = [[sectionItems valueForKey: TurnipParsePostTitleKey] objectAtIndex: indexPath.row];
    cell.dateLabel.text = [dateFormatter stringFromDate:[[sectionItems valueForKey:@"date"] objectAtIndex: indexPath.row]];
    [cell.titleLabel sizeToFit];
    [cell.dateLabel sizeToFit];
    
    if ([[[sectionItems valueForKey: TurnipParsePostPrivateKey] objectAtIndex: indexPath.row] isEqualToString:@"False"]) {
        cell.statusImage.image = [UIImage imageNamed:@"PUBLIC.png"];
    }
    if ([[[sectionItems valueForKey:TurnipParsePostPrivateKey] objectAtIndex: indexPath.row] isEqualToString:@"True"]) {
        cell.statusImage.image = [UIImage imageNamed:@"PRIVATE.png"];
    }
    
    [cell.eventImageView loadInBackground];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 155;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
  //  [self performSegueWithIdentifier:@"eventDetailsSegue" sender:self];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    if([self.events count] > 0) {
        self.tableView.backgroundView = nil;
        return [self.days count];
    } else if(![self.activityView isAnimating]){
        // Display a message when the table is empty
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Arial-Bold" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
    }
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width, 35)];
    header.backgroundColor = [UIColor whiteColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:header.bounds];
    headerLabel.textColor = [UIColor blackColor];
    [header addSubview:headerLabel];
    
    [headerLabel setText: [self.days objectAtIndex:section]];
    
    return header;
}

- (void)groupEventsIntoDays {

    for (NSArray *data in self.events) {
        NSString *date = [self convertDate:[data valueForKey:@"date"]];
        
        if (![self.days containsObject:date])
        {
            [self.days addObject:date];
            [self.groupedEvents setObject:[NSMutableArray arrayWithObject:data] forKey:date];
        }
        else
        {
            [((NSMutableArray*)[self.groupedEvents objectForKey:date]) addObject:data];
        }
    }
}

#pragma mark -
#pragma mark utils


- (NSString *) convertDate: (NSDate *) date {
    
    NSLocale *currentLocale = [NSLocale currentLocale];
    
    // Set the date components you want
    NSString *dateComponents = @"EEEEMMMMd";
    
    // The components will be reordered according to the locale
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:currentLocale];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    return formattedDateString;
}

#pragma mark - Navigation

- (void)backNavigation {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (UIImage *)imageResize :(UIImage*)img andResizeTo:(CGSize)newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"eventDetailsSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SAEEventDetailsViewController *destViewController = segue.destinationViewController;
        
        destViewController.event = [self.events objectAtIndex:indexPath.row];
    }
}
@end