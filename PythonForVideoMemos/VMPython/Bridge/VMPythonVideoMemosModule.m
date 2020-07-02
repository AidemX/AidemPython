//
//  VMPythonVideoMemosModule.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 30/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonVideoMemosModule.h"

#import "VMPython.h"
// Lib
#import "Python.h"


//! Make sure it's equal to the one in `site_packages/video_memos/vm_downloading_progress.py`
NSString * const kVMPythonVideoMemosModuleProgressFileName = @"vm_progress";

static char * const kSourceDownloaderMethodOfCheckSource_    = "check_source";
static char * const kSourceDownloaderMethodOfDownloadSource_ = "download_source";


@interface VMPythonVideoMemosModule ()

@property (nonatomic, assign) int debug;

@property (nonatomic, assign, getter=isModuleLoaded) BOOL moduleLoaded;

@property (nonatomic, assign) PyObject *pySourceDownloaderModule;

#ifdef DEBUG

- (void)_loadKYVideoDownloaderModuleIfNeeded;

- (NSString *)_errorMessageFromPyErrOccurred;

#endif // END #ifdef DEBUG

@end


@implementation VMPythonVideoMemosModule

- (void)dealloc
{
  [[VMPython sharedInstance] quitPythonEnv];
  
  if (NULL != self.pySourceDownloaderModule) Py_DECREF(self.pySourceDownloaderModule);
}

#pragma mark - Setter

- (void)setDebugMode:(BOOL)debugMode
{
  _debugMode = debugMode;
  
  self.debug = (debugMode ? 1 : 0);
}

#pragma mark - Private

- (void)_loadKYVideoDownloaderModuleIfNeeded
{
  if (self.isModuleLoaded) {
    return;
  }
  
  [[VMPython sharedInstance] enterPythonEnv];
  
  static const char *moduleName = "video_memos.vm_source_downloader";
  self.pySourceDownloaderModule = PyImport_ImportModule(moduleName);
  if (self.pySourceDownloaderModule == NULL) {
    PyErr_Print();
    
  } else {
    NSLog(@"Importing %s module succeeded", moduleName);
    self.moduleLoaded = YES;
  }
}

- (NSString *)_errorMessageFromPyErrOccurred
{
  //PyObject *pErrString = PyObject_Str(pErr);
  //if (pErrString != NULL) Py_DECREF(pErrString);
  //Py_DECREF(pErr);
  
  // `pValue` contains error message
  // `pTraceback` contains stack snapshot and many other information (see python traceback structure)
  PyObject *pyErrType, *pyErrValue, *pyErrTraceback;
  PyErr_Fetch(&pyErrType, &pyErrValue, &pyErrTraceback);
  
  NSMutableString *mutableErrorMessage = [NSMutableString string];
  
  if (NULL != pyErrType) {
    //NSString *errorTypeText = _stringFromPyObject(pyErrType);
    //if (errorTypeText) [mutableErrorMessage appendFormat:@"%@\n", errorTypeText];
    PyTypeObject *errorTypeObj = (PyTypeObject *)pyErrType;
    [mutableErrorMessage appendFormat:@"%s\n%s\n", errorTypeObj->tp_name, errorTypeObj->tp_doc];
  }
  
  if (NULL != pyErrValue) {
    NSString *errorValueText = _stringFromPyObject(pyErrValue);
    if (errorValueText) [mutableErrorMessage appendFormat:@"%@\n", errorValueText];
  }
  
  if (NULL != pyErrTraceback && self.inDebugMode) {
    //PyTracebackObject *tracebackObj = (PyTracebackObject*)pTraceback;
    //NSString *errorTrackbackText = _stringFromPyObject(pTraceback);
    //if (errorTrackbackText) [mutableErrorMessage appendString:errorTrackbackText];
    // See if we can get a full traceback
    static const char *moduleName = "traceback";
    PyObject *pyTrackbackModule = PyImport_ImportModule(moduleName);
    if (NULL != pyTrackbackModule) {
      PyObject *pyTrackbackModuleFunc = PyObject_GetAttrString(pyTrackbackModule, "format_exception");
      if (NULL != pyTrackbackModuleFunc && PyCallable_Check(pyTrackbackModuleFunc)) {
        PyObject *pyTrackbackValue = PyObject_CallFunctionObjArgs(pyTrackbackModuleFunc, pyErrType, pyErrValue, pyErrTraceback, NULL);
        if (NULL != pyTrackbackValue) {
          //NSString *trackbackValue = _stringFromPyObject(pyTrackbackValue);
          NSMutableString *trackbackValue = [NSMutableString string];
          Py_ssize_t listSize = PyList_Size(pyTrackbackValue);
          for (Py_ssize_t i = 0; i < listSize; ++i) {
            PyObject *line = PyList_GetItem(pyTrackbackValue, i);
            if (NULL != line) {
              [trackbackValue appendString:_stringFromPyObject(line)];
              Py_DECREF(line);
            }
          }
          NSLog(@"TRACEKBACK: %@", trackbackValue);
          Py_DECREF(pyTrackbackValue);
        }
        Py_DECREF(pyTrackbackModuleFunc);
      }
      Py_DECREF(pyTrackbackModule);
    }
  }
  
  if (NULL != pyErrType)      Py_DECREF(pyErrType);
  if (NULL != pyErrValue)     Py_DECREF(pyErrValue);
  if (NULL != pyErrTraceback) Py_DECREF(pyErrTraceback);
  
  return mutableErrorMessage;
}

static inline NSString *_stringFromPyObject(PyObject *pyObj)
{
  PyObject *pyStringObj = PyObject_Str(pyObj);
  if (NULL == pyStringObj) {
    return nil;
  } else {
    NSString *result = _stringFromPyStringObject(pyStringObj);
    Py_DECREF(pyStringObj);
    return result;
  }
}

