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

#pragma mark - Public

- (void)checkWithURLString:(NSString *)urlString completion:(void (^)(VMRemoteSourceModel *))completion
{
  [self _loadKYVideoDownloaderModuleIfNeeded];
  
  NSLog(@"Checking Source w/ URL: %@ ...", urlString);
  
  VMRemoteSourceModel *sourceItem;
  
  const char *url = [urlString UTF8String];
  PyObject *result = PyObject_CallMethod(self.pyObj, kSourceDownloaderMethodOfCheckSource_, "(ssss)",
                                         url, "a_proxy", "a_username", "a_pwd");
  if (result == NULL) {
    PyErr_Print();
  } else {
    NSLog(@"Got result!");
    PyObject_Print(result, stdout, Py_PRINT_RAW);
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
    
    if (resultCString != NULL) {
      NSError *error = nil;
      NSString *resultJsonString = [NSString stringWithUTF8String:resultCString];
      NSData *resultJsonData = [resultJsonString dataUsingEncoding:NSUTF8StringEncoding];
      NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:resultJsonData options:kNilOptions error:&error];
      if (error) {
        NSLog(@"Parsing JSON failed: %@", [error localizedDescription]);
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
  PyRun_SimpleString("print('\\n')");
  NSLog(@"Reaches `-checkWithURLString:` End, Got sourceItem.options: %@", sourceItem.options);
  completion(sourceItem);
}

- (void)downloadWithURLString:(NSString *)urlString inFormat:(NSString *)format
{
  [self _loadKYVideoDownloaderModuleIfNeeded];
  
  NSLog(@"Start Downloading Source w/ URL: %@ ...", urlString);
  
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
  } else {
    PyObject_Print(result, stdout, Py_PRINT_RAW);
    Py_DECREF(result);
  }
  PyRun_SimpleString("print('\\n')");
  NSLog(@"Reaches `-downloadWithURLString:` End.");
}

@end
