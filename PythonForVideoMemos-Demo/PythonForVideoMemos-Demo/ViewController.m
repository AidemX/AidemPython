//
//  ViewController.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 25/6/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "ViewController.h"

// Lib
#import "VMPythonRemoteSourceDownloader.h"
#import "VMRemoteSourceDownloader.h"
#import "VMRemoteSourceModel.h"


static NSString * const kVideosFolderName_ = @"videos";


@interface ViewController () <
  UITableViewDataSource,
  UITableViewDelegate
>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong, nullable) VMRemoteSourceModel *sourceItem;

#ifdef DEBUG

- (void)_presentAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

#endif // END #ifdef DEBUG

@end


@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor blackColor];
  
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
  
  [NSLayoutConstraint activateConstraints:
   @[[_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
     [_tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
     [_tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
     [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
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
  [downloader setupWithSavePath:savePath cacheJSONFile:YES inDebugMode:YES];
  
  self.urlString = @"https://www.bilibili.com/video/BV1kW411p7B3";
  
  /*/ Test downloading progress
  [downloader debug_downloadWithURLString:self.urlString
                                 progress:^(float progress) {
    NSLog(@"Get progress: %f", progress);
  } completion:^(NSString * _Nullable errorMessage) {
    NSLog(@"Did complete downloading, error: %@", errorMessage);
  }];
  return;
   */
  
  // Download directly w/ default format
  //[[VMPythonRemoteSourceDownloader sharedInstance] py_downloadWithURLString:self.urlString inFormat:nil];
  //[[VMPythonRemoteSourceDownloader sharedInstance] py_downloadWithURLString:self.urlString inFormat:@"dash-flv360"];
  //return;
  
  // Check source w/ URL
  typeof(self) __weak weakSelf = self;
  [[VMPythonRemoteSourceDownloader sharedInstance] checkWithURLString:self.urlString completion:^(VMRemoteSourceModel *sourceItem, NSString *errorMessage) {
    if (nil == errorMessage) {
      weakSelf.sourceItem = sourceItem;
      [weakSelf.tableView reloadData];
    } else {
      [weakSelf _presentAlertWithTitle:nil message:errorMessage];
    }
  }];
}

#pragma mark - Private

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
  VMRemoteSourceOptionModel *item = self.sourceItem.options[indexPath.row];
  //[_downloader downloadWithURLString:self.urlString inFormat:item.format];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    VMPythonVideoMemosModuleDownloadingProgress progress = ^(float progress) {
      NSLog(@"Current progress: %f", progress);
    };
    
    VMPythonVideoMemosModuleDownloadingCompletion completion = ^(NSString *errorMessage) {
      if (errorMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self _presentAlertWithTitle:nil message:errorMessage];
        });
      } else {
        NSLog(@"Did complete downloading.");
      }
    };
    
    [[VMPythonRemoteSourceDownloader sharedInstance] downloadWithSourceItem:self.sourceItem
                                                                 optionItem:item
                                                                   progress:progress
                                                                 completion:completion];
  });
  
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

@end
