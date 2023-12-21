//
//  VMPythonAidemModule.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 30/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;


NS_ASSUME_NONNULL_BEGIN

extern NSString * const kVMPythonAidemModuleProgressFileName;

typedef void (^VMPythonAidemModuleWebResourceCheckingCompletion)(NSString *_Nullable jsonString, NSString *_Nullable errorMessage);

typedef void (^VMPythonAidemModuleDownloadingProgress)(float progress);
typedef void (^VMPythonAidemModuleDownloadingCompletion)(NSString *_Nullable errorMessage);


@interface VMPythonAidemModule : NSObject

@property (nonatomic, copy) NSString *savePath; ///< Path to save the downloaed source.
@property (nonatomic, assign, getter=inDebugMode) BOOL debugMode;

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonAidemModuleWebResourceCheckingCompletion)completion;

- (void)downloadWithURLString:(NSString *)urlString
                     inFormat:(nullable NSString *)format
                preferredName:(nullable NSString *)preferredName
                   completion:(nullable VMPythonAidemModuleDownloadingCompletion)completion;

@end

NS_ASSUME_NONNULL_END
