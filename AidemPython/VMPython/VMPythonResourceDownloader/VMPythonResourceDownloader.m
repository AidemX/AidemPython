//
//  VMPythonResourceDownloader.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonResourceDownloader.h"

#define VMPYTHON_ENABLED_ 1

#import "VMPythonCommon.h"
// Model
#ifdef VMPYTHON_ENABLED_
  #import "VMPythonAidemModule.h"
#endif // END #ifdef VMPYTHON_ENABLED_
#import "VMWebResourceModel.h"
#import "VMPythonDownloadOperation.h"


@interface VMPythonResourceDownloader ()

@property (nonatomic, strong) VMPythonAidemModule *pythonVideoMemosModule;

@property (nonatomic, strong) NSOperationQueue *downloadingOperationQueue;

/**
 * The path of a unique progress file that reflect current downloading operation progress.
 *
 * @discussion
 * Whenever a new operation starts, will make sure this file created, and it'll be deleted
 *   once completed downloading.
 *
 * Note:
 *
 * If this progress file deleted during downloading, the downloading process will be paused.
 * The downloading code snippet keeps checking its existence, refer to
 *
 *   site_packages/you-get/src/you_get/common.py: if not os.path.exists(vm_tmp_progress_filepath)
 */
@property (nonatomic, copy) NSString *progressFilePath;

@property (nonatomic, strong, nullable) NSCharacterSet *invalidFilenameCharacterSet;

#ifdef DEBUG

- (NSString *)_validFilenameFromName:(NSString *)name;
- (NSString *)_filenameFromURLString:(NSString *)urlString;
- (VMWebResourceModel *)_newWebResourceItemFromJSON:(NSDictionary *)json withURLString:(NSString *)urlString;

- (void)_observeOperation:(NSOperation *)operation;

#endif // END #ifdef DEBUG

@end


@implementation VMPythonResourceDownloader

- (void)dealloc
{
  if (_downloadingOperationQueue) {
    [_downloadingOperationQueue cancelAllOperations];
  }
}

+ (instancetype)sharedInstance
{
  static VMPythonResourceDownloader *_sharedVMPythonResourceDownloader = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedVMPythonResourceDownloader = [[VMPythonResourceDownloader alloc] init];
  });
  
  return _sharedVMPythonResourceDownloader;
}

- (instancetype)init
{
  if (self = [super init]) {
#ifdef VMPYTHON_ENABLED_
    _pythonVideoMemosModule = [[VMPythonAidemModule alloc] init];
#endif // END #ifdef VMPYTHON_ENABLED_
  }
  return self;
}

#pragma mark - Getter

- (NSOperationQueue *)downloadingOperationQueue
{
  if (!_downloadingOperationQueue) {
    _downloadingOperationQueue = [[NSOperationQueue alloc] init];
    _downloadingOperationQueue.maxConcurrentOperationCount = 1;
    _downloadingOperationQueue.suspended = self.suspended;
    _downloadingOperationQueue.qualityOfService = NSQualityOfServiceUtility;
  }
  // Set `suspended=YES` if want to pause all operations temporary.
  //self.downloadingOperationQueue.suspended = YES;
  return _downloadingOperationQueue;
}

- (NSCharacterSet *)invalidFilenameCharacterSet
{
  if (!_invalidFilenameCharacterSet) {
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@":/"];
    [characterSet formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
    [characterSet formUnionWithCharacterSet:[NSCharacterSet illegalCharacterSet]];
    [characterSet formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
    _invalidFilenameCharacterSet = characterSet;
  }
  return _invalidFilenameCharacterSet;
}

#pragma mark - Private

- (NSString *)_validFilenameFromName:(NSString *)name
{
  if (nil == name) {
    return @"";
  } else {
    return [[name componentsSeparatedByCharactersInSet:self.invalidFilenameCharacterSet] componentsJoinedByString:@"_"];
  }
}

- (NSString *)_filenameFromURLString:(NSString *)urlString
{
  if (urlString == nil) {
    return @"_";
  }
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9_]+" options:0 error:nil];
  return [regex stringByReplacingMatchesInString:urlString options:0 range:NSMakeRange(0, urlString.length) withTemplate:@"_"];
}

