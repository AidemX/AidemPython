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

@interface ViewController ()

@property (nonatomic, strong) VMPythonRemoteSourceDownloader *downloader;

@end


@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Do any additional setup after loading the view.
  
  NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
  _downloader = [[VMPythonRemoteSourceDownloader alloc] initWithSavePath:docPath];
  // Check
  [_downloader checkWithURLString:@"https://www.bilibili.com/video/BV1kW411p7B3"];
  // Download
  //[_downloader downloadWithURLString:@"https://www.bilibili.com/video/BV1kW411p7B3"];
}


@end
