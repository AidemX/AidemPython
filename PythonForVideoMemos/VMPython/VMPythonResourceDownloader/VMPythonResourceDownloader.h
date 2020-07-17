//
//  VMPythonResourceDownloader.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

// Protocol to Implement by Others
#import "VMPythonResourceDownloaderDelegate.h"
// Constants
#import "VMDownloadOperationConstants.h"

@class VMWebResourceModel;
@class VMWebResourceOptionModel;


NS_ASSUME_NONNULL_BEGIN

typedef void (^VMPythonResourceDownloaderFetchInfoCompletion)(NSDictionary *_Nullable json, NSString *_Nullable errorMessage);
typedef void (^VMPythonResourceDownloaderFetchTitleCompletion)(NSString *_Nullable title, NSString *_Nullable errorMessage);
typedef void (^VMPythonResourceDownloaderResourceCheckingCompletion)(VMWebResourceModel *_Nullable resourceItem, NSString *_Nullable errorMessage);


@protocol VMPythonResourceDownloaderDelegate;


@interface VMPythonResourceDownloader : NSObject

@property (nonatomic, copy) NSString *savePath; ///< Path to save the downloaed source.
@property (nonatomic, assign) BOOL cacheJSONFile; ///< Whether cached parsed json file, default: NO.
@property (nonatomic, assign, getter=inDebugMode) BOOL debugMode;

@property (nonatomic, assign, getter=isSuspended) BOOL suspended;

@property (nonatomic, weak, nullable) id <VMPythonResourceDownloaderDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)fetchInfoWithURLString:(NSString *)urlString completion:(VMPythonResourceDownloaderFetchInfoCompletion)completion;
- (void)fetchTitleWithURLString:(NSString *)urlString completion:(VMPythonResourceDownloaderFetchTitleCompletion)completion;
- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonResourceDownloaderResourceCheckingCompletion)completion;

/**
 * Download resource w/ URL string in format.
 *
 * @param urlString     URL string
 * @param format        Resource format
 * @param totalFileSize Total file size
 * @param preferredName (Optional) Preferred name (w/o ext) as the saved filename
 * @param userInfo      (Optional) Cutom user info to store if needed
 *
 * @return Task identifier of the downloading operation (NOTE: it's operation name, not unique for sure).
 */
- (NSString *)downloadWithURLString:(NSString *)urlString
                           inFormat:(nullable NSString *)format
                      totalFileSize:(uint64_t)totalFileSize
                      preferredName:(nullable NSString *)preferredName
                           userInfo:(nullable NSDictionary *)userInfo;

/**
 * Download resource w/ selected source option item.
 *
 * @param resourceItem  Main resource item associated w/ an URL
 * @param optionItem    Resource item's option item in different format.
 * @param preferredName (Optioanl) Preferred name (w/o ext) as the saved filename for this option item.
 * @param userInfo      (Optional) Cutom user info to store if needed
 *
 * @return Task identifier of the downloading operation (NOTE: it's operation name, not unique for sure).
 */
- (NSString *)downloadWithResourceItem:(VMWebResourceModel *)resourceItem
                            optionItem:(nullable VMWebResourceOptionModel *)optionItem
                         preferredName:(nullable NSString *)preferredName
                              userInfo:(nullable NSDictionary *)userInfo;

/*
 * Task Management
 */
//! Get status of a task w/ identifier provided.
- (VMDownloadOperationStatus)statusOfTaskWithIdentifier:(NSString *)taskIdentifier;
//! Resume a task w/ identifier provided.
- (void)resumeTaskWithIdentifier:(NSString *)taskIdentifier;
//! Pause a task w/ identifier provided.
- (void)pauseTaskWithIdentifier:(NSString *)taskIdentifier;
//! Stop a task w/ identifier provided (will also clean cached files).
- (void)stopTaskWithIdentifier:(NSString *)taskIdentifier;

/*
 * Clean
 */
- (void)cleanCachedJSONFileWithURLString:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
