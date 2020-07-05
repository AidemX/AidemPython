//
//  VMRemoteResourceModel.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 26/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMRemoteResourceModel.h"

@implementation VMRemoteResourceModel

#pragma mark - Public

- (VMRemoteResourceOptionModel *)matchedOptionAtRow:(NSInteger *)matchedRow withTaskIdentifier:(NSString *)taskIdentifier
{
  VMRemoteResourceOptionModel *matchedOption = nil;
  NSInteger row = 0;
  for (VMRemoteResourceOptionModel *option in self.options) {
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
