//
//  TicketViewController.h
//  turnip
//
//  Created by Per on 2/7/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TicketViewController : UIViewController

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *ticketTitle;
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSDate *date;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) IBOutlet UIImageView *qrCodeImage;

- (IBAction)backNavigation:(id)sender;
@end
