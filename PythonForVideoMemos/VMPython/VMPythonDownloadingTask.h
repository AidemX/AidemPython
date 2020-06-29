//
//  VMPythonDownloadingTask.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 29/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface VMPythonDownloadingTask : NSObject

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) float progress;

@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, copy) NSString *errorMessage;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithURLString:(NSString *)urlString;

- (void)updateWithProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
