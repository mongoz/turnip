//
//  RequestViewController.m
//  turnip
//
//  Created by Per on 1/31/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "RequestViewController.h"
#import "DraggableViewBackground.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface RequestViewController ()

@property (nonatomic, assign) BOOL loadData;

@end

@implementation RequestViewController

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.loadData) {
    
        NSArray *test = [[NSArray alloc]initWithObjects:@"Taylor",@"second",@"third",@"fourth",@"last", nil];
        
        DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame userData: test];
        [self.view addSubview:draggableBackground];
        
    } else {
        NSLog(@"No requests");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) downloadUserData {
    PFQuery *query = [PFQuery queryWithClassName:TurnipParsePostClassName];
    
    [query whereKey:@"user" equalTo:[PFUser currentUser]];

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
