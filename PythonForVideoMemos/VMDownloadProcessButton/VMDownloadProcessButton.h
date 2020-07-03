//
//  VMDownloadProcessButton.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 3/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import UIKit;

#import "VMPythonCommon.h"

NS_ASSUME_NONNULL_BEGIN

@interface VMDownloadProcessButton : UIControl

@property (nonatomic, assign) VMPythonDownloadProcessStatus status;
@property (nonatomic, assign) float progress;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)coder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithSize:(CGSize)size padding:(CGFloat)padding tintColor:(nullable UIColor *)tintColor;

@end

NS_ASSUME_NONNULL_END
