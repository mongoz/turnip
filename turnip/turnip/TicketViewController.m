//
//  TicketViewController.m
//  turnip
//
//  Created by Per on 2/7/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "TicketViewController.h"

@interface TicketViewController ()

@property (nonatomic, weak) NSTimer* timer;
@property (nonatomic, strong) NSDateComponents *dateComponents;

@end

@implementation TicketViewController

@synthesize address;
@synthesize ticketTitle;
@synthesize objectId;
@synthesize date;

- (void) viewWillDisappear:(BOOL)animated {
    [self.timer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.dateComponents = [[NSDateComponents alloc] init];
    [self.dateComponents setHour:-2];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM d hh:mm a";
    
    CIImage *qrCode = [self createQRCode];
    UIImage *qrCodeImage = [self createNonInterpolatedUIImageFromCIImage:qrCode withScale:2*[[UIScreen mainScreen] scale]];
    
    self.titleLabel.text = ticketTitle;
    self.dateLabel.text = [dateFormatter stringFromDate: date];
    //self.addressLabel.text = address;
    self.qrCodeImage.image = qrCodeImage;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCounter) userInfo:nil repeats:YES];

}

- (void) updateCounter {
    
    NSDate *showDate = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponents toDate:date options:0];
    
    NSInteger ti = [showDate timeIntervalSinceNow];

    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600) % 24;
    NSInteger days = (ti / 86400);
    
    if (ti > 0) {
        self.addressLabel.text = [NSString stringWithFormat: @"%02lid %02lih %02lim %02lis untill address is shown", (long)days, (long)hours, (long)minutes, (long)seconds];
    } else {
        self.addressLabel.text = address;
        
        [self.timer invalidate];
    }
    
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

- (IBAction)backNavigation:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
