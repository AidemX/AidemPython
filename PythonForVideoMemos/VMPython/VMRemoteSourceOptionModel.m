//
//  VMRemoteSourceOptionModel.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 26/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMRemoteSourceOptionModel.h"

@implementation VMRemoteSourceOptionModel

+ (instancetype)newWithKey:(NSString *)key andValue:(NSDictionary *)value
{
  VMRemoteSourceOptionModel *item = [[VMRemoteSourceOptionModel alloc] init];
  
  item.format = key;
  
  item.mediaTypeText = value[@"container"];
  item.qualityText   = value[@"quality"];
  
  NSInteger size = [value[@"size"] integerValue];;
  item.size = size;
  
  if (size < 1048576) item.sizeText = [NSString stringWithFormat:@"%.2f KB", (double)(size / 1024.f)];
  else                item.sizeText = [NSString stringWithFormat:@"%.2f MB", (double)(size / 1048576.f)];
  
  return item;
}

@end
