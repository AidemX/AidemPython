//
//  VMResourceDownloader.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 28/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

@class VMWebResourceModel;
@class VMWebResourceOptionModel;


NS_ASSUME_NONNULL_BEGIN

@interface VMResourceDownloader : NSObject

@property (nonatomic, copy) NSURL *baseSavePathURL;
@property (nonatomic, assign, getter=isDebugMode) BOOL debugMode;

+ (instancetype)sharedInstance;

- (void)downloadWithSourceItem:(VMWebResourceModel *)sourceItem optionItem:(VMWebResourceOptionModel *)optionItem;

@end

NS_ASSUME_NONNULL_END
