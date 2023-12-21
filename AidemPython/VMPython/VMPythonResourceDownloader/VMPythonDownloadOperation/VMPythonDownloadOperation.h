//
//  VMPythonDownloadOperation.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 29/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

@class VMPythonAidemModule;


NS_ASSUME_NONNULL_BEGIN

extern NSString * const kVMPythonDownloadOperationPropertyOfName;

extern NSString * const kVMPythonDownloadOperationPropertyOfIsExecuting;
extern NSString * const kVMPythonDownloadOperationPropertyOfIsFinished;
extern NSString * const kVMPythonDownloadOperationPropertyOfIsCancelled;

extern NSString * const kVMPythonDownloadOperationPropertyOfReceivedFileSize;


@interface VMPythonDownloadOperation : NSOperation

@property (nonatomic, assign) uint64_t receivedFileSize; ///< Received file size in bytes
@property (nonatomic, assign) uint64_t totalFileSize;    ///< Total file size in bytes

@property (nonatomic, copy, nullable) NSDictionary *userInfo; ///< (Optional) Used to store user operation associated infos.

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithURLString:(NSString *)urlString
                         inFormat:(nullable NSString *)format
                    totalFileSize:(uint64_t)totalFileSize
                    preferredName:(nullable NSString *)preferredName
                         userInfo:(nullable NSDictionary *)userInfo
           pythonVideoMemosModule:(VMPythonAidemModule *)pythonVideoMemosModule
                 progressFilePath:(NSString *)progressFilePath;

@end

NS_ASSUME_NONNULL_END
