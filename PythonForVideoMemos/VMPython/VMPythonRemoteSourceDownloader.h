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

@property (nonatomic, copy) NSString *savePath; ///< Path to save the downloaed source.
@property (nonatomic, assign) BOOL cacheJSONFile; ///< Whether cached parsed json file, default: NO.
@property (nonatomic, assign, getter=inDebugMode) BOOL debugMode;

@property (nonatomic, assign, getter=isSuspended) BOOL suspended;

@property (nonatomic, weak, nullable) id <VMPythonRemoteSourceDownloaderDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonRemoteSourceDownloaderSourceCheckingCompletion)completion;

/**
 * Download source w/ URL string in format.
 *
 * @param urlString URL string
 * @param format    source format
 *
 * @return Task identifier of the downloading operation.
 */
- (NSString *)downloadWithURLString:(NSString *)urlString inFormat:(nullable NSString *)format;
- (NSString *)downloadWithSourceItem:(VMRemoteSourceModel *)sourceItem optionItem:(nullable VMRemoteSourceOptionModel *)optionItem;

/*
 * Task Management
 */
- (void)resumeTaskWithIdentifier:(NSString *)taskIdentifier;
- (void)pauseTaskWithIdentifier:(NSString *)taskIdentifier;

@end


@protocol VMPythonRemoteSourceDownloaderDelegate <NSObject>

@optional

- (void)vm_pythonRemoteSourceDownloaderDidStartTaskWithIdentifier:(NSString *)taskIdentifier;

- (void)vm_pythonRemoteSourceDownloaderDidUpdateTaskWithIdentifier:(NSString *)taskIdentifier progress:(float)progress;

- (void)vm_pythonRemoteSourceDownloaderDidEndTaskWithIdentifier:(NSString *)taskIdentifier
                                                   errorMessage:(nullable NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
