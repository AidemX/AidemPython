//
//  VMFileSizeCalculator.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 14/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface VMFileSizeCalculator : NSObject

+ (NSString *)readableTextFromFileSizeInBytes:(uint64_t)fileSizeInBytes;

@end

NS_ASSUME_NONNULL_END
