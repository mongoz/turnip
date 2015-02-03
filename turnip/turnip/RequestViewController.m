//
//  RequestViewController.m
//  turnip
//
//  Created by Per on 1/31/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

#import "RequestViewController.h"
#import "DraggableViewBackground.h"
#import "Constants.h"

@interface RequestViewController ()

@property (nonatomic, assign) BOOL loadData;

@end

@implementation RequestViewController

NSArray *fetchedObjects;
NSManagedObject *selectedObject;

- (id) init
{
    self = [super init];
    if (!self) return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRequestPush:)
                                                 name:@"requestPush"
                                               object:nil];
    
    return self;
}

- (void) receiveRequestPush:(NSNotification *) notification
{
    NSLog(@"note: %@", notification);
    if ([[notification name] isEqualToString:@"requestPush"])
        NSLog (@"Successfully received the test notification!");
}

- (void) viewWillAppear:(BOOL)animated {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"UserInfo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if([fetchedObjects count] > 0) {
        DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc] initWithFrame:self.view.frame userData: fetchedObjects];
        [self.view addSubview:draggableBackground];
    } else {
       self.requestLabel.text = @"you got no requests";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    statusBarView.backgroundColor  =  [UIColor blackColor];
    [self.view addSubview:statusBarView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -



@end
