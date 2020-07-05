//
//  VMWebResourceModel.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 26/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

// Model
#import "VMWebResourceOptionModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface VMWebResourceModel : NSObject

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *site;
@property (nonatomic, copy, nullable) NSString *urlString;

@property (nonatomic, copy, nullable) NSString *userAgent;
@property (nonatomic, copy, nullable) NSString *referer;

@property (nonatomic, copy, nullable) NSArray <VMWebResourceOptionModel *> *options;

- (VMWebResourceOptionModel *)matchedOptionAtRow:(NSInteger *)matchedRow withTaskIdentifier:(NSString *)taskIdentifier;

@end

NS_ASSUME_NONNULL_END
