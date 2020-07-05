//
//  VMWebResourceOptionModel.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 26/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

#import "VMPythonCommon.h"


NS_ASSUME_NONNULL_BEGIN

@interface VMWebResourceOptionModel : NSObject

@property (nonatomic, copy) NSString *format; ///< Format, used to download as key arg

@property (nonatomic, copy)   NSString *mediaTypeText; ///< Media type
@property (nonatomic, copy)   NSString *qualityText;   ///< Media quality
@property (nonatomic, assign) NSInteger size;          ///< Media size
@property (nonatomic, copy)   NSString *sizeText;      ///< Media size in text

@property (nonatomic, copy) NSArray <NSString *> *urls; ///< Urls in string

@property (nonatomic, assign) VMPythonDownloadProcessStatus status; ///< Item status
@property (nonatomic, copy, nullable) NSString *taskIdentifier; ///< Associated task's identifier
@property (nonatomic, assign) float progress; ///< Downloading progress, from 0.f to 1.f

+ (instancetype)newWithKey:(NSString *)key andValue:(NSDictionary *)value;

@end

NS_ASSUME_NONNULL_END
