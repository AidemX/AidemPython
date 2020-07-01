//
//  VMPythonRemoteSourceDownloader.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonRemoteSourceDownloader.h"

// Model
#import "VMPythonVideoMemosModule.h"
#import "VMRemoteSourceModel.h"
#import "VMPythonDownloadingOperation.h"


static NSString * const kYNOperationPropertyOfIsExecuting_ = @"isExecuting";
static NSString * const kYNOperationPropertyOfIsFinished_  = @"isFinished";
static NSString * const kYNOperationPropertyOfIsCancelled_ = @"isCancelled";
static NSString * const kYNOperationPropertyOfName_        = @"name";


@interface VMPythonRemoteSourceDownloader ()

@property (nonatomic, strong) VMPythonVideoMemosModule *pythonVideoMemosModule;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSDictionary *> *operationsInfo;
@property (nonatomic, strong) NSOperationQueue *downloadingOperationQueue;

#ifdef DEBUG

- (void)_observeOperation:(NSOperation *)operation;

#endif // END #ifdef DEBUG

@end


@implementation VMPythonRemoteSourceDownloader

- (void)dealloc
{
  if (self.downloadingOperationQueue) {
    [self.downloadingOperationQueue cancelAllOperations];
  }
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

#pragma mark - Private

- (void)_observeOperation:(NSOperation *)operation
{
  if (!self.operationsInfo) {
    self.operationsInfo = [NSMutableDictionary dictionary];
  }
  
  NSString *identifier = [[NSUUID UUID] UUIDString];
  operation.name = identifier;
//  _operationsInfo[identifier] = [NSMutableDictionary dictionaryWithObject:...
//                                                                   forKey:...];
  
  [operation addObserver:self forKeyPath:kYNOperationPropertyOfIsExecuting_ options:NSKeyValueObservingOptionNew context:NULL];
  [operation addObserver:self forKeyPath:kYNOperationPropertyOfIsFinished_  options:NSKeyValueObservingOptionNew context:NULL];
  [operation addObserver:self forKeyPath:kYNOperationPropertyOfIsCancelled_ options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)_unobserveOperation:(NSOperation *)operation
{
  [operation removeObserver:self forKeyPath:kYNOperationPropertyOfIsExecuting_];
  [operation removeObserver:self forKeyPath:kYNOperationPropertyOfIsFinished_];
  [operation removeObserver:self forKeyPath:kYNOperationPropertyOfIsCancelled_];
}

#pragma mark - NSKeyValueObserving Protocol

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary <NSString *, id> *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:kYNOperationPropertyOfIsExecuting_]) {
    // The `isExecuting` will be 1 when operation starts, and will be 0 when it ends (and `isFinished` will be 1 at same time).
    //   What we care is when it starts, so compare the `new` value w/ 1 here.
    if (1 == [change[NSKeyValueChangeNewKey] intValue]) {
      NSString *operationIdentifier = [object valueForKey:kYNOperationPropertyOfName_];
      NSLog(@"* > Start Executing Operation: \"%@\".", operationIdentifier);
      
      if (self.delegate && [self.delegate respondsToSelector:@selector(vm_pythonRemoteSourceDownloaderDidStartTaskWithIdentifier:)]) {
        [self.delegate vm_pythonRemoteSourceDownloaderDidStartTaskWithIdentifier:operationIdentifier];
      }
    }
    
  } else if ([keyPath isEqualToString:kYNOperationPropertyOfIsFinished_] ||
             [keyPath isEqualToString:kYNOperationPropertyOfIsCancelled_])
  {
    NSString *operationIdentifier = [object valueForKey:kYNOperationPropertyOfName_];
    
    NSLog(@"* < Operation: \"%@\" is %@.", operationIdentifier, ([keyPath isEqualToString:kYNOperationPropertyOfIsFinished_] ? @"Finished" : @"Cancelled"));
    [_operationsInfo removeObjectForKey:operationIdentifier];
    
    [self _unobserveOperation:(NSOperation *)object];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(vm_pythonRemoteSourceDownloaderDidEndTaskWithIdentifier:errorMessage:)]) {
      [self.delegate vm_pythonRemoteSourceDownloaderDidEndTaskWithIdentifier:operationIdentifier errorMessage:nil];
    }
  }
}

#pragma mark - Public (Python Related)

- (void)setupWithSavePath:(NSString *)savePath cacheJSONFile:(BOOL)cacheJSONFile inDebugMode:(BOOL)debugMode
{
  NSLog(@"[VMPythonRemoteSourceDownloader]: Downloaded sources will be stored at: %@", savePath);
  [self.pythonVideoMemosModule setupWithSavePath:savePath cacheJSONFile:cacheJSONFile inDebugMode:debugMode];
}

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonVideoMemosModuleRemoteSourceCheckingCompletion)completion
{
  [self.pythonVideoMemosModule checkWithURLString:urlString completion:completion];
}

- (void)downloadWithURLString:(NSString *)urlString
                     inFormat:(NSString *)format
                        title:(NSString *)title
                     progress:(VMPythonVideoMemosModuleDownloadingProgress)progress
                   completion:(VMPythonVideoMemosModuleDownloadingCompletion)completion
{
  if (!self.downloadingOperationQueue) {
    self.downloadingOperationQueue = [[NSOperationQueue alloc] init];
    self.downloadingOperationQueue.maxConcurrentOperationCount = 1;
  }
  // Set `suspended=YES` if want to pause temporary.
  //self.downloadingOperationQueue.suspended = YES;
  
  VMPythonDownloadingOperation *operation = [[VMPythonDownloadingOperation alloc] initWithURLString:urlString
                                                                                           inFormat:format
                                                                                              title:title
                                                                             pythonVideoMemosModule:self.pythonVideoMemosModule];
  [self.downloadingOperationQueue addOperation:operation];
}

- (void)downloadWithSourceItem:(VMRemoteSourceModel *)sourceItem
                    optionItem:(VMRemoteSourceOptionModel *)optionItem
                      progress:(VMPythonVideoMemosModuleDownloadingProgress)progress
                    completion:(VMPythonVideoMemosModuleDownloadingCompletion)completion
{
  [self downloadWithURLString:sourceItem.urlString inFormat:optionItem.format title:sourceItem.title progress:progress completion:completion];
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

- (void)enqueueDownloadingTask:(VMPythonDownloadingOperation *)task
{
  if (!self.taskRef) {
    self.taskRef = [NSMutableDictionary dictionary];
  }
  
  if (nil == self.taskRef[task.urlString]) {
    self.taskRef[task.urlString] = task;
  }
}*/

@end
