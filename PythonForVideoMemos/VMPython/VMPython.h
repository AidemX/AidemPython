//
//  VMPython.h
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface VMPython : NSObject

@property (nonatomic, assign, readonly, getter=isInitialized) BOOL initialized;

+ (instancetype)sharedInstance;

- (void)enterPythonEnv;
- (void)quitPythonEnv;

@end

NS_ASSUME_NONNULL_END
