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

- (void)vm_pythonResourceDownloaderDidStartTaskWithIdentifier:(NSString *)taskIdentifier;

- (void)vm_pythonResourceDownloaderDidUpdateTaskWithIdentifier:(NSString *)taskIdentifier progress:(float)progress;

- (void)vm_pythonResourceDownloaderDidEndTaskWithIdentifier:(NSString *)taskIdentifier errorMessage:(nullable NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
