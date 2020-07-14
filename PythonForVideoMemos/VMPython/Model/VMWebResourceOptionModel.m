//
//  VMWebResourceOptionModel.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 26/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMWebResourceOptionModel.h"

// Data Service
#import "VMFileSizeCalculator.h"


@implementation VMWebResourceOptionModel

+ (instancetype)newWithKey:(NSString *)key andValue:(NSDictionary *)value
{
  VMWebResourceOptionModel *item = [[VMWebResourceOptionModel alloc] init];
  
  item.format = key;
  
  item.mediaTypeText = value[@"container"];
  item.qualityText   = value[@"quality"];
  
  NSInteger size = [value[@"size"] integerValue];;
  item.size = size;
  item.sizeText = [VMFileSizeCalculator vm_readableTextFromFileSizeInBytes:size];
  
  /*
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
  }*/
  
  item.status = kVMPythonDownloadProcessStatusNone;
  item.taskIdentifier = nil;
  
  return item;
}

@end
