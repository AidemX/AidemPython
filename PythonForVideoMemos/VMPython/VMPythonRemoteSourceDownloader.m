//
//  VMPythonRemoteSourceDownloader.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonRemoteSourceDownloader.h"

#import "VMPython.h"
// Model
#import "VMRemoteSourceModel.h"
// Lib
#import "Python.h"


static char * const kSourceDownloaderMethodOfCheckSource_    = "check_source";
static char * const kSourceDownloaderMethodOfDownloadSource_ = "download_source";


@interface VMPythonRemoteSourceDownloader ()

@property (nonatomic, assign) int debug;

@property (nonatomic, assign, getter=isModuleLoaded) BOOL moduleLoaded;
@property (nonatomic, copy) NSString *savePath;

@property (nonatomic, assign) PyObject *pyObj;

#ifdef DEBUG

- (void)_loadKYVideoDownloaderModuleIfNeeded;

- (NSString *)_errorMessageFromPyErrOccurred;

- (VMRemoteSourceModel *)_newRemoteSourceItemFromJSON:(NSDictionary *)json;

#endif // END #ifdef DEBUG

@end


@implementation VMPythonRemoteSourceDownloader

- (void)dealloc
{
  [[VMPython sharedInstance] quitPythonEnv];
}

- (instancetype)initWithSavePath:(NSString *)savePath inDebugMode:(BOOL)debugMode
{
  if (self = [super init]) {
    self.debug = (debugMode ? 1 : 0);
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
  
  static const char *moduleName = "video_memos.ky_source_downloader";
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
  
  if (NULL != pyErrTraceback && [self inDebugMode]) {
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

- (VMRemoteSourceModel *)_newRemoteSourceItemFromJSON:(NSDictionary *)json
{
  VMRemoteSourceModel *sourceItem = [[VMRemoteSourceModel alloc] init];
  sourceItem.title     = json[@"title"];
  sourceItem.site      = json[@"site"];
  sourceItem.urlString = json[@"url"];
  
  sourceItem.userAgent = json[@"ua"];
  sourceItem.referer   = json[@"referer"];
  
  NSDictionary *streams = json[@"streams"];
  if (nil != streams && [streams isKindOfClass:[NSDictionary class]]) {
    NSMutableArray <VMRemoteSourceOptionModel *> *options = [NSMutableArray array];
    for (NSString *key in [streams allKeys]) {
      VMRemoteSourceOptionModel *option = [VMRemoteSourceOptionModel newWithKey:key andValue:streams[key]];
      [options addObject:option];
    }
    sourceItem.options = options;
  }
  
  return sourceItem;
}

#pragma mark - Public

- (BOOL)inDebugMode
{
  return (1 == self.debug);
}

#pragma mark - Public (Python Related)

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonRemoteSourceDownloaderCheckingCompletion)completion
{
  [self _loadKYVideoDownloaderModuleIfNeeded];
  
  NSLog(@"Checking Source w/ URL: %@ ...", urlString);
  
  VMRemoteSourceModel *sourceItem = nil;
  NSString *errorMessage = nil;
  
  NSString *jsonPath;
  if (self.cacheJSONFile) {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9_]+" options:0 error:nil];
    NSString *filename = [regex stringByReplacingMatchesInString:urlString options:0 range:NSMakeRange(0, urlString.length) withTemplate:@"_"];
    jsonPath = [self.savePath stringByAppendingPathComponent:[filename stringByAppendingPathExtension:@"json"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:jsonPath]) {
      NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
      NSError *error = nil;
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
      if (error) {
        // Can't parse the json file, let's rm it & reload from remote.
        [fileManager removeItemAtPath:jsonPath error:NULL];
        
      } else {
        sourceItem = [self _newRemoteSourceItemFromJSON:json];
        NSLog(@"\nGot cached JSON file at %@\nsourceItem.options: %@", jsonPath, sourceItem.options);
        completion(sourceItem, nil);
        return;
      }
    }
  }
  
  const char *url = [urlString UTF8String];
  PyObject *result = PyObject_CallMethod(self.pyObj, kSourceDownloaderMethodOfCheckSource_, "(ssssi)",
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
      NSError *error = nil;
      NSString *resultJsonString = [NSString stringWithUTF8String:resultCString];
      NSData *resultJsonData = [resultJsonString dataUsingEncoding:NSUTF8StringEncoding];
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:resultJsonData options:kNilOptions error:&error];
      if (error) {
        errorMessage = [NSString stringWithFormat:@"Parsing JSON failed: %@\nThe String to Parse: %@", [error localizedDescription], resultJsonString];
        NSLog(@"%@", errorMessage);
        
      } else {
        NSLog(@"Parsed JSON Dict: %@", json);
        if (self.cacheJSONFile && jsonPath) {
          [resultJsonString writeToFile:jsonPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        sourceItem = [self _newRemoteSourceItemFromJSON:json];
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
    result = PyObject_CallMethod(self.pyObj, kSourceDownloaderMethodOfDownloadSource_, "(ssssssi)",
                                 path, url, "",        "a_proxy", "a_username", "a_pwd", self.debug);
  } else {
    const char *formatArg = [format UTF8String];
    result = PyObject_CallMethod(self.pyObj, kSourceDownloaderMethodOfDownloadSource_, "(ssssssi)",
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
}

- (void)downloadWithSourceOptionItem:(VMRemoteSourceOptionModel *)item
{
  // ...
}

/*
- (void)debug_downloadWithURLString:(NSString *)urlString
                           progress:(VMPythonRemoteSourceDownloaderProgress)progress
                         completion:(VMPythonRemoteSourceDownloaderCompletion)completion
{
  [self _loadKYVideoDownloaderModuleIfNeeded];
  
  NSLog(@"Test Downloading Progress w/ URL: %@ ...", urlString);
  
  NSString *errorMessage = nil;
  
  const char *url = [urlString UTF8String];
  PyObject *result = PyObject_CallMethod(self.pyObj, "debug_download_progress", "(s)", url);
  
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
  NSLog(@"\nReaches `-debug_downloadWithURLString:progress:completion:` End.");
}*/

@end
