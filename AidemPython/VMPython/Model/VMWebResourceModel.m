//
//  VMWebResourceModel.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 26/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMWebResourceModel.h"

@implementation VMWebResourceModel

#pragma mark - Public

- (VMWebResourceOptionModel *)matchedOptionAtRow:(NSInteger *)matchedRow withTaskIdentifier:(NSString *)taskIdentifier
{
  VMWebResourceOptionModel *matchedOption = nil;
  NSInteger row = 0;
  for (VMWebResourceOptionModel *option in self.options) {
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
