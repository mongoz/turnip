//
//  ScannerShapeView.m
//  turnip
//
//  Created by Per on 2/13/15.
//  Copyright (c) 2015 Per. All rights reserved.
//

#import "ScannerShapeView.h"

@interface ScannerShapeView ()

@property (nonatomic, strong) CAShapeLayer *outline;

@end

@implementation ScannerShapeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _outline = [CAShapeLayer new];
        _outline.strokeColor = [[[UIColor blueColor] colorWithAlphaComponent:0.8] CGColor];
        _outline.lineWidth = 2.0;
        _outline.fillColor = [[UIColor clearColor] CGColor];
        [self.layer addSublayer:_outline];
    }
    return self;
}

- (void)setCorners:(NSArray *)corners
{
    if(corners != _corners) {
        _corners = corners;
        _outline.path = [[self createPathFromPoints:corners] CGPath];
    }
}

- (UIBezierPath *)createPathFromPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath new];
    // Start at the first corner
    [path moveToPoint:[[points firstObject] CGPointValue]];
    
    // Now draw lines around the corners
    for (NSUInteger i = 1; i < [points count]; i++) {
        [path addLineToPoint:[points[i] CGPointValue]];
    }
    
    // And join it back to the first corner
    [path addLineToPoint:[[points firstObject] CGPointValue]];
    
    return path;
}@end
