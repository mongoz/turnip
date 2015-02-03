//
//  RequestViewController.h
//  turnip
//
//  Created by Per on 1/31/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RequestViewController : UIViewController

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (strong, nonatomic) IBOutlet UILabel *requestLabel;

@end
