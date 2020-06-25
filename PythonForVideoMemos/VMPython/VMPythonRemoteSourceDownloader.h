//
//  VMPythonRemoteSourceDownloader.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface VMPythonRemoteSourceDownloader : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithSavePath:(NSString *)savePath;

- (void)checkWithURLString:(NSString *)urlString;
- (void)downloadWithURLString:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
