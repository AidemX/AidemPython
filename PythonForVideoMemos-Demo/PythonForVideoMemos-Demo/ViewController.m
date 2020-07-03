//
//  ViewController.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "ViewController.h"

#import "VMPythonCommon.h"
// Lib
#import "VMPythonRemoteSourceDownloader.h"
#import "VMRemoteSourceDownloader.h"
#import "VMRemoteSourceModel.h"


static NSString * const kVideosFolderName_ = @"videos";

static CGFloat const kActionButtonHeight_ = 44.f;


@interface ViewController () <
  UITableViewDataSource,
  UITableViewDelegate,
  VMPythonRemoteSourceDownloaderDelegate
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton    *pauseOrResumeCurrentButton;
@property (nonatomic, strong) UIButton    *suspendOrResumeAllButton;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong, nullable) VMRemoteSourceModel *sourceItem;

@property (nonatomic, strong, nullable) VMRemoteSourceOptionModel *selectedItem;
@property (nonatomic, copy,   nullable) NSString *currentTaskIdentifier;

#ifdef DEBUG

- (void)_refreshPauseOrResumeCurrentButton;
- (void)_didPressPauseOrResumeCurrentButton;

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
  
  _pauseOrResumeCurrentButton = [UIButton buttonWithType:UIButtonTypeSystem];
  _pauseOrResumeCurrentButton.backgroundColor = [UIColor secondarySystemBackgroundColor];
  _pauseOrResumeCurrentButton.layer.cornerRadius = 5.f;
  [_pauseOrResumeCurrentButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
  [_pauseOrResumeCurrentButton setTitle:@"Pause Current" forState:UIControlStateNormal];
  [_pauseOrResumeCurrentButton addTarget:self action:@selector(_didPressPauseOrResumeCurrentButton) forControlEvents:UIControlEventTouchUpInside];
  _pauseOrResumeCurrentButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_pauseOrResumeCurrentButton];
  
  _suspendOrResumeAllButton = [UIButton buttonWithType:UIButtonTypeSystem];
  _suspendOrResumeAllButton.backgroundColor = [UIColor secondarySystemBackgroundColor];
  _suspendOrResumeAllButton.layer.cornerRadius = 5.f;
  [_suspendOrResumeAllButton setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
  [_suspendOrResumeAllButton setTitle:@"Suspend All" forState:UIControlStateNormal];
  [_suspendOrResumeAllButton addTarget:self action:@selector(_didPressSuspendOrResumeAllButton) forControlEvents:UIControlEventTouchUpInside];
  _suspendOrResumeAllButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_suspendOrResumeAllButton];
  
  [NSLayoutConstraint activateConstraints:
   @[[_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
     [_tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
     [_tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
     [_tableView.bottomAnchor constraintEqualToAnchor:_pauseOrResumeCurrentButton.topAnchor constant:-15.f],
     
     [_pauseOrResumeCurrentButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:15.f],
     [_pauseOrResumeCurrentButton.rightAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:-5.f],
     [_pauseOrResumeCurrentButton.heightAnchor constraintEqualToConstant:kActionButtonHeight_],
     [_pauseOrResumeCurrentButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
     
     [_suspendOrResumeAllButton.leftAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:5.f],
     [_suspendOrResumeAllButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-15.f],
     [_suspendOrResumeAllButton.heightAnchor constraintEqualToConstant:kActionButtonHeight_],
     [_suspendOrResumeAllButton.bottomAnchor constraintEqualToAnchor:_pauseOrResumeCurrentButton.bottomAnchor]
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
  VMPythonRemoteSourceDownloader *downloader = [VMPythonRemoteSourceDownloader sharedInstance];
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
  //[[VMPythonRemoteSourceDownloader sharedInstance] py_downloadWithURLString:self.urlString inFormat:nil];
  //[[VMPythonRemoteSourceDownloader sharedInstance] py_downloadWithURLString:self.urlString inFormat:@"dash-flv360"];
  //return;
  
  // Check source w/ URL
  typeof(self) __weak weakSelf = self;
  [downloader checkWithURLString:self.urlString completion:^(VMRemoteSourceModel *sourceItem, NSString *errorMessage) {
    if (nil == errorMessage) {
      VMPythonLogDebug(@"Got sourceItem.options: %@", sourceItem.options);
      weakSelf.sourceItem = sourceItem;
      [weakSelf.tableView reloadData];
    } else {
      [weakSelf _presentAlertWithTitle:nil message:errorMessage];
    }
  }];
}

#pragma mark - Private

- (void)_refreshPauseOrResumeCurrentButton
{
  NSString *title;
  if (nil == self.selectedItem) {
    _pauseOrResumeCurrentButton.enabled = NO;
    title = @"Pause Current";
  } else {
    _pauseOrResumeCurrentButton.enabled = YES;
    title = (nil == self.currentTaskIdentifier ? @"Resume Current" : @"Pause Current");
  }
  [_pauseOrResumeCurrentButton setTitle:title forState:UIControlStateNormal];
}

- (void)_didPressPauseOrResumeCurrentButton
{
  if (nil == self.currentTaskIdentifier) {
    if (nil == self.selectedItem) {
      [self _presentAlertWithTitle:nil message:@"No selected item to resume task, please select one."];
    } else {
      self.currentTaskIdentifier = [[VMPythonRemoteSourceDownloader sharedInstance] downloadWithSourceItem:self.sourceItem optionItem:self.selectedItem];
    }
  } else {
    [[VMPythonRemoteSourceDownloader sharedInstance] pauseTaskWithIdentifier:self.currentTaskIdentifier];
    self.currentTaskIdentifier = nil;
  }
  [self _refreshPauseOrResumeCurrentButton];
}

- (void)_refreshSuspendOrResumeAllButton
{
  NSString *title = ([VMPythonRemoteSourceDownloader sharedInstance].suspended ? @"Resume All" : @"Suspend All");
  [_suspendOrResumeAllButton setTitle:title forState:UIControlStateNormal];
}

- (void)_didPressSuspendOrResumeAllButton
{
  BOOL suspended = ![VMPythonRemoteSourceDownloader sharedInstance].isSuspended;
  [VMPythonRemoteSourceDownloader sharedInstance].suspended = suspended;
  
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
  return [self.sourceItem.options count];
}

// Asks the data source for a cell to insert in a particular location of the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString * const cellIdentifier = @"cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    cell.contentView.backgroundColor = [UIColor systemBackgroundColor];
    cell.textLabel.textColor       = [UIColor labelColor];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
  }
  
  VMRemoteSourceOptionModel *item = self.sourceItem.options[indexPath.row];
  cell.textLabel.text = item.qualityText;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", item.mediaTypeText, item.sizeText];
  
  return cell;
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
  return UITableViewAutomaticDimension;
}

// Tells the delegate that the specified row is now selected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.selectedItem = self.sourceItem.options[indexPath.row];
  //[_downloader downloadWithURLString:self.urlString inFormat:item.format];
  self.currentTaskIdentifier = [[VMPythonRemoteSourceDownloader sharedInstance] downloadWithSourceItem:self.sourceItem optionItem:self.selectedItem];
  
  /*
  if (nil == [VMRemoteSourceDownloader sharedInstance].baseSavePathURL) {
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *baseSavePathURL = [documentsDirectoryURL URLByAppendingPathComponent:kVideosFolderName_];
    [VMRemoteSourceDownloader sharedInstance].baseSavePathURL = baseSavePathURL;
    [VMRemoteSourceDownloader sharedInstance].debugMode = debugMode;
  }
  [[VMRemoteSourceDownloader sharedInstance] downloadWithSourceItem:self.sourceItem optionItem:item];
   */
}

#pragma mark - VMPythonRemoteSourceDownloaderDelegate

- (void)vm_pythonRemoteSourceDownloaderDidStartTaskWithIdentifier:(NSString *)taskIdentifier
{
  VMPythonLogDebug(@"Got Callback from VMPythonRemoteSourceDownloader\n  - Start Task (Identifier: %@)", taskIdentifier);
}

- (void)vm_pythonRemoteSourceDownloaderDidUpdateTaskWithIdentifier:(NSString *)taskIdentifier progress:(float)progress
{
  VMPythonLogDebug(@"Got Callback from VMPythonRemoteSourceDownloader\n  - - Task (Identifier: %@) progress: %f", taskIdentifier, progress);
}

- (void)vm_pythonRemoteSourceDownloaderDidEndTaskWithIdentifier:(NSString *)taskIdentifier errorMessage:(NSString *)errorMessage
{
  VMPythonLogDebug(@"Got Callback from VMPythonRemoteSourceDownloader\n  - End Task (Identifier: %@) - errorMessage: %@", taskIdentifier, errorMessage);
  
  if (errorMessage) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self _presentAlertWithTitle:nil message:errorMessage];
    });
  }
}

@end