- (VMWebResourceModel *)_newWebResourceItemFromJSON:(NSDictionary *)json withURLString:(NSString *)urlString
{
  VMWebResourceModel *resourceItem = [[VMWebResourceModel alloc] init];
  resourceItem.title     = json[@"title"];
  resourceItem.site      = json[@"site"];
  resourceItem.urlString = urlString;// `json[@"url"]` might be null, e.g. "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"
  
  resourceItem.userAgent = json[@"ua"];
  resourceItem.referer   = json[@"referer"];
  
  NSDictionary *streams = json[@"streams"];
  if (nil != streams && [streams isKindOfClass:[NSDictionary class]]) {
    NSMutableArray<VMWebResourceOptionModel *> *options = [NSMutableArray array];
    for (NSString *key in [streams allKeys]) {
      VMWebResourceOptionModel *option = [VMWebResourceOptionModel newWithKey:key andValue:streams[key]];
      [options addObject:option];
    }
    resourceItem.options = options;
  }
  
  return resourceItem;
}

- (void)_observeOperation:(NSOperation *)operation
{
  [operation addObserver:self forKeyPath:kVMPythonDownloadOperationPropertyOfIsExecuting options:NSKeyValueObservingOptionNew context:NULL];
  [operation addObserver:self forKeyPath:kVMPythonDownloadOperationPropertyOfIsFinished  options:NSKeyValueObservingOptionNew context:NULL];
  [operation addObserver:self forKeyPath:kVMPythonDownloadOperationPropertyOfIsCancelled options:NSKeyValueObservingOptionNew context:NULL];
  [operation addObserver:self forKeyPath:kVMPythonDownloadOperationPropertyOfReceivedFileSize options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)_unobserveOperation:(NSOperation *)operation
{
  [operation removeObserver:self forKeyPath:kVMPythonDownloadOperationPropertyOfIsExecuting];
  [operation removeObserver:self forKeyPath:kVMPythonDownloadOperationPropertyOfIsFinished];
  [operation removeObserver:self forKeyPath:kVMPythonDownloadOperationPropertyOfIsCancelled];
  [operation removeObserver:self forKeyPath:kVMPythonDownloadOperationPropertyOfReceivedFileSize];
}

#pragma mark - NSKeyValueObserving Protocol

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *, id> *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:kVMPythonDownloadOperationPropertyOfReceivedFileSize]) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(vm_pythonResourceDownloaderDidUpdateTaskWithIdentifier:receivedFileSize:)]) {
      NSString *operationIdentifier = [object valueForKey:kVMPythonDownloadOperationPropertyOfName];
      uint64_t receivedFileSize = [change[NSKeyValueChangeNewKey] unsignedLongLongValue];
      [self.delegate vm_pythonResourceDownloaderDidUpdateTaskWithIdentifier:operationIdentifier receivedFileSize:receivedFileSize];
    }
    
  } else if ([keyPath isEqualToString:kVMPythonDownloadOperationPropertyOfIsExecuting]) {
    // The `isExecuting` will be 1 when operation starts, and will be 0 when it ends (and `isFinished` will be 1 at same time).
    //   What we care is when it starts, so compare the `new` value w/ 1 here.
    if (1 == [change[NSKeyValueChangeNewKey] intValue]) {
      NSString *operationIdentifier = [object valueForKey:kVMPythonDownloadOperationPropertyOfName];
      VMPythonLogNotice(@"* > Start Executing Operation: \"%@\".", operationIdentifier);
      
      if (self.delegate && [self.delegate respondsToSelector:@selector(vm_pythonResourceDownloaderDidStartTaskWithIdentifier:totalFileSize:userInfo:)]) {
        VMPythonDownloadOperation *operation = (VMPythonDownloadOperation *)object;
        [self.delegate vm_pythonResourceDownloaderDidStartTaskWithIdentifier:operationIdentifier
                                                               totalFileSize:operation.totalFileSize
                                                                    userInfo:operation.userInfo];
      }
    }
    
  } else if ([keyPath isEqualToString:kVMPythonDownloadOperationPropertyOfIsFinished] ||
             [keyPath isEqualToString:kVMPythonDownloadOperationPropertyOfIsCancelled])
  {
    NSString *operationIdentifier = [object valueForKey:kVMPythonDownloadOperationPropertyOfName];
    
    VMPythonLogNotice(@"* < Operation: \"%@\" is %@.", operationIdentifier,
                      ([keyPath isEqualToString:kVMPythonDownloadOperationPropertyOfIsFinished] ? @"Finished" : @"Cancelled"));
    
    [self _unobserveOperation:(NSOperation *)object];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(vm_pythonResourceDownloaderDidEndTaskWithIdentifier:userInfo:errorMessage:)]) {
      [self.delegate vm_pythonResourceDownloaderDidEndTaskWithIdentifier:operationIdentifier
                                                                userInfo:((VMPythonDownloadOperation *)object).userInfo
                                                            errorMessage:nil];
    }
  }
}

