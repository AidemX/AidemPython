//
//  VMRemoteSourceDownloader.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 28/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMRemoteSourceDownloader.h"

// Model
#import "VMRemoteSourceModel.h"


@implementation VMRemoteSourceDownloader

+ (instancetype)sharedInstance
{
  static VMRemoteSourceDownloader *_sharedVMRemoteSourceDownloader = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedVMRemoteSourceDownloader = [[VMRemoteSourceDownloader alloc] init];
  });
  
  return _sharedVMRemoteSourceDownloader;
}

#pragma mark - Public

- (void)downloadWithSourceItem:(VMRemoteSourceModel *)sourceItem optionItem:(VMRemoteSourceOptionModel *)optionItem
{
  
}

@end
