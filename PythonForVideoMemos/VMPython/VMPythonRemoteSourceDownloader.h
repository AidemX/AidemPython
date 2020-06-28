//
//  VMPythonRemoteSourceDownloader.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

// Model
#import "VMRemoteSourceModel.h"


NS_ASSUME_NONNULL_BEGIN

typedef void (^VMPythonRemoteSourceDownloaderCheckingCompletion)(VMRemoteSourceModel *_Nullable sourceItem, NSString *_Nullable errorMessage);

typedef void (^VMPythonRemoteSourceDownloaderProgress)(float progress);
typedef void (^VMPythonRemoteSourceDownloaderCompletion)(NSString *_Nullable errorMessage);


@interface VMPythonRemoteSourceDownloader : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithSavePath:(NSString *)savePath inDebugMode:(BOOL)debugMode;

- (BOOL)inDebugMode;

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonRemoteSourceDownloaderCheckingCompletion)completion;

- (void)downloadWithURLString:(NSString *)urlString inFormat:(nullable NSString *)format;

- (void)debug_downloadWithURLString:(NSString *)urlString
                           progress:(VMPythonRemoteSourceDownloaderProgress)progress
                         completion:(VMPythonRemoteSourceDownloaderCompletion)completion;

@end

NS_ASSUME_NONNULL_END
