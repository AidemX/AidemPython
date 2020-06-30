//
//  VMPythonVideoMemosModule.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 30/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonVideoMemosModuleConstants.h"

@class VMRemoteSourceOptionModel;


NS_ASSUME_NONNULL_BEGIN

@interface VMPythonVideoMemosModule : NSObject

- (void)setupWithSavePath:(NSString *)savePath cacheJSONFile:(BOOL)cacheJSONFile inDebugMode:(BOOL)debugMode;

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonVideoMemosModuleRemoteSourceCheckingCompletion)completion;

- (void)downloadWithURLString:(NSString *)urlString
                     inFormat:(nullable NSString *)format
                        title:(nullable NSString *)title
                     progress:(nullable VMPythonVideoMemosModuleDownloadingProgress)progress
                   completion:(nullable VMPythonVideoMemosModuleDownloadingCompletion)completion;

- (void)downloadWithSourceItem:(VMRemoteSourceModel *)sourceItem
                    optionItem:(nullable VMRemoteSourceOptionModel *)optionItem
                      progress:(nullable VMPythonVideoMemosModuleDownloadingProgress)progress
                    completion:(nullable VMPythonVideoMemosModuleDownloadingCompletion)completion;

@end

NS_ASSUME_NONNULL_END