#pragma mark - Setter

- (void)setSavePath:(NSString *)savePath
{
  VMPythonLogNotice(@"[VMPythonResourceDownloader]: Downloaded sources will be stored at: %@", savePath);
  
  _savePath = savePath;
  
#ifdef VMPYTHON_ENABLED_
  self.progressFilePath = [savePath stringByAppendingPathComponent:kVMPythonAidemModuleProgressFileName];
  
  self.pythonVideoMemosModule.savePath = savePath;
#endif // END #ifdef VMPYTHON_ENABLED_
}

- (void)setDebugMode:(BOOL)debugMode
{
  _debugMode = debugMode;
  
#ifdef VMPYTHON_ENABLED_
  self.pythonVideoMemosModule.debugMode = debugMode;
#endif // END #ifdef VMPYTHON_ENABLED_
}

- (void)setSuspended:(BOOL)suspended
{
  _suspended = suspended;
  
  self.downloadingOperationQueue.suspended = self.suspended;
}

#pragma mark - Public

- (void)fetchInfoWithURLString:(NSString *)urlString completion:(VMPythonResourceDownloaderFetchInfoCompletion)completion
{
  NSString *jsonPath;
  
  // Let's use cached json file if it exists.
  if (self.cacheJSONFile) {
    NSString *filename = [self _filenameFromURLString:urlString];
    jsonPath = [self.savePath stringByAppendingPathComponent:[filename stringByAppendingPathExtension:@"json"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:jsonPath]) {
      NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
      NSError *error = nil;
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
      if (error) {
        // Can't parse the json file, let's rm it & reload from web.
        [fileManager removeItemAtPath:jsonPath error:NULL];
        
      } else {
        VMPythonLogNotice(@"\nGot cached JSON file at %@", jsonPath);
        completion(json, nil);
        
        return;
      }
    }
  }
  
#ifdef VMPYTHON_ENABLED_
  typeof(self) __weak weakSelf = self;
  [self.pythonVideoMemosModule checkWithURLString:urlString completion:^(NSString *jsonString, NSString *errorMessage) {
    if (errorMessage) {
      completion(nil, errorMessage);
      
    } else {
      NSError *error = nil;
      NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
      if (error) {
        errorMessage = [NSString stringWithFormat:@"Parsing JSON failed: %@\nThe String to Parse: %@", [error localizedDescription], jsonString];
        completion(nil, errorMessage);
        
      } else {
        VMPythonLogDebug(@"Parsed JSON Dict: %@", json);
        if (weakSelf.cacheJSONFile && jsonPath) {
          [jsonString writeToFile:jsonPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        completion(json, nil);
      }
    }
  }];
#endif // END #ifdef VMPYTHON_ENABLED_
}

- (void)fetchTitleWithURLString:(NSString *)urlString completion:(VMPythonResourceDownloaderFetchTitleCompletion)completion
{
  [self fetchInfoWithURLString:urlString completion:^(NSDictionary *json, NSString *errorMessage) {
    if (errorMessage) {
      completion(nil, errorMessage);
    } else {
      NSString *title = json[@"title"];
      completion(title, nil);
    }
  }];
}

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonResourceDownloaderResourceCheckingCompletion)completion
{
  [self fetchInfoWithURLString:urlString completion:^(NSDictionary *json, NSString *errorMessage) {
    if (errorMessage) {
      completion(nil, errorMessage);
    } else {
      VMWebResourceModel *resourceItem = [self _newWebResourceItemFromJSON:json withURLString:urlString];
      completion(resourceItem, nil);
    }
  }];
}

- (NSString *)downloadWithURLString:(NSString *)urlString
                           inFormat:(NSString *)format
                      totalFileSize:(uint64_t)totalFileSize
                      preferredName:(NSString *)preferredName
                           userInfo:(NSDictionary *)userInfo
{
  VMPythonDownloadOperation *operation = [[VMPythonDownloadOperation alloc] initWithURLString:urlString
                                                                                     inFormat:format
                                                                                totalFileSize:totalFileSize
                                                                                preferredName:preferredName
                                                                                     userInfo:userInfo
                                                                       pythonVideoMemosModule:self.pythonVideoMemosModule
                                                                             progressFilePath:self.progressFilePath];
  [self _observeOperation:operation];
  [self.downloadingOperationQueue addOperation:operation];
  
  return operation.name;
}

- (NSString *)downloadWithResourceItem:(VMWebResourceModel *)resourceItem
                            optionItem:(VMWebResourceOptionModel *)optionItem
                         preferredName:(NSString *)preferredName
                              userInfo:(NSDictionary *)userInfo
{
  if (nil == preferredName) {
    preferredName = [self _validFilenameFromName:resourceItem.title];
    if (nil != optionItem.format) {
      preferredName = [preferredName stringByAppendingFormat:@" - %@", optionItem.format];
    }
  }
  return [self downloadWithURLString:resourceItem.urlString
                            inFormat:optionItem.format
                       totalFileSize:optionItem.size
                       preferredName:preferredName
                            userInfo:userInfo];
}

#pragma mark - Public (Task Management)

- (VMDownloadOperationStatus)statusOfTaskWithIdentifier:(NSString *)taskIdentifier
{
  VMDownloadOperationStatus status = kVMDownloadOperationStatusNone;
  for (NSOperation *operation in self.downloadingOperationQueue.operations) {
    if ([operation.name isEqualToString:taskIdentifier]) {
      if      (operation.isCancelled) status = kVMDownloadOperationStatusOfCancelled;
      else if (operation.isExecuting) status = kVMDownloadOperationStatusOfExecuting;
      else if (operation.isFinished)  status = kVMDownloadOperationStatusOfFinished;
      else                            status = kVMDownloadOperationStatusOfWaiting;
      break;
    }
  }
  return status;
}

/*
- (void)resumeTaskWithIdentifier:(NSString *)taskIdentifier
{
  for (VMPythonDownloadOperation *operation in self.downloadingOperationQueue.operations) {
    if ([operation.name isEqualToString:taskIdentifier]) {
      [operation resume];
      break;
    }
  }
}*/

- (void)pauseTaskWithIdentifier:(NSString *)taskIdentifier
{
  VMPythonDownloadOperation *matchedOperation = nil;
  for (VMPythonDownloadOperation *operation in self.downloadingOperationQueue.operations) {
    if ([operation.name isEqualToString:taskIdentifier]) {
      matchedOperation = operation;
      break;
    }
  }
  
  if (matchedOperation) {
    [matchedOperation cancel];
  }
}

- (void)stopTaskWithIdentifier:(NSString *)taskIdentifier
{
  [self pauseTaskWithIdentifier:taskIdentifier];
  
  // Clean cached files
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *filenames = [fileManager contentsOfDirectoryAtPath:self.savePath error:NULL];
  NSString *searchFilename = [taskIdentifier stringByAppendingString:@"."];
  for (NSString *filename in filenames) {
    if ([filename hasPrefix:searchFilename]) {
      NSString *filePath = [self.savePath stringByAppendingPathComponent:filename];
      NSError *error = nil;
      if (![fileManager removeItemAtPath:filePath error:&error]) {
        VMPythonLogError(@"Failed to rm cached file at %@", filePath);
      }
      break;
    }
  }
}

#pragma mark - Public (Clean)

- (void)cleanCachedJSONFileWithURLString:(NSString *)urlString
{
  NSString *filename = [self _filenameFromURLString:urlString];
  NSString *jsonPath = [self.savePath stringByAppendingPathComponent:[filename stringByAppendingPathExtension:@"json"]];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:jsonPath]) {
    [fileManager removeItemAtPath:jsonPath error:NULL];
    VMPythonLogNotice(@"Cleaned Cached JSON File w/ URL: %@", urlString);
  }
}

@end
