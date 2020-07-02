//
//  VMPythonVideoMemosModule.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 30/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;


NS_ASSUME_NONNULL_BEGIN

extern NSString * const kVMPythonVideoMemosModuleProgressFileName;

typedef void (^VMPythonVideoMemosModuleRemoteSourceCheckingCompletion)(NSString *_Nullable jsonString, NSString *_Nullable errorMessage);

typedef void (^VMPythonVideoMemosModuleDownloadingProgress)(float progress);
typedef void (^VMPythonVideoMemosModuleDownloadingCompletion)(NSString *_Nullable errorMessage);


@interface VMPythonVideoMemosModule : NSObject

@property (nonatomic, copy) NSString *savePath; ///< Path to save the downloaed source.
@property (nonatomic, assign, getter=inDebugMode) BOOL debugMode;

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonVideoMemosModuleRemoteSourceCheckingCompletion)completion;

- (void)downloadWithURLString:(NSString *)urlString
                     inFormat:(nullable NSString *)format
                   completion:(nullable VMPythonVideoMemosModuleDownloadingCompletion)completion;

//- (void)stopDownloadingWithTaskProgressFilePath:(NSString *)taskProgressFilePath;

@end

NS_ASSUME_NONNULL_END
