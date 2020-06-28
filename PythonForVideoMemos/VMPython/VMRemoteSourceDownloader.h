//
//  VMRemoteSourceDownloader.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 28/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

@class VMRemoteSourceModel;
@class VMRemoteSourceOptionModel;


NS_ASSUME_NONNULL_BEGIN

@interface VMRemoteSourceDownloader : NSObject

@property (nonatomic, copy) NSURL *baseSavePathURL;
@property (nonatomic, assign, getter=isDebugMode) BOOL debugMode;

+ (instancetype)sharedInstance;

- (void)downloadWithSourceItem:(VMRemoteSourceModel *)sourceItem optionItem:(VMRemoteSourceOptionModel *)optionItem;

@end

NS_ASSUME_NONNULL_END
