//
//  VMPythonRemoteSourceDownloader.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonRemoteSourceDownloader.h"

#import "VMPython.h"
// Lib
#import "Python.h"


static char * const kSourceDownloaderMethodOfCheckSource_    = "check_source";
static char * const kSourceDownloaderMethodOfDownloadSource_ = "download_source";


@interface VMPythonRemoteSourceDownloader ()

@property (nonatomic, assign, getter=isModuleLoaded) BOOL moduleLoaded;
@property (nonatomic, copy) NSString *savePath;

@property (nonatomic, assign) PyObject *pyObj;

#ifdef DEBUG

- (void)_loadKYVideoDownloaderModuleIfNeeded;

#endif // END #ifdef DEBUG

@end


@implementation VMPythonRemoteSourceDownloader

- (void)dealloc
{
  [[VMPython sharedInstance] quitPythonEnv];
}

- (instancetype)initWithSavePath:(NSString *)savePath
{
  if (self = [super init]) {
    self.savePath = savePath;
    NSLog(@"[VMPythonRemoteSourceDownloader]: Downloaded sources will be stored at: %@", savePath);
  }
  return self;
}

#pragma mark - Private

- (void)_loadKYVideoDownloaderModuleIfNeeded
{
  if (self.isModuleLoaded) {
    return;
  }
  
  [[VMPython sharedInstance] enterPythonEnv];
  
  putenv("PYTHONDONTWRITEBYTECODE=1");
//  NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
//  NSString *resourcePath = [docPath stringByAppendingString:@"/Python.framework/Resources"];
//  NSString *python_path = [NSString stringWithFormat:@"PYTHONPATH=%@/python_scripts:%@/Resources/lib/python3.4/site-packages/", resourcePath, resourcePath, nil];
//  NSLog(@"PYTHONPATH is: %@", python_path);
//  putenv((char *)[python_path UTF8String]);
  
  static const char *moduleName = "ky_source_downloader.ky_source_downloader";
  self.pyObj = PyImport_ImportModule(moduleName);
  if (self.pyObj == NULL) {
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
  PyObject *pType, *pValue, *pTraceback;
  PyErr_Fetch(&pType, &pValue, &pTraceback);
  
  NSMutableString *mutableErrorMessage = [NSMutableString string];
  if (NULL != pType) {
    NSString *errorTypeText = _stringFromPyObject(pType);
    if (errorTypeText) [mutableErrorMessage appendFormat:@"%@\n", errorTypeText];
    Py_DECREF(pType);
  }
  
  if (NULL != pValue) {
    NSString *errorValueText = _stringFromPyStringObject(pValue);
    if (errorValueText) [mutableErrorMessage appendFormat:@"%@\n", errorValueText];
    Py_DECREF(pValue);
  }
  
  if (NULL != pTraceback) {
    NSString *errorTrackbackText = _stringFromPyObject(pTraceback);
    if (errorTrackbackText) [mutableErrorMessage appendString:errorTrackbackText];
    Py_DECREF(pTraceback);
  }
  
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

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonRemoteSourceDownloaderCheckingCompletion)completion
{
  [self _loadKYVideoDownloaderModuleIfNeeded];
  
  NSLog(@"Checking Source w/ URL: %@ ...", urlString);
  
  VMRemoteSourceModel *sourceItem = nil;
  NSString *errorMessage = nil;
  
  const char *url = [urlString UTF8String];
  PyObject *result = PyObject_CallMethod(self.pyObj, kSourceDownloaderMethodOfCheckSource_, "(ssss)",
                                         url, "a_proxy", "a_username", "a_pwd");
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
      NSError *error = nil;
      NSString *resultJsonString = [NSString stringWithUTF8String:resultCString];
      NSData *resultJsonData = [resultJsonString dataUsingEncoding:NSUTF8StringEncoding];
      NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:resultJsonData options:kNilOptions error:&error];
      if (error) {
        errorMessage = [NSString stringWithFormat:@"Parsing JSON failed: %@\nThe String to Parse: %@", [error localizedDescription], resultJsonString];
        NSLog(@"%@", errorMessage);
        
      } else {
        NSLog(@"Parsed JSON Dict: %@", jsonDict);
        
        sourceItem = [[VMRemoteSourceModel alloc] init];
        sourceItem.title     = jsonDict[@"title"];
        sourceItem.site      = jsonDict[@"site"];
        sourceItem.urlString = jsonDict[@"url"];
        
        NSDictionary *streams = jsonDict[@"streams"];
        if (nil != streams && [streams isKindOfClass:[NSDictionary class]]) {
          NSMutableArray <VMRemoteSourceOptionModel *> *options = [NSMutableArray array];
          for (NSString *key in [streams allKeys]) {
            VMRemoteSourceOptionModel *option = [VMRemoteSourceOptionModel newWithKey:key andValue:streams[key]];
            [options addObject:option];
          }
          sourceItem.options = options;
        }
      }
    }
  }
  //PyRun_SimpleString("print('\\n')");
  NSLog(@"\nReaches `-checkWithURLString:` End, Got sourceItem.options: %@", sourceItem.options);
  completion(sourceItem, errorMessage);
}

- (void)downloadWithURLString:(NSString *)urlString inFormat:(NSString *)format
{
  [self _loadKYVideoDownloaderModuleIfNeeded];
  
  NSLog(@"Start Downloading Source w/ URL: %@ ...", urlString);
  
  NSString *errorMessage = nil;
  
  const char *url  = [urlString UTF8String];
  const char *path = [self.savePath UTF8String];
  
  PyObject *result;
  if (nil == format) {
    result = PyObject_CallMethod(self.pyObj, kSourceDownloaderMethodOfDownloadSource_, "(ssssss)",
                                 path, url, "",       "a_proxy", "a_username", "a_pwd");
  } else {
    const char *formatArg = [format UTF8String];
    result = PyObject_CallMethod(self.pyObj, kSourceDownloaderMethodOfDownloadSource_, "(ssssss)",
                                 path, url, formatArg, "a_proxy", "a_username", "a_pwd");
  }
  
  if (result == NULL) {
    PyErr_Print();
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
}

@end
