//
//  SAEChooseEventView.m
//  turnip
//
//  Created by Per on 6/18/15.
//  Copyright (c) 2015 Stupidest App Ever. All rights reserved.
//

#import "SAEChooseEventView.h"
#import "SAEImageLabelView.h"
#import "SAESwipeEvent.h"
#import <Parse/Parse.h>

static const CGFloat ChoosePersonViewImageLabelWidth = 42.f;

@interface SAEChooseEventView ()
@property (nonatomic, strong) UIView *informationView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) SAEImageLabelView *cameraImageLabelView;
@property (nonatomic, strong) SAEImageLabelView *interestsImageLabelView;
@property (nonatomic, strong) SAEImageLabelView *friendsImageLabelView;
@end

@implementation SAEChooseEventView

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
                       event:(SAESwipeEvent *)event
                      options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame options:options];
    if (self) {
        _event = event;
        
        [_event.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.imageView.image = image;
                
                self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                UIViewAutoresizingFlexibleWidth |
                UIViewAutoresizingFlexibleBottomMargin;
                self.imageView.autoresizingMask = self.autoresizingMask;
                
                [self constructInformationView];

            }
        }];
        
    }
    return self;
}

#pragma mark - Internal Methods

- (void)constructInformationView {
    CGFloat bottomHeight = 60.f;
    CGRect bottomFrame = CGRectMake(0,
                                    CGRectGetHeight(self.bounds) - bottomHeight,
                                    CGRectGetWidth(self.bounds),
                                    bottomHeight);
    _informationView = [[UIView alloc] initWithFrame:bottomFrame];
    _informationView.backgroundColor = [UIColor whiteColor];
    _informationView.clipsToBounds = YES;
    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_informationView];
    
    [self constructNameLabel];
}

- (void)constructNameLabel {
    CGFloat leftPadding = 12.f;
    CGFloat topPadding = 17.f;
    CGRect frame = CGRectMake(leftPadding,
                              topPadding,
                              floorf(CGRectGetWidth(_informationView.frame)/2),
                              CGRectGetHeight(_informationView.frame) - topPadding);
    _nameLabel = [[UILabel alloc] initWithFrame:frame];
    _nameLabel.text = [NSString stringWithFormat:@"%@", _event.title];
    [_informationView addSubview:_nameLabel];
}

//- (void)constructCameraImageLabelView {
//    CGFloat rightPadding = 10.f;
//    UIImage *image = [UIImage imageNamed:@"group"];
//    _cameraImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetWidth(_informationView.bounds) - rightPadding
//                                                      image:image
//                                                       text:[@(_person.numberOfPhotos) stringValue]];
//    [_informationView addSubview:_cameraImageLabelView];
//}


- (SAEImageLabelView *)buildImageLabelViewLeftOf:(CGFloat)x image:(UIImage *)image text:(NSString *)text {
    CGRect frame = CGRectMake(x - ChoosePersonViewImageLabelWidth,
                              0,
                              ChoosePersonViewImageLabelWidth,
                              CGRectGetHeight(_informationView.bounds));
    SAEImageLabelView *view = [[SAEImageLabelView alloc] initWithFrame:frame
                                                           image:image
                                                            text:text];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return view;
}

@end