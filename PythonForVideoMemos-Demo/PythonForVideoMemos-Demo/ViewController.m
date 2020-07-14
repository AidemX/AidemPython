//
//  ViewController.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "ViewController.h"

#import "VMPythonCommon.h"
#import "Constants.h"
// View
#import "TableViewDownloadingCell.h"
// Lib
#import "VMPythonResourceDownloader.h"
#import "VMWebResourceModel.h"


static NSString * const kVideosFolderName_ = @"videos";

static CGFloat const kActionButtonHeight_ = 44.f;


@interface ViewController () <
  UITableViewDataSource,
  UITableViewDelegate,
  TableViewDownloadingCellDelegate,
  VMPythonResourceDownloaderDelegate
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton    *suspendOrResumeAllButton;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong, nullable) VMWebResourceModel *resourceItem;

@property (nonatomic, strong, nullable) VMWebResourceOptionModel *currentDownloadingItem;
@property (nonatomic, strong, nullable) TableViewDownloadingCell *currentDownloadingCell;

#ifdef DEBUG

- (void)_refreshSuspendOrResumeAllButton;
- (void)_didPressSuspendOrResumeAllButton;

- (void)_presentAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

#endif // END #ifdef DEBUG

@end


@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor systemBackgroundColor];
  
  _tableView = ({
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.opaque = YES;
    tableView.scrollEnabled = YES;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.bounces = YES;
    tableView.backgroundView = nil;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    // TableView Footer (empty view here to hide separators between empty cells).
    tableView.sectionFooterHeight = 0;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    
    tableView;
  });
  
  _suspendOrResumeAllButton = [UIButton buttonWithType:UIButtonTypeSystem];
  _suspendOrResumeAllButton.backgroundColor = [UIColor secondarySystemBackgroundColor];
  _suspendOrResumeAllButton.layer.cornerRadius = 5.f;
  [_suspendOrResumeAllButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
  [_suspendOrResumeAllButton addTarget:self action:@selector(_didPressSuspendOrResumeAllButton) forControlEvents:UIControlEventTouchUpInside];
  [self _refreshSuspendOrResumeAllButton];
  _suspendOrResumeAllButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_suspendOrResumeAllButton];
  
  [NSLayoutConstraint activateConstraints:
   @[[_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
     [_tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
     [_tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
     [_tableView.bottomAnchor constraintEqualToAnchor:_suspendOrResumeAllButton.topAnchor constant:-15.f],
     
     [_suspendOrResumeAllButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:15.f],
     [_suspendOrResumeAllButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-15.f],
     [_suspendOrResumeAllButton.heightAnchor constraintEqualToConstant:kActionButtonHeight_],
     [_suspendOrResumeAllButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
   ]];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  NSString *documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
  NSString *savePath = [documentsDirectoryPath stringByAppendingPathComponent:kVideosFolderName_];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:savePath]) {
    [fileManager createDirectoryAtPath:savePath withIntermediateDirectories:NO attributes:nil error:NULL];
  }
  VMPythonResourceDownloader *downloader = [VMPythonResourceDownloader sharedInstance];
  downloader.savePath      = savePath;
  downloader.cacheJSONFile = YES;
  downloader.debugMode     = YES;
  downloader.delegate = self;
  
  self.urlString = @"https://www.bilibili.com/video/BV1kW411p7B3";
  
  /*/ Test downloading progress
  [downloader debug_downloadWithURLString:self.urlString
                                 progress:^(float progress) {
    VMPythonLogDebug(@"Get progress: %f", progress);
  } completion:^(NSString * _Nullable errorMessage) {
    VMPythonLogDebug(@"Did complete downloading, error: %@", errorMessage);
  }];
  return;
   */
  
  // Download directly w/ default format
  //[[VMPythonResourceDownloader sharedInstance] py_downloadWithURLString:self.urlString inFormat:nil];
  //[[VMPythonResourceDownloader sharedInstance] py_downloadWithURLString:self.urlString inFormat:@"dash-flv360"];
  //return;
  
  // Check source w/ URL
  typeof(self) __weak weakSelf = self;
  [downloader checkWithURLString:self.urlString completion:^(VMWebResourceModel *resourceItem, NSString *errorMessage) {
    if (nil == errorMessage) {
      VMPythonLogDebug(@"Got sourceItem.options: %@", resourceItem.options);
      weakSelf.resourceItem = resourceItem;
      [weakSelf.tableView reloadData];
    } else {
      [weakSelf _presentAlertWithTitle:nil message:errorMessage];
    }
  }];
}

#pragma mark - Private

- (void)_refreshSuspendOrResumeAllButton
{
  NSString *title = ([VMPythonResourceDownloader sharedInstance].suspended ? @"Resume Downloading Queue" : @"Suspend Downloading Queue");
  [_suspendOrResumeAllButton setTitle:title forState:UIControlStateNormal];
}

- (void)_didPressSuspendOrResumeAllButton
{
  BOOL suspended = ![VMPythonResourceDownloader sharedInstance].isSuspended;
  [VMPythonResourceDownloader sharedInstance].suspended = suspended;
  
  [self _refreshSuspendOrResumeAllButton];
}

- (void)_presentAlertWithTitle:(NSString *)title message:(NSString *)message
{
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:(title ?: @"Alert")
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
  [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil]];
  [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

// Asks the data source to return the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

// Tells the data source to return the number of rows in a given section of a table view. (required)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.resourceItem.options count];
}

// Asks the data source for a cell to insert in a particular location of the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString * const cellIdentifier = @"cell";
  
  VMWebResourceOptionModel *item = self.resourceItem.options[indexPath.row];
  if (self.currentDownloadingItem == item) {
    return self.currentDownloadingCell;
    
  } else {
    TableViewDownloadingCell *cell = (TableViewDownloadingCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
      cell = [[TableViewDownloadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
      cell.delegate = self;
    }
    
    cell.nameLabel.text = item.qualityText;
    cell.infoLabel.text = [NSString stringWithFormat:@"%@, %@", item.mediaTypeText, item.sizeText];
    cell.downloadProcessButton.status   = item.status;
    cell.downloadProcessButton.progress = item.progress;
    
    return cell;
  }
}

#pragma mark - UITableViewDelegate

// Tells the delegate the table view is about to draw a cell for a particular row.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  // In autolayout, cell's subview layout will be displayed animated, let's rm the animation
  [UIView performWithoutAnimation:^{
    [cell layoutIfNeeded];
  }];
}

// Asks the delegate for the height to use for a row in a specified location.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return kTableViewCellHeight;
}

