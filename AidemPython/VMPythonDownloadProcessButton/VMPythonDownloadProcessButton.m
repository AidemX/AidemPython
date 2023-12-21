//
//  VMPythonDownloadProcessButton.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 3/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonDownloadProcessButton.h"


static CGFloat const kVMDownloadProcessLineWidth_ = 2.f;


@interface VMPythonDownloadProcessButton ()

@property (nonatomic, strong) CAShapeLayer *progressBackgroundLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation VMPythonDownloadProcessButton

- (instancetype)initWithSize:(CGSize)size padding:(CGFloat)padding tintColor:(UIColor *)tintColor
{
  CGRect frame = (CGRect){CGPointZero, size};
  if (self = [super initWithFrame:frame]) {
    _status = VMPythonDownloadProcessStatusUnknown;
    
    CGFloat widthInHalf  = size.width / 2;
    CGFloat heightInHalf = size.height / 2;
    CGPoint center = CGPointMake(widthInHalf, heightInHalf);
    CGFloat radius = MIN(widthInHalf, heightInHalf) - padding;
    
    CGFloat contentsScale = [[UIScreen mainScreen] scale];
    
    _progressBackgroundLayer = ({
      CAShapeLayer *shapeLayer = [CAShapeLayer layer];
      shapeLayer.position = center;
      shapeLayer.bounds = frame;
      shapeLayer.opaque = YES;
      shapeLayer.fillColor = [UIColor clearColor].CGColor;
      shapeLayer.strokeColor = [UIColor tertiarySystemBackgroundColor].CGColor;
      shapeLayer.lineWidth = kVMDownloadProcessLineWidth_;
      shapeLayer.lineCap = kCALineCapRound;
      
      shapeLayer.contentsScale = contentsScale;
      
      shapeLayer;
    });
    [self.layer addSublayer:_progressBackgroundLayer];
    
    _progressLayer = ({
      CAShapeLayer *shapeLayer = [CAShapeLayer layer];
      shapeLayer.position = center;
      shapeLayer.bounds = frame;
      shapeLayer.opaque = YES;
      shapeLayer.fillColor = [UIColor clearColor].CGColor;
      shapeLayer.strokeColor = (tintColor ?: [UIColor systemBlueColor]).CGColor;
      shapeLayer.lineWidth = kVMDownloadProcessLineWidth_;
      shapeLayer.lineCap = kCALineCapRound;
      shapeLayer.contentsScale = contentsScale;
      shapeLayer;
    });
    [self.layer addSublayer:_progressLayer];
    
    /*
     *       PI*3/2 (-PI/2)
     *        |
     *  PI ---|--- 0
     *        |
     *       PI/2
     */
    CGMutablePathRef pathOfCircle = CGPathCreateMutable();
    CGPathMoveToPoint(pathOfCircle, NULL, center.x, heightInHalf - radius);
    CGPathAddArc(pathOfCircle, NULL, center.x, center.y, radius, -M_PI_2, M_PI + M_PI_2, NO);
    _progressBackgroundLayer.path = pathOfCircle;
    _progressLayer.path = pathOfCircle;
    CGPathRelease(pathOfCircle);
    
    _progressLayer.strokeEnd = 0.f;
    
    CGFloat iconSizeLength = ceil(radius * .8f);
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((size.width  - iconSizeLength) / 2,
                                                               (size.height - iconSizeLength) / 2,
                                                               iconSizeLength, iconSizeLength)];
    if (tintColor) {
      _imageView.tintColor = tintColor;
    }
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
  }
  return self;
}

#pragma mark - Setter

- (void)setStatus:(VMPythonDownloadProcessStatus)status
{
  if (_status == status) {
    return;
  }
  _status = status;
  
  if (VMPythonDownloadProcessStatusNone == status || VMPythonDownloadProcessStatusDownloadSucceeded == status) {
    self.hidden = YES;
  } else {
    self.hidden = NO;
    if (VMPythonDownloadProcessStatusWaiting == status) {
      _imageView.image = [UIImage systemImageNamed:@"xmark"];
    } else if (VMPythonDownloadProcessStatusPaused == status) {
      _imageView.image = [UIImage systemImageNamed:@"arrow.clockwise"];
    } else if (VMPythonDownloadProcessStatusDownloading == status) {
      _imageView.image = [UIImage systemImageNamed:@"pause.fill"];
    } else if (VMPythonDownloadProcessStatusDownloadFailed == status) {
      _imageView.image = [UIImage systemImageNamed:@"exclamationmark"];
    }
  }
}

- (void)setProgress:(float)progress
{
  _progress = progress;
  
  _progressLayer.strokeEnd = progress;
}

@end
