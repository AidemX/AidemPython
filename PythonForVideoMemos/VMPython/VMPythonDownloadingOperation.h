//
//  VMPythonDownloadingOperation.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 29/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

@class VMPythonVideoMemosModule;


NS_ASSUME_NONNULL_BEGIN

@interface VMPythonDownloadingOperation : NSOperation

//@property (nonatomic, copy) NSString *urlString;
//@property (nonatomic, assign) float progress;

//@property (nonatomic, assign, getter=isPaused) BOOL paused;
//@property (nonatomic, copy) NSString *errorMessage;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithURLString:(NSString *)urlString
                         inFormat:(nullable NSString *)format
                            title:(nullable NSString *)title
           pythonVideoMemosModule:(VMPythonVideoMemosModule *)pythonVideoMemosModule;

//- (void)resume;
//- (void)pause;
//- (void)finish;

@end

NS_ASSUME_NONNULL_END