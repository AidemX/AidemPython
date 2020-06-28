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
// Lib
@import AFNetworking;


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
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  
  NSURL *url = [NSURL URLWithString:[optionItem.urls firstObject]];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:60];
  if (sourceItem.userAgent) [request addValue:sourceItem.referer forHTTPHeaderField:@"User-Agent"];
  if (sourceItem.referer)   [request addValue:sourceItem.referer forHTTPHeaderField:@"Referer"];
  
  NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
    NSURL *destinationURL = [self.baseSavePathURL URLByAppendingPathComponent:[response suggestedFilename]];
    return destinationURL;
  } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
    NSLog(@"File downloaded to: %@", filePath);
  }];
  [downloadTask resume];
}

@end
