//
//  VMPythonResourceDownloader.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

@class VMRemoteResourceModel;
@class VMRemoteResourceOptionModel;


NS_ASSUME_NONNULL_BEGIN

typedef void (^VMPythonRemoteResourceDownloaderSourceCheckingCompletion)(VMRemoteResourceModel *_Nullable sourceItem, NSString *_Nullable errorMessage);


@protocol VMPythonRemoteResourceDownloaderDelegate;


@interface VMPythonResourceDownloader : NSObject

@property (nonatomic, copy) NSString *savePath; ///< Path to save the downloaed source.
@property (nonatomic, assign) BOOL cacheJSONFile; ///< Whether cached parsed json file, default: NO.
@property (nonatomic, assign, getter=inDebugMode) BOOL debugMode;

@property (nonatomic, assign, getter=isSuspended) BOOL suspended;

@property (nonatomic, weak, nullable) id <VMPythonRemoteResourceDownloaderDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonRemoteResourceDownloaderSourceCheckingCompletion)completion;

/**
 * Download source w/ URL string in format.
 *
 * @param urlString URL string
 * @param format    source format
 *
 * @return Task identifier of the downloading operation.
 */
- (NSString *)downloadWithURLString:(NSString *)urlString inFormat:(nullable NSString *)format preferredName:(nullable NSString *)preferredName;

/**
 * Download source w/ selected source option item.
 *
 * @param sourceItem    Main resource item associated w/ an URL
 * @param optionItem    Resource item's option item in different format.
 * @param preferredName (Optioanl) preferred name for this option item.
 *
 * @return Task identifier of the downloading operation.
 */
- (NSString *)downloadWithSourceItem:(VMRemoteResourceModel *)sourceItem optionItem:(nullable VMRemoteResourceOptionModel *)optionItem preferredName:(nullable NSString *)preferredName;

/*
 * Task Management
 */
- (void)resumeTaskWithIdentifier:(NSString *)taskIdentifier;
- (void)pauseTaskWithIdentifier:(NSString *)taskIdentifier;

@end


@protocol VMPythonRemoteResourceDownloaderDelegate <NSObject>

@optional

- (void)vm_pythonRemoteResourceDownloaderDidStartTaskWithIdentifier:(NSString *)taskIdentifier;

- (void)vm_pythonRemoteResourceDownloaderDidUpdateTaskWithIdentifier:(NSString *)taskIdentifier progress:(float)progress;

- (void)vm_pythonRemoteResourceDownloaderDidEndTaskWithIdentifier:(NSString *)taskIdentifier
                                                     errorMessage:(nullable NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