static inline NSString *_stringFromPyStringObject(PyObject *pyStringObj)
{
  char *cString = NULL;
  PyArg_Parse(pyStringObj, "s", &cString);
  return (NULL == cString ? nil : [NSString stringWithUTF8String:cString]);
}

#pragma mark - Public

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonVideoMemosModuleRemoteSourceCheckingCompletion)completion
{
  [self _loadKYVideoDownloaderModuleIfNeeded];
  
  NSLog(@"Checking Source w/ URL: %@ ...", urlString);
  
  NSString *resultJsonString = nil;
  NSString *errorMessage = nil;
  
  const char *url = [urlString UTF8String];
  PyObject *result = PyObject_CallMethod(self.pySourceDownloaderModule, kSourceDownloaderMethodOfCheckSource_, "(ssssi)",
                                         url, "a_proxy", "a_username", "a_pwd", self.debug);
  if (NULL == result) {
    //PyErr_Print();
    if (PyErr_Occurred()) {
      errorMessage = [self _errorMessageFromPyErrOccurred];
    }
    
    if (0 == errorMessage.length) {
      errorMessage = @"Empty Result";
    }
    NSLog(@"Error Msg:\n%@", errorMessage);
    
  } else {
    //NSLog(@"Got result!");
    //PyObject_Print(result, stdout, Py_PRINT_RAW);
    /*
    NSString *listInfo = CFBridgingRelease(PyObject_GetAttrString(result, nil));
    PyObject *output = PyObject_GetAttrString(result, "value"); //get the stdout and stderr from our catchOutErr object
    printf("Here's the output:\n %s", Pystring(output));
    PyObject_Print(output, stdout, Py_PRINT_RAW);
     */
    
    // Prase JSON from `result`.
    char *resultCString = NULL;
    PyArg_Parse(result, "s", &resultCString);
    Py_DECREF(result);
    
    if (NULL == resultCString) {
      errorMessage = @"Empty Result";
    } else {
      resultJsonString = [NSString stringWithUTF8String:resultCString];
    }
  }
  //PyRun_SimpleString("print('\\n')");
  NSLog(@"\nReaches `-checkWithURLString:` End");
  
  completion(resultJsonString, errorMessage);
}

- (void)downloadWithURLString:(NSString *)urlString
                     inFormat:(NSString *)format
                   completion:(VMPythonVideoMemosModuleDownloadingCompletion)completion
{
  [self _loadKYVideoDownloaderModuleIfNeeded];
  
  // GIL: Global Interpreter Lock, it's a mutex (or a lock) that allows only
  //   one thread to hold the control of the Python interpreter.
  // REF: https://realpython.com/python-gil/
  //PyGILState_STATE pyGILState = PyGILState_Ensure();
  
  NSLog(@"Start Downloading Source w/ URL: %@ ...", urlString);
  
  /*
  VMPythonDownloadingOperation *task;
  if (title && progress) {
    task = [[VMPythonDownloadingOperation alloc] initWithBaseSavePath:self.savePath title:title];
    task.urlString = urlString;
    [self enqueueDownloadingTask:task];
    
    [task resume];
  }*/
  
  NSString *errorMessage = nil;
  
  const char *url  = [urlString UTF8String];
  const char *path = [self.savePath UTF8String];
  
  PyObject *result;
  if (nil == format) {
    result = PyObject_CallMethod(self.pySourceDownloaderModule, kSourceDownloaderMethodOfDownloadSource_, "(ssssssi)",
                                 path, url, "",        "a_proxy", "a_username", "a_pwd", self.debug);
  } else {
    const char *formatArg = [format UTF8String];
    result = PyObject_CallMethod(self.pySourceDownloaderModule, kSourceDownloaderMethodOfDownloadSource_, "(ssssssi)",
                                 path, url, formatArg, "a_proxy", "a_username", "a_pwd", self.debug);
  }
  
  if (result == NULL) {
    //PyErr_Print();
    if (PyErr_Occurred()) {
      errorMessage = [self _errorMessageFromPyErrOccurred];
    }
    
    if (0 == errorMessage.length) {
      errorMessage = [NSString stringWithFormat:@"Failed to download source w/ URL: %@", urlString];
    }
    
  } else {
    PyObject_Print(result, stdout, Py_PRINT_RAW);
    Py_DECREF(result);
  }
  
  //PyRun_SimpleString("print('\\n')");
  NSLog(@"\nReaches `-downloadWithURLString:` End.");
  
  /*
  if (task) {
    [task finish];
    [self.taskRef removeObjectForKey:task.urlString];
  }*/
  
  //PyGILState_Release(pyGILState);
  
  if (completion) {
    completion(errorMessage);
  }
}

/*
- (void)stopDownloadingWithTaskProgressFilePath:(NSString *)taskProgressFilePath
{
  NSLog(@"Stop Downloading Source ...");
  
  if (!self.isModuleLoaded) {
    NSLog(@"Module Not Loaded, Do Nothing.");
    return;
  }
  
  PyGILState_STATE pyGILState = PyGILState_Ensure();
  
  const char *path = [taskProgressFilePath UTF8String];
  int debug = 1;
  PyObject *result = PyObject_CallMethod(self.pySourceDownloaderModule, "stop_downloading", "(si)", path, debug);
  if (result == NULL) {
    PyErr_Print();
    
  } else {
    PyObject_Print(result, stdout, Py_PRINT_RAW);
    Py_DECREF(result);
  }
  //PyRun_SimpleString("print('\\n')");
  NSLog(@"\nReaches `-stopDownloading:` End.");
  
  PyGILState_Release(pyGILState);
}*/

@end
