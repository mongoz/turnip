//
//  RequestTableViewController.m
//  turnip
//
//  Created by Per on 2/3/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "RequestViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "MCSwipeTableViewCell.h"
#import "Constants.h"

@interface RequestViewController ()

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, assign) NSUInteger nbItems;
@property (nonatomic, strong) MCSwipeTableViewCell *cellToDelete;

@end

@implementation RequestViewController

NSArray *fetchedObjects;

- (void) receiveRequestPush:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"requestPush"])
        NSLog (@"Successfully received the test notification!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRequestPush:)
                                                 name:@"requestPush"
                                               object:nil];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"RequesterInfo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    fetchedObjects = [context executeFetchRequest:fetchRequest error: &error];

    if([fetchedObjects count] > 0) {
        _nbItems = [fetchedObjects count];
    } else {
        NSLog(@"derp");
    }
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:227.0 /225.0 green:227.0/255.0 blue:227.0 / 255.0 alpha:1.0]];
    [self.tableView setBackgroundView: backgroundView];
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
      return _nbItems;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"requestCell";
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // Remove inset of iOS 7 separators.
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        // Setting the background color of the cell.
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(MCSwipeTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIView *checkView = [self viewWithImageName:@"check"];
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
    
    // Setting the default inactive state color to the tableView background color
    [cell setDefaultColor:self.tableView.backgroundView.backgroundColor];
    
    [cell setDelegate:self];
    
    NSArray *name = [[[fetchedObjects valueForKey:@"name"] objectAtIndex: indexPath.row] componentsSeparatedByString: @" "];
    NSString *age = @([self calculateAge:[[fetchedObjects valueForKey:@"birthday"] objectAtIndex:indexPath.row]]).stringValue;
    
    NSString *label = [NSString stringWithFormat:@"%@  %@", [name objectAtIndex:0], age];
    
    cell.imageView.image = [[fetchedObjects valueForKey:@"profileImage"] objectAtIndex:indexPath.row];
    cell.textLabel.text = label;
    
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self deleteCell:cell];
        [self acceptUserRequest: [fetchedObjects objectAtIndex: indexPath.row]];
        [self deleteObjectFromCoreData: [fetchedObjects objectAtIndex: indexPath.row]];
    }];
}

- (void) deleteCell: (MCSwipeTableViewCell *) cell {
    NSParameterAssert(cell);
    
    _nbItems--;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void) acceptUserRequest: (NSArray *) user {
    //send push to current user
    
    NSString *userId = [user valueForKey:@"objectId"];
    NSString *userEvent = [user valueForKey:@"eventId"];
    NSString *message = @"sure thing brah";
    
    [PFCloud callFunctionInBackground:@"acceptEventPush"
                       withParameters:@{@"recipientId": userId, @"message": message, @"eventId": userEvent}
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        NSLog(@"push sent");
                                    }
                                }];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // call super because we're a custom subclass.
}

- (int) calculateAge: (NSString *) birthday {
    
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    int time = [todayDate timeIntervalSinceDate:[dateFormatter dateFromString: birthday]];
    int allDays = (((time / 60) / 60) / 24);
    int days = allDays % 365;
    int years = (allDays - days) / 365;
    
    return  years;
}

- (void) swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    NSLog(@"did start swiping");
}

- (void) swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    NSLog(@"did end swiping");
}

- (UIView *) viewWithImageName: (NSString *) imageName {
    UIImage *image = [UIImage imageNamed: imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (void) deleteObjectFromCoreData: (NSMutableArray * ) user {

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"RequesterInfo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"objectId = %@", [user valueForKey:@"objectId"]];
    [fetchRequest setPredicate: searchFilter];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:fetchRequest error: &error];
    
    for (NSManagedObject *managedObject in array) {
        [context deleteObject:managedObject];
    }
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Data updated");
}

@end
