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

@property (nonatomic, assign) BOOL cacheJSONFile; ///< Whether cached parsed json file, default: NO.

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithSavePath:(NSString *)savePath inDebugMode:(BOOL)debugMode;

- (BOOL)inDebugMode;

#pragma mark - Python Related

- (void)py_checkWithURLString:(NSString *)urlString completion:(VMPythonRemoteSourceDownloaderCheckingCompletion)completion;
- (void)py_downloadWithURLString:(NSString *)urlString inFormat:(nullable NSString *)format;

- (void)debug_downloadWithURLString:(NSString *)urlString
                           progress:(VMPythonRemoteSourceDownloaderProgress)progress
                         completion:(VMPythonRemoteSourceDownloaderCompletion)completion;

#pragma mark - ObjC Related

- (void)objc_downloadWithSourceOptionItem:(VMRemoteSourceOptionModel *)item;

@end

NS_ASSUME_NONNULL_END
