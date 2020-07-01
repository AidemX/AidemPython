//
//  VMPythonVideoMemosModule.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 30/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

@class VMRemoteSourceModel;
@class VMRemoteSourceOptionModel;


NS_ASSUME_NONNULL_BEGIN

typedef void (^VMPythonVideoMemosModuleRemoteSourceCheckingCompletion)(VMRemoteSourceModel *_Nullable sourceItem, NSString *_Nullable errorMessage);

typedef void (^VMPythonVideoMemosModuleDownloadingProgress)(float progress);
typedef void (^VMPythonVideoMemosModuleDownloadingCompletion)(NSString *_Nullable errorMessage);


@interface VMPythonVideoMemosModule : NSObject

@property (nonatomic, copy) NSString *savePath; ///< Path to save the downloaed source.
@property (nonatomic, assign) BOOL cacheJSONFile; ///< Whether cached parsed json file, default: NO.
@property (nonatomic, assign, getter=inDebugMode) BOOL debugMode;

- (void)setupWithSavePath:(NSString *)savePath cacheJSONFile:(BOOL)cacheJSONFile inDebugMode:(BOOL)debugMode;

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonVideoMemosModuleRemoteSourceCheckingCompletion)completion;

- (void)downloadWithURLString:(NSString *)urlString
                     inFormat:(nullable NSString *)format
                   completion:(nullable VMPythonVideoMemosModuleDownloadingCompletion)completion;

- (void)downloadWithSourceItem:(VMRemoteSourceModel *)sourceItem
                    optionItem:(nullable VMRemoteSourceOptionModel *)optionItem
                    completion:(nullable VMPythonVideoMemosModuleDownloadingCompletion)completion;

@end

NS_ASSUME_NONNULL_END
