//
//  VMPythonResourceDownloader.m
//  PythonForVideoMemos
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMPythonResourceDownloader.h"

#import "VMPythonCommon.h"
// Model
#import "VMPythonVideoMemosModule.h"
#import "VMRemoteResourceModel.h"
#import "VMPythonDownloadingOperation.h"


@interface VMPythonResourceDownloader ()

@property (nonatomic, strong) VMPythonVideoMemosModule *pythonVideoMemosModule;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSDictionary *> *operationsInfo;
@property (nonatomic, strong) NSOperationQueue *downloadingOperationQueue;

/**
 * The path of an unique progress file that reflect current downloading operation progress.
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
- (VMRemoteResourceModel *)_newRemoteResourceItemFromJSON:(NSDictionary *)json;

- (void)_observeOperation:(NSOperation *)operation;

#endif // END #ifdef DEBUG

@end


@implementation VMPythonResourceDownloader

- (void)dealloc
{
  if (self.downloadingOperationQueue) {
    [self.downloadingOperationQueue cancelAllOperations];
  }
}

+ (instancetype)sharedInstance
{
  static VMPythonResourceDownloader *_sharedVMPythonRemoteResourceDownloader = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedVMPythonRemoteResourceDownloader = [[VMPythonResourceDownloader alloc] init];
  });
  
  return _sharedVMPythonRemoteResourceDownloader;
}

- (instancetype)init
{
  if (self = [super init]) {
    _pythonVideoMemosModule = [[VMPythonVideoMemosModule alloc] init];
  }
  return self;
}

#pragma mark - Getter

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
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9_]+" options:0 error:nil];
  return [regex stringByReplacingMatchesInString:urlString options:0 range:NSMakeRange(0, urlString.length) withTemplate:@"_"];
}

- (VMRemoteResourceModel *)_newRemoteResourceItemFromJSON:(NSDictionary *)json
{
  VMRemoteResourceModel *sourceItem = [[VMRemoteResourceModel alloc] init];
  sourceItem.title     = json[@"title"];
  sourceItem.site      = json[@"site"];
  sourceItem.urlString = json[@"url"];
  
  sourceItem.userAgent = json[@"ua"];
  sourceItem.referer   = json[@"referer"];
  
  NSDictionary *streams = json[@"streams"];
  if (nil != streams && [streams isKindOfClass:[NSDictionary class]]) {
    NSMutableArray <VMRemoteResourceOptionModel *> *options = [NSMutableArray array];
    for (NSString *key in [streams allKeys]) {
      VMRemoteResourceOptionModel *option = [VMRemoteResourceOptionModel newWithKey:key andValue:streams[key]];
      [options addObject:option];
    }
    sourceItem.options = options;
  }
  
  return sourceItem;
}

- (void)_observeOperation:(NSOperation *)operation
{
  if (!self.operationsInfo) {
    self.operationsInfo = [NSMutableDictionary dictionary];
  }
  
  NSString *identifier = [[NSUUID UUID] UUIDString];
  operation.name = identifier;
//  _operationsInfo[identifier] = [NSMutableDictionary dictionaryWithObject:...
//                                                                   forKey:...];
  
  [operation addObserver:self forKeyPath:kVMPythonDownloadingOperationPropertyOfIsExecuting options:NSKeyValueObservingOptionNew context:NULL];
  [operation addObserver:self forKeyPath:kVMPythonDownloadingOperationPropertyOfIsFinished  options:NSKeyValueObservingOptionNew context:NULL];
  [operation addObserver:self forKeyPath:kVMPythonDownloadingOperationPropertyOfIsCancelled options:NSKeyValueObservingOptionNew context:NULL];
  [operation addObserver:self forKeyPath:kVMPythonDownloadingOperationPropertyOfProgress options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)_unobserveOperation:(NSOperation *)operation
{
  [operation removeObserver:self forKeyPath:kVMPythonDownloadingOperationPropertyOfIsExecuting];
  [operation removeObserver:self forKeyPath:kVMPythonDownloadingOperationPropertyOfIsFinished];
  [operation removeObserver:self forKeyPath:kVMPythonDownloadingOperationPropertyOfIsCancelled];
  [operation removeObserver:self forKeyPath:kVMPythonDownloadingOperationPropertyOfProgress];
}

#pragma mark - NSKeyValueObserving Protocol

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary <NSString *, id> *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:kVMPythonDownloadingOperationPropertyOfProgress]) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(vm_pythonRemoteResourceDownloaderDidUpdateTaskWithIdentifier:progress:)]) {
      NSString *operationIdentifier = [object valueForKey:kVMPythonDownloadingOperationPropertyOfName];
      float progress = [change[NSKeyValueChangeNewKey] floatValue];
      [self.delegate vm_pythonRemoteResourceDownloaderDidUpdateTaskWithIdentifier:operationIdentifier progress:progress];
    }
    
  } else if ([keyPath isEqualToString:kVMPythonDownloadingOperationPropertyOfIsExecuting]) {
    // The `isExecuting` will be 1 when operation starts, and will be 0 when it ends (and `isFinished` will be 1 at same time).
    //   What we care is when it starts, so compare the `new` value w/ 1 here.
    if (1 == [change[NSKeyValueChangeNewKey] intValue]) {
      NSString *operationIdentifier = [object valueForKey:kVMPythonDownloadingOperationPropertyOfName];
      VMPythonLogNotice(@"* > Start Executing Operation: \"%@\".", operationIdentifier);
      
      if (self.delegate && [self.delegate respondsToSelector:@selector(vm_pythonRemoteResourceDownloaderDidStartTaskWithIdentifier:)]) {
        [self.delegate vm_pythonRemoteResourceDownloaderDidStartTaskWithIdentifier:operationIdentifier];
      }
    }
    
  } else if ([keyPath isEqualToString:kVMPythonDownloadingOperationPropertyOfIsFinished] ||
             [keyPath isEqualToString:kVMPythonDownloadingOperationPropertyOfIsCancelled])
  {
    NSString *operationIdentifier = [object valueForKey:kVMPythonDownloadingOperationPropertyOfName];
    
    VMPythonLogNotice(@"* < Operation: \"%@\" is %@.", operationIdentifier, ([keyPath isEqualToString:kVMPythonDownloadingOperationPropertyOfIsFinished] ? @"Finished" : @"Cancelled"));
    [_operationsInfo removeObjectForKey:operationIdentifier];
    
    [self _unobserveOperation:(NSOperation *)object];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(vm_pythonRemoteResourceDownloaderDidEndTaskWithIdentifier:errorMessage:)]) {
      [self.delegate vm_pythonRemoteResourceDownloaderDidEndTaskWithIdentifier:operationIdentifier errorMessage:nil];
    }
  }
}

#pragma mark - Setter

- (void)setSavePath:(NSString *)savePath
{
  VMPythonLogNotice(@"[VMPythonRemoteResourceDownloader]: Downloaded sources will be stored at: %@", savePath);
  
  _savePath = savePath;
  
  self.progressFilePath = [savePath stringByAppendingPathComponent:kVMPythonVideoMemosModuleProgressFileName];
  
  self.pythonVideoMemosModule.savePath = savePath;
}

- (void)setDebugMode:(BOOL)debugMode
{
  _debugMode = debugMode;
  
  self.pythonVideoMemosModule.debugMode = debugMode;
}

- (void)setSuspended:(BOOL)suspended
{
  _suspended = suspended;
  
  if (self.downloadingOperationQueue) {
    self.downloadingOperationQueue.suspended = self.suspended;
  }
  
  // Pause all operations if needed
  for (VMPythonDownloadingOperation *operation in self.downloadingOperationQueue.operations) {
    [operation pause];
  }
}

#pragma mark - Public

- (void)checkWithURLString:(NSString *)urlString completion:(VMPythonRemoteResourceDownloaderSourceCheckingCompletion)completion
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
        // Can't parse the json file, let's rm it & reload from remote.
        [fileManager removeItemAtPath:jsonPath error:NULL];
        
      } else {
        VMRemoteResourceModel *sourceItem = [self _newRemoteResourceItemFromJSON:json];
        VMPythonLogNotice(@"\nGot cached JSON file at %@", jsonPath);
        completion(sourceItem, nil);
        
        return;
      }
    }
  }
  
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
        VMRemoteResourceModel *sourceItem = [weakSelf _newRemoteResourceItemFromJSON:json];
        completion(sourceItem, nil);
      }
    }
  }];
}

- (NSString *)downloadWithURLString:(NSString *)urlString
                           inFormat:(NSString *)format
                      preferredName:(NSString *)preferredName
{
  if (!self.downloadingOperationQueue) {
    self.downloadingOperationQueue = [[NSOperationQueue alloc] init];
    self.downloadingOperationQueue.maxConcurrentOperationCount = 1;
    self.downloadingOperationQueue.suspended = self.suspended;
  }
  // Set `suspended=YES` if want to pause temporary.
  //self.downloadingOperationQueue.suspended = YES;
  
  VMPythonDownloadingOperation *operation = [[VMPythonDownloadingOperation alloc] initWithURLString:urlString
                                                                                           inFormat:format
                                                                                      preferredName:preferredName
                                                                             pythonVideoMemosModule:self.pythonVideoMemosModule
                                                                                   progressFilePath:self.progressFilePath];
  if (self.suspended) {
    [operation pause];
  }
  [self _observeOperation:operation];
  [self.downloadingOperationQueue addOperation:operation];
  
  return operation.name;
}

- (NSString *)downloadWithSourceItem:(VMRemoteResourceModel *)sourceItem
                          optionItem:(VMRemoteResourceOptionModel *)optionItem
                       preferredName:(NSString *)preferredName
{
  if (nil == preferredName) {
    preferredName = [self _validFilenameFromName:sourceItem.title];
    if (nil != optionItem.format) {
      preferredName = [preferredName stringByAppendingFormat:@" - %@", optionItem.format];
    }
  }
  return [self downloadWithURLString:sourceItem.urlString inFormat:optionItem.format preferredName:preferredName];
}

#pragma mark - Public (Task Management)

- (void)resumeTaskWithIdentifier:(NSString *)taskIdentifier
{
  for (VMPythonDownloadingOperation *operation in self.downloadingOperationQueue.operations) {
    if ([operation.name isEqualToString:taskIdentifier]) {
      [operation resume];
      break;
    }
  }
}

- (void)pauseTaskWithIdentifier:(NSString *)taskIdentifier
{
  VMPythonDownloadingOperation *matchedOperation = nil;
  for (VMPythonDownloadingOperation *operation in self.downloadingOperationQueue.operations) {
    if ([operation.name isEqualToString:taskIdentifier]) {
      matchedOperation = operation;
      break;
    }
  }
  
  if (matchedOperation) {
    [matchedOperation pause];
  }
}

@end
