//
//  VMFileSizeCalculator.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 14/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMFileSizeCalculator.h"

@implementation VMFileSizeCalculator

#pragma mark - Public

+ (NSString *)readableTextFromFileSizeInBytes:(uint64_t)fileSizeInBytes
{
  NSString *text;
  if (fileSizeInBytes < 1048576) text = [NSString stringWithFormat:@"%.2f KB", (double)(fileSizeInBytes / 1024.f)];
  else                           text = [NSString stringWithFormat:@"%.2f MB", (double)(fileSizeInBytes / 1048576.f)];
  return text;
}

@end
