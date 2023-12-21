//
//  VMResourceDownloader.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 28/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMResourceDownloader.h"

#import "VMPythonCommon.h"
// Model
#import "VMWebResourceModel.h"
// Lib
@import AFNetworking;


@implementation VMResourceDownloader

+ (instancetype)sharedInstance
{
  static VMResourceDownloader *_sharedVMResourceDownloader = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedVMResourceDownloader = [[VMResourceDownloader alloc] init];
  });
  
  return _sharedVMResourceDownloader;
}

#pragma mark - Public

- (void)downloadWithSourceItem:(VMWebResourceModel *)sourceItem optionItem:(VMWebResourceOptionModel *)optionItem
{
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  
  NSURL *url = nil;//[NSURL URLWithString:[optionItem.urls firstObject]];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
  if (sourceItem.userAgent) [request addValue:sourceItem.referer forHTTPHeaderField:@"User-Agent"];
  if (sourceItem.referer)   [request addValue:sourceItem.referer forHTTPHeaderField:@"Referer"];
  
  NSString *filename = [sourceItem.title stringByAppendingPathExtension:optionItem.mediaTypeText];
  NSURL *destinationURL = [self.baseSavePathURL URLByAppendingPathComponent:filename];
  
  NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
    return destinationURL;
  } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
    VMPythonLogNotice(@"File downloaded to: %@", filePath);
  }];
  [downloadTask resume];
}

@end
