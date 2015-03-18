//
//  ScannerViewController.m
//  turnip
//
//  Created by Per on 2/13/15.
//  Copyright (c) 2015 Per. All rights reserved.
//
#import "DetailViewController.h"
#import "ScannerViewController.h"
#import "ScannerShapeView.h"
@import AVFoundation;

@interface ScannerViewController ()

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) ScannerShapeView *boundingBox;
@property (nonatomic, strong) NSTimer *boxHideTimer;
@property (nonatomic, strong) UILabel *message;

@end

@implementation ScannerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(input) {
        [session addInput:input];
    } else {
        NSLog(@"Errror: %@", error);
        return;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [session addOutput:output];
    
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Camera view on screen.
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.bounds = self.view.bounds;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.layer addSublayer:self.previewLayer];
    
    // Draw bounding box for UIView
    // Add the view to draw the bounding box for the UIView
    self.boundingBox = [[ScannerShapeView alloc] initWithFrame:self.view.bounds];
    self.boundingBox.backgroundColor = [UIColor clearColor];
    self.boundingBox.hidden = YES;
    [self.view addSubview:self.boundingBox];
    
    // Message box on Screen.
    self.message = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 75, CGRectGetWidth(self.view.bounds), 75)];
    self.message.numberOfLines = 0;
    self.message.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.9];\
    self.message.textColor = [UIColor blackColor];
    self.message.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.message];
    
    [session startRunning];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) validateQRCode: (NSString *) codeToken {
    
    if ([codeToken isEqualToString:@"event"]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // Transform the meta-data coordinates to screen coords
            AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:metadata];
            // Update the frame on the _boundingBox view, and show it
            self.boundingBox.frame = transformed.bounds;
            self.boundingBox.hidden = NO;
            // Now convert the corners array into CGPoints in the coordinate system
            //  of the bounding box itself
            NSArray *translatedCorners = [self translatePoints:transformed.corners
                                                      fromView:self.view
                                                        toView:_boundingBox];
            
            // Set the corners array
            _boundingBox.corners = translatedCorners;
            
            // Update the view with the decoded text
            self.message.font = [_message.font fontWithSize:30];
            if ([[transformed stringValue] isEqualToString: self.eventId]) {
                self.message.text = @"Accepted";
                self.message.textColor = [UIColor greenColor];
            } else {
                self.message.text = @"Denied";
                self.message.textColor = [UIColor redColor];
            }
            
            // Start the timer which will hide the overlay
            [self startOverlayHideTimer];
        }
    }
}

#pragma mark - Utility Methods
- (void)startOverlayHideTimer
{
    // Cancel it if we're already running
    if(self.boxHideTimer) {
        [self.boxHideTimer invalidate];
    }
    
    // Restart it to hide the overlay when it fires
    self.boxHideTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                     target:self
                                                   selector:@selector(removeBoundingBox:)
                                                   userInfo:nil
                                                    repeats:NO];
}

- (void)removeBoundingBox:(id)sender
{
    // Hide the box and remove the decoded text
    self.boundingBox.hidden = YES;
    self.message.text = @"";
}

- (NSArray *)translatePoints:(NSArray *)points fromView:(UIView *)fromView toView:(UIView *)toView
{
    NSMutableArray *translatedPoints = [NSMutableArray new];
    
    // The points are provided in a dictionary with keys X and Y
    for (NSDictionary *point in points) {
        // Let's turn them into CGPoints
        CGPoint pointValue = CGPointMake([point[@"X"] floatValue], [point[@"Y"] floatValue]);
        // Now translate from one view to the other
        CGPoint translatedPoint = [fromView convertPoint:pointValue toView:toView];
        // Box them up and add to the array
        [translatedPoints addObject:[NSValue valueWithCGPoint:translatedPoint]];
    }
    
    return [translatedPoints copy];
}
- (IBAction)backNavigationButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
