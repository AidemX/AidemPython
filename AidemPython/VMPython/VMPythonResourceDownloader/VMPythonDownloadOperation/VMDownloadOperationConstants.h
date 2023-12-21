//
//  VMDownloadOperationConstants.h
//  AidemPythonDemo
//
//  Created by Kjuly on 16/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, VMDownloadOperationStatus) {
  kVMDownloadOperationStatusNone = 0,
  kVMDownloadOperationStatusOfWaiting,
  kVMDownloadOperationStatusOfExecuting,
  kVMDownloadOperationStatusOfFinished,
  kVMDownloadOperationStatusOfCancelled,
};


@interface VMDownloadOperationConstants : NSObject

@end

NS_ASSUME_NONNULL_END
