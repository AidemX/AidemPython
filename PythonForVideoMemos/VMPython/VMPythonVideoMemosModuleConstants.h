//
//  VMPythonVideoMemosModuleConstants.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 30/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

@class VMRemoteSourceModel;


NS_ASSUME_NONNULL_BEGIN

typedef void (^VMPythonVideoMemosModuleRemoteSourceCheckingCompletion)(VMRemoteSourceModel *_Nullable sourceItem, NSString *_Nullable errorMessage);

typedef void (^VMPythonVideoMemosModuleDownloadingProgress)(float progress);
typedef void (^VMPythonVideoMemosModuleDownloadingCompletion)(NSString *_Nullable errorMessage);


@interface VMPythonVideoMemosModuleConstants : NSObject

@end

NS_ASSUME_NONNULL_END
