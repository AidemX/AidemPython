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

extern NSString * const kVMPythonDownloadingOperationPropertyOfName;

extern NSString * const kVMPythonDownloadingOperationPropertyOfIsExecuting;
extern NSString * const kVMPythonDownloadingOperationPropertyOfIsFinished;
extern NSString * const kVMPythonDownloadingOperationPropertyOfIsCancelled;

extern NSString * const kVMPythonDownloadingOperationPropertyOfProgress;


@interface VMPythonDownloadingOperation : NSOperation

@property (nonatomic, assign) float progress;
@property (nonatomic, assign, getter=isPaused) BOOL paused;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithURLString:(NSString *)urlString
                         inFormat:(nullable NSString *)format
                            title:(nullable NSString *)title
           pythonVideoMemosModule:(VMPythonVideoMemosModule *)pythonVideoMemosModule;

- (void)resume;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
