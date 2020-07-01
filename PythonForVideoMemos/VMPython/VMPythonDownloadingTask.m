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
#import "VMPythonVideoMemosModule.h"
#import "VMRemoteSourceModel.h"
#import "VMPythonDownloadingTask.h"


@interface VMPythonDownloadingTask ()

@property (nonatomic, weak) VMPythonVideoMemosModule *pythonVideoMemosModule;

@property (nonatomic, copy)           NSString *urlString;
@property (nonatomic, copy, nullable) NSString *format;

@property (nonatomic, copy,   nullable) NSString *progressFilePath;
@property (nonatomic, strong, nullable) NSTimer  *progressTimer;

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

- (instancetype)initWithURLString:(NSString *)urlString
                         inFormat:(NSString *)format
                            title:(NSString *)title
           pythonVideoMemosModule:(VMPythonVideoMemosModule *)pythonVideoMemosModule
{
  if (self = [super init]) {
    self.urlString = urlString;
    self.format    = format;
    
    self.pythonVideoMemosModule = pythonVideoMemosModule;
    
    NSString *preogresFileName = [title stringByAppendingPathExtension:@"progress"];
    self.progressFilePath = [self.pythonVideoMemosModule.savePath stringByAppendingPathComponent:preogresFileName];
    NSLog(@"self.progressFilePath: %@", self.progressFilePath);
    
//    [[VMPythonRemoteSourceDownloader sharedInstance] enqueueDownloadingTask:self];
  }
  return self;
}

#pragma mark - Private

- (void)_checkProgress
{
  NSString *content = [NSString stringWithContentsOfFile:self.progressFilePath encoding:NSUTF8StringEncoding error:NULL];
  NSLog(@"GET CONTENT \"%f\" from .progress file", content.floatValue);
}

#pragma mark - Public (Override NSOperation)

- (void)main
{
  NSLog(@"# Start Operation: %@", self);
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
  
  typeof(self) __weak weakSelf = self;
  VMPythonVideoMemosModuleDownloadingCompletion completion = ^(NSString *errorMessage) {
//    if (errorMessage) {
//      dispatch_async(dispatch_get_main_queue(), ^{
//        [self _presentAlertWithTitle:nil message:errorMessage];
//      });
//    } else {
//      NSLog(@"Did complete downloading.");
//    }
    [weakSelf.progressTimer invalidate];
    weakSelf.progressTimer = nil;
  };
  [self.pythonVideoMemosModule downloadWithURLString:self.urlString
                                            inFormat:self.format
                                          completion:completion];
}

#pragma mark - Public

/*
- (void)resume
{
  
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
}*/

@end
