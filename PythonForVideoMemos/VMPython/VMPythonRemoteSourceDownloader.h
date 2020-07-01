//
//  VMPythonRemoteSourceDownloader.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonVideoMemosModuleConstants.h"

@class VMRemoteSourceOptionModel;


NS_ASSUME_NONNULL_BEGIN


@protocol VMPythonRemoteSourceDownloaderDelegate;


@interface VMPythonRemoteSourceDownloader : NSObject

@property (nonatomic, weak, nullable) id <VMPythonRemoteSourceDownloaderDelegate> delegate;

+ (instancetype)sharedInstance;

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

//- (void)debug_downloadWithURLString:(NSString *)urlString
//                           progress:(VMPythonRemoteSourceDownloaderProgress)progress
//                         completion:(VMPythonRemoteSourceDownloaderCompletion)completion;

@end


@protocol VMPythonRemoteSourceDownloaderDelegate <NSObject>

@optional

- (void)vm_pythonRemoteSourceDownloaderDidStartTaskWithIdentifier:(NSString *)taskIdentifier;

- (void)vm_pythonRemoteSourceDownloaderDidUpdateTaskWithIdentifier:(NSString *)taskIdentifier progress:(float)progress;

- (void)vm_pythonRemoteSourceDownloaderDidEndTaskWithIdentifier:(NSString *)taskIdentifier
                                                   errorMessage:(nullable NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
