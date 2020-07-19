//
//  VMVideoNAudioMerger.m
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 17/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "VMVideoNAudioMerger.h"

#import "VMPythonCommon.h"
// Model
#import "VMTrackMergingAsset.h"
// Lib
//@import AVFoundation;
@import CoreServices.UTType;


static NSString * const kVMVideoNAudioMergerAVURLAssetPropertyOfDuration_ = @"duration";
static NSString * const kVMVideoNAudioMergerAVURLAssetPropertyOfTracks_   = @"tracks";


#ifdef DEBUG

@interface VMVideoNAudioMerger ()

+ (void)_mergeWithTrackMergingAssets:(NSArray <VMTrackMergingAsset *> *)trackMergingAssets
                      withFolderPath:(NSString *)folderPath
                 preferredResultName:(NSString *)preferredResultName
                          completion:(VMVideoNAudioMergerCompletion)completion;

@end

#endif // END #ifdef DEBUG


@implementation VMVideoNAudioMerger

#pragma mark - Private

+ (void)_mergeWithTrackMergingAssets:(NSArray <VMTrackMergingAsset *> *)trackMergingAssets
                      withFolderPath:(NSString *)folderPath
                 preferredResultName:(NSString *)preferredResultName
                          completion:(VMVideoNAudioMergerCompletion)completion
{
  AVMutableComposition *mixComposition = [AVMutableComposition composition];
  BOOL videoTrackMerged = NO;
  BOOL audioTrackMerged = NO;
  for (VMTrackMergingAsset *asset in trackMergingAssets) {
    if (videoTrackMerged && audioTrackMerged) {
      break;
    }
    
    if ((videoTrackMerged && AVMediaTypeVideo == asset.interestedTrackMediaType) ||
        (audioTrackMerged && AVMediaTypeAudio == asset.interestedTrackMediaType))
    {
      continue;
    }
    NSError *error = nil;
    AVMutableCompositionTrack *compositionTrack = [mixComposition addMutableTrackWithMediaType:asset.interestedTrackMediaType preferredTrackID:kCMPersistentTrackID_Invalid];
    if ([compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:asset.interestedTrack atTime:kCMTimeZero error:&error]) {
      if (AVMediaTypeVideo == asset.interestedTrackMediaType) videoTrackMerged = YES;
      else                                                    audioTrackMerged = YES;
    } else {
      VMPythonLogError(@"%@", [error localizedDescription]);
    }
  }
  
  // Export merged file
  AVFileType outputFileType = AVFileTypeMPEG4;
  NSString *extension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef _Nonnull)(outputFileType), kUTTagClassFilenameExtension));
  NSString *mergedFilename = [preferredResultName stringByAppendingPathExtension:extension];
  NSString *mergedFilePath = [folderPath stringByAppendingPathComponent:mergedFilename];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:mergedFilePath]) {
    [fileManager removeItemAtPath:mergedFilePath error:nil];
  }
  
  // Export Merged File to `resultPath`
  AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
  exportSession.outputFileType = outputFileType;
  exportSession.outputURL = [NSURL fileURLWithPath:mergedFilePath];
  
  [exportSession exportAsynchronouslyWithCompletionHandler:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      switch (exportSession.status) {
        case AVAssetExportSessionStatusCompleted: {
          VMPythonLogSuccess(@"exportSession Completed");
          completion(mergedFilePath, nil);
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

#pragma mark - Public

/*
+ (void)mergeVideoNAudioFilesWithIdentifier:(NSString *)identifier
                               atFolderPath:(NSString *)folderPath
                                 completion:(VMVideoNAudioMergerCompletion)completion {}
 */

+ (void)mergeVideoNAudioFiles:(NSArray <NSString *> *)filenames
                 atFolderPath:(NSString *)folderPath
          preferredResultName:(NSString *)preferredResultName
                   completion:(VMVideoNAudioMergerCompletion)completion
{
  NSMutableArray <VMTrackMergingAsset *> *trackMergingAssets = [NSMutableArray array];
  
  NSUInteger         countOfTotalAssets  = [filenames count];
  NSUInteger __block countOfLoadedAssets = 0;
  BOOL       __block startMerging = NO;
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *requiredAssetKeys = @[kVMVideoNAudioMergerAVURLAssetPropertyOfDuration_,
                                 kVMVideoNAudioMergerAVURLAssetPropertyOfTracks_];
  
  for (NSString *filename in filenames) {
    NSString *filepath = [folderPath stringByAppendingPathComponent:filename];
    if (![fileManager fileExistsAtPath:filepath]) {
      --countOfTotalAssets;
      continue;
    }
    
    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    VMTrackMergingAsset *asset = [[VMTrackMergingAsset alloc] initWithURL:fileURL options:nil];
    [asset loadValuesAsynchronouslyForKeys:requiredAssetKeys completionHandler:^{
      if (startMerging) {
        return;
      }
      ++countOfLoadedAssets;
      
      NSError *error = nil;
      AVKeyValueStatus durationValueStatus = [asset statusOfValueForKey:kVMVideoNAudioMergerAVURLAssetPropertyOfDuration_ error:&error];
      if (AVKeyValueStatusLoaded == durationValueStatus) {
        AVKeyValueStatus tracksValueStatus = [asset statusOfValueForKey:kVMVideoNAudioMergerAVURLAssetPropertyOfTracks_ error:&error];
        if (AVKeyValueStatusLoaded == tracksValueStatus) {
          AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
          if (videoTrack) {
            asset.interestedTrackMediaType = AVMediaTypeVideo;
            asset.interestedTrack          = videoTrack;
            [trackMergingAssets insertObject:asset atIndex:0];
          }
          
          AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
          if (audioTrack) {
            asset.interestedTrackMediaType = AVMediaTypeAudio;
            asset.interestedTrack          = audioTrack;
            [trackMergingAssets addObject:asset];
          }
          
        } else if (AVKeyValueStatusFailed == tracksValueStatus) {
          VMPythonLogError(@"%@", [error localizedDescription]);
        }
      } else if (AVKeyValueStatusFailed == durationValueStatus) {
        VMPythonLogError(@"%@", [error localizedDescription]);
      }
      
      if (countOfLoadedAssets >= countOfTotalAssets) {
        startMerging = YES;
        [self _mergeWithTrackMergingAssets:trackMergingAssets withFolderPath:folderPath preferredResultName:preferredResultName completion:completion];
      }
    }];
  }
}

/*
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
  AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
  NSError *error = nil;
  AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
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
  AVAssetTrack *audioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
  AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
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
}*/

@end
