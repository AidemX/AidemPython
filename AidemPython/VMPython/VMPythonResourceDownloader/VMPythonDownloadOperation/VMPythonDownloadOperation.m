//
//  VMPythonDownloadOperation.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 29/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonDownloadOperation.h"

#import "VMPythonCommon.h"
// Model
#import "VMPythonAidemModule.h"
#import "VMWebResourceModel.h"


NSString * const kVMPythonDownloadOperationPropertyOfName = @"name";

NSString * const kVMPythonDownloadOperationPropertyOfIsExecuting = @"isExecuting";
NSString * const kVMPythonDownloadOperationPropertyOfIsFinished  = @"isFinished";
NSString * const kVMPythonDownloadOperationPropertyOfIsCancelled = @"isCancelled";

NSString * const kVMPythonDownloadOperationPropertyOfReceivedFileSize = @"receivedFileSize";


@interface VMPythonDownloadOperation ()

@property (nonatomic, weak) VMPythonAidemModule *pythonVideoMemosModule;

@property (nonatomic, copy)           NSString *urlString;
@property (nonatomic, copy, nullable) NSString *format;
@property (nonatomic, copy, nullable) NSString *preferredName;

@property (nonatomic, copy,   nullable) NSString *progressFilePath;
@property (nonatomic, strong, nullable) NSTimer  *progressTimer;

#ifdef DEBUG

- (void)_checkProgress;

#endif // END #ifdef DEBUG

@end


@implementation VMPythonDownloadOperation

- (void)dealloc
{
  if (self.progressTimer) {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
  }
}

- (instancetype)initWithURLString:(NSString *)urlString
                         inFormat:(NSString *)format
                    totalFileSize:(uint64_t)totalFileSize
                    preferredName:(NSString *)preferredName
                         userInfo:(NSDictionary *)userInfo
           pythonVideoMemosModule:(VMPythonAidemModule *)pythonVideoMemosModule
                 progressFilePath:(NSString *)progressFilePath
{
  if (self = [super init]) {
    self.name = (preferredName ?: [[NSUUID UUID] UUIDString]);
    
    self.urlString     = urlString;
    self.format        = format;
    self.totalFileSize = (totalFileSize ?: ULLONG_MAX);
    self.preferredName = preferredName;
    self.userInfo      = userInfo;
    
    self.pythonVideoMemosModule = pythonVideoMemosModule;
    self.progressFilePath = progressFilePath;
    VMPythonLogDebug(@"self.progressFilePath: %@", self.progressFilePath);
  }
  return self;
}

#pragma mark - Private

- (void)_checkProgress
{
  NSString *content = [NSString stringWithContentsOfFile:self.progressFilePath encoding:NSUTF8StringEncoding error:NULL];
  // About NSString to "unsigned long long"
  //   unsigned long long receivedFileSize = strtoull([content UTF8String], NULL, 0);
  // REF: https://stackoverflow.com/questions/1181637/storing-and-retrieving-unsigned-long-long-value-to-from-nsstring/1181715#1181715
  uint64_t receivedFileSize = (uint64_t)content.longLongValue;
  VMPythonLogDebug(@"GET CONTENT \"%lld\" from .progress file", receivedFileSize);
  if (self.receivedFileSize != receivedFileSize) {
    self.receivedFileSize = receivedFileSize;
  }
}

#pragma mark - Public (Override NSOperation)

- (void)main
{
  VMPythonLogNotice(@"# Start Operation: %@", self);
  if (self.isCancelled) {
    VMPythonLogNotice(@"# Operation Is Cancelled, Do Nothing.");
    return;
  }
  
  if (self.progressTimer) {
    return;
  }
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:self.progressFilePath]) {
    NSData *data = [NSData data];
    [[NSFileManager defaultManager] createFileAtPath:self.progressFilePath contents:data attributes:nil];
    VMPythonLogDebug(@"Created progress file: vm_progress");
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                          target:self
                                                        selector:@selector(_checkProgress)
                                                        userInfo:nil
                                                         repeats:YES];
  });
  
  typeof(self) __weak weakSelf = self;
  VMPythonAidemModuleDownloadingCompletion completion = ^(NSString *errorMessage) {
    [weakSelf.progressTimer invalidate];
    weakSelf.progressTimer = nil;
    
    if (weakSelf.progressFilePath && [[NSFileManager defaultManager] fileExistsAtPath:weakSelf.progressFilePath]) {
      NSError *error = nil;
      (void)[[NSFileManager defaultManager] removeItemAtPath:weakSelf.progressFilePath error:&error];
      VMPythonLogNotice(@"Did Complete Downloading, Deleting progressFile, error: %@", [error localizedDescription]);
    } else {
      VMPythonLogNotice(@"Did Complete Downloading, No existing progressFile, do nothing.");
    }
  };
  [self.pythonVideoMemosModule downloadWithURLString:self.urlString
                                            inFormat:self.format
                                       preferredName:self.preferredName
                                          completion:completion];
}

#pragma mark - Public (Override NSOperation)

- (void)cancel
{
  VMPythonLogNotice(@"Cancel Operation w/ Task Identifier: %@", self.name);
  [super cancel];
  
  if (self.progressTimer) {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    
    //[self.pythonVideoMemosModule stopDownloading];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] removeItemAtPath:self.progressFilePath error:&error]) {
      VMPythonLogNotice(@"Stop Downloading by deleting progressFile.");
    } else {
      VMPythonLogError(@"Deleting progressFile at path failed: %@", [error localizedDescription]);
    }
  }
}

/*
#pragma mark - Public

- (void)resume
{
  if (!self.isPaused) {
    return;
  }
  self.paused = NO;
  VMPythonLogNotice(@"Resume Operation w/ Task Identifier: %@", self.name);
}

- (void)pause
{
  if (self.isPaused) {
    return;
  }
  self.paused = YES;
  VMPythonLogNotice(@"Pause Operation w/ Task Identifier: %@", self.name);
  
  if (self.progressTimer) {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    
    //[self.pythonVideoMemosModule stopDownloading];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] removeItemAtPath:self.progressFilePath error:&error]) {
      VMPythonLogNotice(@"Stop Downloading by deleting progressFile.");
    } else {
      VMPythonLogError(@"Deleting progressFile at path failed: %@", [error localizedDescription]);
    }
  }
}*/

@end
