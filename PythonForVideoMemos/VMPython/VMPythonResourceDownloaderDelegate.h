//
//  VMPythonResourceDownloaderDelegate.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 6/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol VMPythonResourceDownloaderDelegate <NSObject>

@optional

- (void)vm_pythonResourceDownloaderDidStartTaskWithIdentifier:(NSString *)taskIdentifier totalFileSize:(uint64_t)totalFileSize userInfo:(nullable NSDictionary *)userInfo;

- (void)vm_pythonResourceDownloaderDidUpdateTaskWithIdentifier:(NSString *)taskIdentifier receivedFileSize:(uint64_t)receivedFileSize;

- (void)vm_pythonResourceDownloaderDidEndTaskWithIdentifier:(NSString *)taskIdentifier userInfo:(nullable NSDictionary *)userInfo errorMessage:(nullable NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
