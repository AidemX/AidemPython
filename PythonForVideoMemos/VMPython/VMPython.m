//
//  VMPython.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPython.h"

// Lib
#import "Python.h"


@interface VMPython ()

@property (nonatomic, assign, readwrite) BOOL initialized;

@end


@implementation VMPython

+ (instancetype)sharedInstance
{
  static VMPython *_sharedVMPython = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedVMPython = [[VMPython alloc] init];
  });
  
  return _sharedVMPython;
}

- (void)enterPythonEnv
{
  if (self.isInitialized) {
    return;
  }
  
  // Change the executing path to YourApp
  //chdir("PythonForVideoMemos-Demo");
  
  // Special environment to prefer .pyo, and don't write bytecode if .py are found
  // because the process will not have a write attribute on the device.
  putenv("PYTHONOPTIMIZE=2");
  putenv("PYTHONDONTWRITEBYTECODE=1");
  putenv("PYTHONNOUSERSITE=1");
  putenv("PYTHONPATH=.");
  putenv("PYTHONUNBUFFERED=1");
  putenv("LC_CTYPE=UTF-8");
  // putenv("PYTHONVERBOSE=1");
  // putenv("PYOBJUS_DEBUG=1");
  
  // Kivy environment to prefer some implementation on iOS platform
  putenv("KIVY_BUILD=ios");
  putenv("KIVY_NO_CONFIG=1");
  putenv("KIVY_NO_FILELOG=1");
  putenv("KIVY_WINDOW=sdl2");
  putenv("KIVY_IMAGE=imageio,tex,gif");
  putenv("KIVY_AUDIO=sdl2");
  putenv("KIVY_GL_BACKEND=sdl2");
  
  // IOS_IS_WINDOWED=True disables fullscreen and then statusbar is shown
  putenv("IOS_IS_WINDOWED=False");
  
  //#ifndef DEBUG
  putenv("KIVY_NO_CONSOLELOG=1");
  //#endif
  
  NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
  resourcePath = [resourcePath stringByAppendingPathComponent:@"python"];
  NSLog(@"resourcePath: %@", resourcePath);
#if PY_MAJOR_VERSION == 2
  wchar_t *pythonHome = (wchar_t *)[resourcePath UTF8String];
  NSLog(@"PythonHome is: %s", pythonHome);
  Py_SetPythonHome(pythonHome);
#else
  NSString *pythonHome = [NSString stringWithFormat:@"PYTHONHOME=%@", resourcePath, nil];
  putenv((char *)[pythonHome UTF8String]);
  
  NSString *pythonPath = [NSString stringWithFormat:@"PYTHONPATH=%@:%@/lib/python3.8/:%@/lib/python3.8/site-packages:.", resourcePath, resourcePath, resourcePath, nil];
  putenv((char *)[pythonPath UTF8String]);
  
  NSString *tmpPath = [NSString stringWithFormat:@"TMP=%@/tmp", resourcePath, nil];
  putenv((char *)[tmpPath UTF8String]);
#endif
  
  // Initialize Python Environment
  NSLog(@"Initializing Python ...");
  Py_Initialize();
  // If other modules are using the thread, we need to initialize them before.
  PyEval_InitThreads();
  
  BOOL pythonEnvInitialized = Py_IsInitialized();
  NSLog(@"Python Environment Initialization %@", (pythonEnvInitialized ? @"Succeeded" : @"Failed"));
  
  self.initialized = YES;
}

- (void)quitPythonEnv
{
  if (self.isInitialized) {
    self.initialized = NO;
    Py_Finalize();
    NSLog(@"Python Finalize");
  }
}

@end
