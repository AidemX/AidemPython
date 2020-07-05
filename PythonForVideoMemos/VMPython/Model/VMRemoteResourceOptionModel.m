//
//  VMRemoteResourceOptionModel.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 26/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMRemoteResourceOptionModel.h"

@implementation VMRemoteResourceOptionModel

+ (instancetype)newWithKey:(NSString *)key andValue:(NSDictionary *)value
{
  VMRemoteResourceOptionModel *item = [[VMRemoteResourceOptionModel alloc] init];
  
  item.format = key;
  
  item.mediaTypeText = value[@"container"];
  item.qualityText   = value[@"quality"];
  
  NSInteger size = [value[@"size"] integerValue];;
  item.size = size;
  
  if (size < 1048576) item.sizeText = [NSString stringWithFormat:@"%.2f KB", (double)(size / 1024.f)];
  else                item.sizeText = [NSString stringWithFormat:@"%.2f MB", (double)(size / 1048576.f)];
  
  NSArray *sources = (NSArray *)value[@"src"];
  if ([sources isKindOfClass:[NSArray class]]) {
    NSMutableArray *urls = [NSMutableArray array];
    for (NSArray *source in sources) {
      NSString *url = ([source isKindOfClass:[NSArray class]] ? [source firstObject] : source);
      if ([url isKindOfClass:[NSString class]]) {
        [urls addObject:url];
      }
    }
    item.urls = urls;
  }
  
  item.status = kVMPythonDownloadProcessStatusNone;
  item.taskIdentifier = nil;
  
  return item;
}

@end