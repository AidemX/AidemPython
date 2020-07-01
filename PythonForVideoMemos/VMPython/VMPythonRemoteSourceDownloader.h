//
//  VMPythonRemoteSourceDownloader.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

@class VMRemoteSourceModel;
@class VMRemoteSourceOptionModel;


NS_ASSUME_NONNULL_BEGIN

typedef void (^VMPythonRemoteSourceDownloaderSourceCheckingCompletion)(VMRemoteSourceModel *_Nullable sourceItem, NSString *_Nullable errorMessage);


@protocol VMPythonRemoteSourceDownloaderDelegate;


@interface VMPythonRemoteSourceDownloader : NSObject

@property (nonatomic, weak, nullable) id <VMPythonRemoteSourceDownloaderDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)setupWithSavePath:(NSString *)savePath cacheJSONFile:(BOOL)cacheJSONFile inDebugMode:(BOOL)debugMode;

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonRemoteSourceDownloaderSourceCheckingCompletion)completion;

- (void)downloadWithURLString:(NSString *)urlString inFormat:(nullable NSString *)format title:(nullable NSString *)title;
- (void)downloadWithSourceItem:(VMRemoteSourceModel *)sourceItem optionItem:(nullable VMRemoteSourceOptionModel *)optionItem;

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
