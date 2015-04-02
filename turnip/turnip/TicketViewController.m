//
//  TicketViewController.m
//  turnip
//
//  Created by Per on 2/7/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "TicketViewController.h"

@interface TicketViewController ()

@end

@implementation TicketViewController

@synthesize address;
@synthesize ticketTitle;
@synthesize objectId;
@synthesize date;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd hh:mm a";
    
    CIImage *qrCode = [self createQRCode];
    UIImage *qrCodeImage = [self createNonInterpolatedUIImageFromCIImage:qrCode withScale:2*[[UIScreen mainScreen] scale]];
    
    self.titleLabel.text = ticketTitle;
    self.dateLabel.text = [dateFormatter stringFromDate: date];
    self.addressLabel.text = address;
    self.qrCodeImage.image = qrCodeImage;
    
    NSDate *currentDate = [NSDate date];
    
    NSLog(@"currDate: %@", currentDate);
    NSLog(@"date: %@", date);
    NSTimeInterval timeDifferenceBetweenDates = [date timeIntervalSinceNow];
    
    NSLog(@"timeDiff: %f", timeDifferenceBetweenDates / (60 * 60));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CIImage *) createQRCode {
    NSData *stringData = [objectId dataUsingEncoding: NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue: stringData forKey:@"inputMessage"];
    [qrFilter setValue: @"H" forKey:@"inputCorrectionLevel"];
    
    return qrFilter.outputImage;
}

- (UIImage *) createNonInterpolatedUIImageFromCIImage: (CIImage *) image withScale:(CGFloat) scale {
    
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage: image fromRect: image.extent];
    UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return scaledImage;
}


@end
