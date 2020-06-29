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


@implementation VMPythonDownloadingTask

- (instancetype)initWithURLString:(NSString *)urlString
{
  if (self = [super init]) {
    _urlString = urlString;
    
//    [[VMPythonRemoteSourceDownloader sharedInstance] enqueueDownloadingTask:self];
  }
  return self;
}

- (void)updateWithProgress:(float)progress
{
  self.progress = progress;
  
  NSLog(@"VMPythonDownloadingTask [%@] progress: %f", self.urlString, progress);
}

@end
