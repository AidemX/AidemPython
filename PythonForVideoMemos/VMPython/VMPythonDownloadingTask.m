//
//  VMPythonDownloadingTask.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 29/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonDownloadingTask.h"

// Data Service
#import "VMPythonRemoteSourceDownloader.h"
// Model
#import "VMRemoteSourceModel.h"
#import "VMPythonDownloadingTask.h"


@interface VMPythonDownloadingTask ()

@property (nonatomic, copy, nullable) NSString *progressFilePath;

@property (nonatomic, strong, nullable) NSTimer *progressTimer;

#ifdef DEBUG

- (void)_checkProgress;

#endif // END #ifdef DEBUG

@end


@implementation VMPythonDownloadingTask

- (void)dealloc
{
  if (self.progressTimer) {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
  }
}

- (instancetype)initWithBaseSavePath:(NSString *)baseSavePath title:(NSString *)title
//                          sourceItem:(VMRemoteSourceModel *)sourceItem optionItem:(VMRemoteSourceOptionModel *)optionItem
{
  if (self = [super init]) {
//    _urlString = sourceItem.urlString;
    NSString *preogresFileName = [title stringByAppendingPathExtension:@"progress"];
    self.progressFilePath = [baseSavePath stringByAppendingPathComponent:preogresFileName];
    NSLog(@"self.progressFilePath: %@", self.progressFilePath);
    
    
//    [[VMPythonRemoteSourceDownloader sharedInstance] enqueueDownloadingTask:self];
  }
  return self;
}

#pragma mark - Private

- (void)_checkProgress
{
  NSString *content = [NSString stringWithContentsOfFile:self.progressFilePath encoding:NSUTF8StringEncoding error:NULL];
  NSLog(@"GET CONTENT \"%@\" from .progress file", content);
}

#pragma mark - Public

- (void)resume
{
  if (self.progressTimer) {
    return;
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                          target:self
                                                        selector:@selector(_checkProgress)
                                                        userInfo:nil
                                                         repeats:YES];
  });
}

- (void)pause
{
  if (self.progressTimer) {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
  }
}

- (void)finish
{
  if (self.progressTimer) {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
  }
  
  NSError *error = nil;
  if ([[NSFileManager defaultManager] removeItemAtPath:self.progressFilePath error:&error]) {
    NSLog(@"Removed progressFilePath at %@", self.progressFilePath);
  } else {
    NSLog(@"Failed to remove progressFilePath at %@, error: %@", self.progressFilePath, [error localizedDescription]);
  }
}

- (void)updateWithProgress:(float)progress
{
  self.progress = progress;
  
  NSLog(@"VMPythonDownloadingTask [%@] progress: %f", self.urlString, progress);
}

@end