// Tells the delegate that the specified row is now selected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  VMWebResourceOptionModel *item = self.resourceItem.options[indexPath.row];
  //[_downloader downloadWithURLString:self.urlString inFormat:item.format];
  NSString *taskIdentifier = [[VMPythonResourceDownloader sharedInstance] downloadWithResourceItem:self.resourceItem
                                                                                        optionItem:item
                                                                                     preferredName:nil
                                                                                          userInfo:nil];
  item.taskIdentifier = taskIdentifier;
  item.status = kVMPythonDownloadProcessStatusOfWaiting;
}

#pragma mark - TableViewDownloadingCellDelegate

- (void)didPressDownloadProcessButtonOnTableViewDownloadingCell:(TableViewDownloadingCell *)cell
{
  NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
  if (nil == indexPath) {
    return;
  }
  VMWebResourceOptionModel *item = self.resourceItem.options[indexPath.row];
  if (kVMPythonDownloadProcessStatusOfWaiting == item.status || kVMPythonDownloadProcessStatusOfDownloading == item.status) {
    [[VMPythonResourceDownloader sharedInstance] pauseTaskWithIdentifier:item.taskIdentifier];
    // Pausing downloading task will make it end, so let's reset the `taskIdentifier`.
    //   And when resume the task, will create a new task instead.
    if (kVMPythonDownloadProcessStatusOfDownloading == item.status) {
      item.taskIdentifier = nil;
    }
    cell.downloadProcessButton.status =
    item.status = kVMPythonDownloadProcessStatusOfPaused;
    
  } else if (kVMPythonDownloadProcessStatusOfPaused == item.status || kVMPythonDownloadProcessStatusOfDownloadFailed == item.status) {
    cell.downloadProcessButton.status =
    item.status = kVMPythonDownloadProcessStatusOfWaiting;
    
    if (item.taskIdentifier) {
      [[VMPythonResourceDownloader sharedInstance] resumeTaskWithIdentifier:item.taskIdentifier];
    } else {
      NSString *taskIdentifier = [[VMPythonResourceDownloader sharedInstance] downloadWithResourceItem:self.resourceItem
                                                                                            optionItem:item
                                                                                         preferredName:nil
                                                                                              userInfo:nil];
      item.taskIdentifier = taskIdentifier;
    }
  }
}

