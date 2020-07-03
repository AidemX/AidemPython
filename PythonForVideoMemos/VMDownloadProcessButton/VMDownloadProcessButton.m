//
//  VMDownloadProcessButton.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 3/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMDownloadProcessButton.h"


static CGFloat const kVMDownloadProcessLineWidth_ = 3.f;


@interface VMDownloadProcessButton ()

@property (nonatomic, strong) CAShapeLayer *progressBackgroundLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation VMDownloadProcessButton

- (instancetype)initWithSize:(CGSize)size padding:(CGFloat)padding tintColor:(UIColor *)tintColor
{
  CGRect frame = (CGRect){CGPointZero, size};
  if (self = [super initWithFrame:frame]) {
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
      shapeLayer.strokeColor = [UIColor secondarySystemBackgroundColor].CGColor;
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
    
    _imageView = [[UIImageView alloc] initWithFrame:frame];
    if (tintColor) {
      _imageView.tintColor = tintColor;
    }
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
  }
  return self;
}

#pragma mark - Setter

- (void)setStatus:(VMDownloadProcessButtonStatus)status
{
  if (_status != status) {
    return;
  }
  _status = status;
  
  if (kVMDownloadProcessButtonStatusOfWaiting == status) {
    _imageView.image = [UIImage systemImageNamed:@"xmark"];
  } else if (kVMDownloadProcessButtonStatusOfPaused == status) {
    _imageView.image = [UIImage systemImageNamed:@"arrow.clockwise"];
  } else if (kVMDownloadProcessButtonStatusOfDownloading == status) {
    _imageView.image = [UIImage systemImageNamed:@"pause.fill"];
  }
}

- (void)setProgress:(float)progress
{
  _progress = progress;
  
  _progressLayer.strokeEnd = progress;
}

@end
