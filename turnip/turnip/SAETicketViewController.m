//
//  TicketViewController.m
//  turnip
//
//  Created by Per on 2/7/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "SAETicketViewController.h"

@interface SAETicketViewController ()

@property (nonatomic, weak) NSTimer* timer;
@property (nonatomic, strong) NSDateComponents *dateComponents;

@end

@implementation SAETicketViewController

@synthesize address;
@synthesize ticketTitle;
@synthesize objectId;
@synthesize date;

- (void) viewWillDisappear:(BOOL)animated {
    [self.timer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"TURNIP!"];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
    CIImage *qrCode = [self createQRCode];
    UIImage *qrCodeImage = [self createNonInterpolatedUIImageFromCIImage:qrCode withScale:2*[[UIScreen mainScreen] scale]];
    
    NSString *startText = @"Scan your QR code to Gain entrance to";
    
    NSString *labelText = [NSString stringWithFormat:@"%@ %@", startText, ticketTitle];
    self.mainText.numberOfLines = 0;
    self.mainText.text = labelText;
    [self.mainText sizeToFit];

    self.qrCodeImage.image = qrCodeImage;
    
    if (self.isPrivate) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCounter) userInfo:nil repeats:YES];
    } else {
        self.subText.numberOfLines = 0;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM d 'at' hh:mm a";
        NSString *subText = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:date], address];
        self.subText.text = subText;
        
        [self.subText sizeToFit];

    }
}

- (void) updateCounter {
    
    self.dateComponents = [[NSDateComponents alloc] init];
    [self.dateComponents setHour:-2];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM d 'at' hh:mm a";
    
    NSDate *showDate = [[NSCalendar currentCalendar] dateByAddingComponents:self.dateComponents toDate:date options:0];
    
    NSInteger ti = [showDate timeIntervalSinceNow];

    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600) % 24;
    NSInteger days = (ti / 86400);
    
    self.subText.numberOfLines = 0;

    if (ti > 0) {
        NSString *timeText = [NSString stringWithFormat: @"Adress Hidden until %2li days %02li hours %02li minutes and %02li seconds", (long)days, (long)hours, (long)minutes, (long)seconds];
        
        self.subText.text = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:date], timeText];
    } else {
        NSString *subText = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:date], address];
        self.subText.text = subText;
        
        [self.timer invalidate];
    }
    [self.subText sizeToFit];
    
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
