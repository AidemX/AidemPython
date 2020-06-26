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

@interface VMPythonRemoteSourceDownloader : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithSavePath:(NSString *)savePath;

- (void)checkWithURLString:(NSString *)urlString completion:(void (^)(VMRemoteSourceModel *_Nullable sourceItem))completion;

- (void)downloadWithURLString:(NSString *)urlString inFormat:(nullable NSString *)format;

@end

NS_ASSUME_NONNULL_END
