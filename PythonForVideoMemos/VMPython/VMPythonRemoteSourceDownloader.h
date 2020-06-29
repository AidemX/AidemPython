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

typedef void (^VMPythonRemoteSourceDownloaderCheckingCompletion)(VMRemoteSourceModel *_Nullable sourceItem, NSString *_Nullable errorMessage);

typedef void (^VMPythonRemoteSourceDownloaderProgress)(float progress);
typedef void (^VMPythonRemoteSourceDownloaderCompletion)(NSString *_Nullable errorMessage);


@interface VMPythonRemoteSourceDownloader : NSObject

@property (nonatomic, copy) NSString *savePath; ///< Path to save the downloaed source.
@property (nonatomic, assign) BOOL cacheJSONFile; ///< Whether cached parsed json file, default: NO.
@property (nonatomic, assign, getter=inDebugMode) BOOL debugMode;

+ (instancetype)sharedInstance;

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonRemoteSourceDownloaderCheckingCompletion)completion;
- (void)downloadWithURLString:(NSString *)urlString inFormat:(nullable NSString *)format;
- (void)downloadWithSourceOptionItem:(VMRemoteSourceOptionModel *)item;

- (void)debug_downloadWithURLString:(NSString *)urlString
                           progress:(VMPythonRemoteSourceDownloaderProgress)progress
                         completion:(VMPythonRemoteSourceDownloaderCompletion)completion;

@end

NS_ASSUME_NONNULL_END
