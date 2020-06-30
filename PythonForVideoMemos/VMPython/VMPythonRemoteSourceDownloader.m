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
#import "VMPythonVideoMemosModule.h"
#import "VMRemoteSourceModel.h"
#import "VMPythonDownloadingTask.h"
// Lib
#import "Python.h"

@interface VMPythonRemoteSourceDownloader ()

@property (nonatomic, strong) VMPythonVideoMemosModule *pythonVideoMemosModule;

@property (nonatomic, strong) NSMutableDictionary <NSString *, VMPythonDownloadingTask *> *taskRef;

@end


@implementation VMPythonRemoteSourceDownloader

- (void)dealloc
{
  [[VMPython sharedInstance] quitPythonEnv];
}

+ (instancetype)sharedInstance
{
  static VMPythonRemoteSourceDownloader *_sharedVMPythonRemoteSourceDownloader = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedVMPythonRemoteSourceDownloader = [[VMPythonRemoteSourceDownloader alloc] init];
  });
  
  return _sharedVMPythonRemoteSourceDownloader;
}

- (instancetype)init
{
  if (self = [super init]) {
    _pythonVideoMemosModule = [[VMPythonVideoMemosModule alloc] init];
  }
  return self;
}

#pragma mark - Public (Python Related)

- (void)setupWithSavePath:(NSString *)savePath cacheJSONFile:(BOOL)cacheJSONFile inDebugMode:(BOOL)debugMode
{
  NSLog(@"[VMPythonRemoteSourceDownloader]: Downloaded sources will be stored at: %@", savePath);
  [self.pythonVideoMemosModule setupWithSavePath:savePath cacheJSONFile:cacheJSONFile inDebugMode:debugMode];
}

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonVideoMemosModuleRemoteSourceCheckingCompletion)completion
{
  [self checkWithURLString:urlString completion:completion];
}

- (void)downloadWithURLString:(NSString *)urlString
                     inFormat:(NSString *)format
                        title:(NSString *)title
                     progress:(VMPythonVideoMemosModuleDownloadingProgress)progress
                   completion:(VMPythonVideoMemosModuleDownloadingCompletion)completion
{
  [self.pythonVideoMemosModule downloadWithURLString:urlString inFormat:format title:title progress:progress completion:completion];
}

- (void)downloadWithSourceItem:(VMRemoteSourceModel *)sourceItem
                    optionItem:(VMRemoteSourceOptionModel *)optionItem
                      progress:(VMPythonVideoMemosModuleDownloadingProgress)progress
                    completion:(VMPythonVideoMemosModuleDownloadingCompletion)completion
{
  [self.pythonVideoMemosModule downloadWithSourceItem:sourceItem optionItem:optionItem progress:progress completion:completion];
}

/*
- (void)debug_downloadWithURLString:(NSString *)urlString
                           progress:(VMPythonRemoteSourceDownloaderProgress)progress
                         completion:(VMPythonRemoteSourceDownloaderCompletion)completion
{
  [self _loadKYVideoDownloaderModuleIfNeeded];
  
  static const char *moduleName = "test_source_downloader";
  PyObject *pyObj = PyImport_ImportModule(moduleName);
  if (pyObj == NULL) {
    PyErr_Print();
    return;
    
  } else {
    NSLog(@"Importing %s module succeeded", moduleName);
  }
  
  NSLog(@"Test Downloading Progress w/ URL: %@ ...", urlString);
  
  NSString *errorMessage = nil;
  
  const char *url = [urlString UTF8String];
  PyObject *result = PyObject_CallMethod(pyObj, "debug_download_progress", "(s)", url);
  
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

/*
#pragma mark - Downloading Task

- (void)enqueueDownloadingTask:(VMPythonDownloadingTask *)task
{
  if (!self.taskRef) {
    self.taskRef = [NSMutableDictionary dictionary];
  }
  
  if (nil == self.taskRef[task.urlString]) {
    self.taskRef[task.urlString] = task;
  }
}*/

@end
