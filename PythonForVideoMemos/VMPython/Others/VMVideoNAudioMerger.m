//
//  VMVideoNAudioMerger.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 17/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMVideoNAudioMerger.h"

#import "VMPythonCommon.h"
// Lib
@import AVFoundation;


@implementation VMVideoNAudioMerger

#pragma mark - Public

+ (void)mergeVideoFileAtPath:(NSString *)videoFilePath
         withAudioFileAtPath:(NSString *)audioFilePath
              intoResultPath:(NSString *)resultPath
                  completion:(VMVideoNAudioMergerCompletion)completion
{
  AVMutableComposition *mixComposition = [AVMutableComposition composition];
  
  // Handle Video Track
  NSURL *videoFileURL = [NSURL fileURLWithPath:videoFilePath];
  AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoFileURL options:nil];
  CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
  
  VMPythonLogDebug(@"- videoAsset tracksWithMediaType:AVMediaTypeAudio: %@", [videoAsset tracksWithMediaType:AVMediaTypeAudio]);
  VMPythonLogDebug(@"- videoAsset tracksWithMediaType:AVMediaTypeVideo: %@", [videoAsset tracksWithMediaType:AVMediaTypeVideo]);
  AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
  AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
  NSError *error = nil;
  if (![compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:videoTrack atTime:kCMTimeZero error:&error]) {
    completion(nil, [error localizedDescription]);
    return;
  }
  
  // Handle Audio Track
  NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePath];
  AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioFileURL options:nil];
  CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
  
  VMPythonLogDebug(@"- audioAsset tracksWithMediaType:AVMediaTypeAudio: %@", [audioAsset tracksWithMediaType:AVMediaTypeAudio]);
  VMPythonLogDebug(@"- audioAsset tracksWithMediaType:AVMediaTypeVideo: %@", [audioAsset tracksWithMediaType:AVMediaTypeVideo]);
  AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
  AVAssetTrack *audioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
  if (![compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:audioTrack atTime:kCMTimeZero error:&error]) {
    completion(nil, [error localizedDescription]);
    return;
  }
  
  // Export Merged File to `resultPath`
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:resultPath]) {
    [fileManager removeItemAtPath:resultPath error:nil];
  }
  AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
  exportSession.outputFileType = AVFileTypeMPEG4;
  exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
  
  [exportSession exportAsynchronouslyWithCompletionHandler:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      switch (exportSession.status) {
        case AVAssetExportSessionStatusCompleted: {
          VMPythonLogSuccess(@"exportSession Completed");
          completion(resultPath, nil);
          break;
        }
          
        case AVAssetExportSessionStatusFailed: {
          VMPythonLogError(@"exportSession Failed: %@", exportSession.error);
          completion(nil, [exportSession.error localizedDescription]);
          break;
        }
          
        case AVAssetExportSessionStatusCancelled: {
          VMPythonLogWarn(@"exportSession Cancelled");
          completion(nil, nil);
          break;
        }
          
        case AVAssetExportSessionStatusUnknown:
        case AVAssetExportSessionStatusWaiting:
        case AVAssetExportSessionStatusExporting:
        default:
          VMPythonLogWarn(@"exportSession other status: %ld", (long)exportSession.status);
          completion(nil, nil);
          break;
      }
    });
  }];
}

@end
