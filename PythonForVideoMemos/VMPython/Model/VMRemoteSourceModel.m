//
//  VMRemoteSourceModel.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 26/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMRemoteSourceModel.h"

@implementation VMRemoteSourceModel

#pragma mark - Public

- (VMRemoteSourceOptionModel *)matchedOptionAtRow:(NSInteger *)matchedRow withTaskIdentifier:(NSString *)taskIdentifier
{
  VMRemoteSourceOptionModel *matchedOption = nil;
  NSInteger row = 0;
  for (VMRemoteSourceOptionModel *option in self.options) {
    if (option.taskIdentifier && [option.taskIdentifier isEqualToString:taskIdentifier]) {
      matchedOption = option;
      break;
    }
    ++row;
  }
  *matchedRow = (nil == matchedOption ? NSNotFound : row);
  
  return matchedOption;
}

@end
