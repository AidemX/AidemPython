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

extern NSString * const kVMPythonDownloadingOperationPropertyOfReceivedFileSize;


@interface VMPythonDownloadingOperation : NSOperation

@property (nonatomic, assign) uint64_t receivedFileSize; ///< Received file size in bytes
@property (nonatomic, assign) uint64_t totalFileSize;    ///< Total file size in bytes

@property (nonatomic, assign, getter=isPaused) BOOL paused;

@property (nonatomic, copy, nullable) NSDictionary *userInfo; ///< (Optional) Used to store user operation associated infos.

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithURLString:(NSString *)urlString
                         inFormat:(nullable NSString *)format
                    totalFileSize:(uint64_t)totalFileSize
                    preferredName:(nullable NSString *)preferredName
                         userInfo:(nullable NSDictionary *)userInfo
           pythonVideoMemosModule:(VMPythonVideoMemosModule *)pythonVideoMemosModule
                 progressFilePath:(NSString *)progressFilePath;

- (void)resume;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