#pragma mark - VMPythonResourceDownloaderDelegate

- (void)vm_pythonResourceDownloaderDidStartTaskWithIdentifier:(NSString *)taskIdentifier totalFileSize:(uint64_t)totalFileSize userInfo:(NSDictionary *)userInfo
{
  VMPythonLogDebug(@"Got Callback from VMPythonResourceDownloader\n  - Start Task (Identifier: %@)", taskIdentifier);
  
  NSInteger row;
  VMWebResourceOptionModel *item = [self.resourceItem matchedOptionAtRow:&row withTaskIdentifier:taskIdentifier];
  if (item) {
    item.status = kVMPythonDownloadProcessStatusOfDownloading;
    self.currentDownloadingItem = item;
    dispatch_async(dispatch_get_main_queue(), ^{
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
      self.currentDownloadingCell = [self.tableView cellForRowAtIndexPath:indexPath];
      self.currentDownloadingCell.downloadProcessButton.status   = item.status;
      self.currentDownloadingCell.downloadProcessButton.progress = item.progress;
    });
  }
}

- (void)vm_pythonResourceDownloaderDidUpdateTaskWithIdentifier:(NSString *)taskIdentifier receivedFileSize:(uint64_t)receivedFileSize
{
  float progress = (float)receivedFileSize / (float)self.currentDownloadingItem.size;
  VMPythonLogDebug(@"Got Callback from VMPythonResourceDownloader\n  - - Task (Identifier: %@) receivedFileSize: %lld (progress: %f)",
                   taskIdentifier, receivedFileSize, progress);
  self.currentDownloadingItem.progress = progress;
  self.currentDownloadingCell.downloadProcessButton.progress = progress;
}

- (void)vm_pythonResourceDownloaderDidEndTaskWithIdentifier:(NSString *)taskIdentifier userInfo:(NSDictionary *)userInfo errorMessage:(NSString *)errorMessage
{
  VMPythonLogDebug(@"Got Callback from VMPythonResourceDownloader\n  - End Task (Identifier: %@) - errorMessage: %@", taskIdentifier, errorMessage);
  
  VMWebResourceOptionModel *item;
  NSInteger row = NSNotFound;
  
  if (self.currentDownloadingItem) {
    if (self.currentDownloadingItem.taskIdentifier && [self.currentDownloadingItem.taskIdentifier isEqualToString:taskIdentifier]) {
      item = self.currentDownloadingItem;
      row = [self.resourceItem.options indexOfObject:item];
    }
    self.currentDownloadingItem = nil;
  }
  self.currentDownloadingCell = nil;
  
  if (nil == item) {
    item = [self.resourceItem matchedOptionAtRow:&row withTaskIdentifier:taskIdentifier];
  }
  
  if (errorMessage) {
    if (item) {
      item.taskIdentifier = nil;
      item.status = kVMPythonDownloadProcessStatusOfDownloadFailed;
      item.progress = 0.f;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _presentAlertWithTitle:nil message:errorMessage];
    });
    
  } else {
    if (item) {
      item.taskIdentifier = nil;
      item.status = kVMPythonDownloadProcessStatusOfDownloadSucceeded;
    }
  }
  
  if (NSNotFound != row) {
    dispatch_async(dispatch_get_main_queue(), ^{
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
      [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
  }
}

@end
