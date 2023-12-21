//
//  VMVideoNAudioMerger.h
//  AidemPythonDemo
//
//  Created by Kjuly on 17/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef void (^VMVideoNAudioMergerCompletion)(NSString *_Nullable mergedFilePath, NSString *_Nullable mergingErrorMessage);

@interface VMVideoNAudioMerger : NSObject

/**
 * Merge video & audio files
 *
 * @param identifier The unique filename, generally, same to VMPythonResourceDownloader's `preferredName`.
 * @param folderPath The path to folder that hosts video & audio files, and also, the merged file will be exporeted there.
 * @param completion The bloack to execute when completed.
 */
//+ (void)mergeVideoNAudioFilesWithIdentifier:(NSString *)identifier
//                               atFolderPath:(NSString *)folderPath
//                                 completion:(VMVideoNAudioMergerCompletion)completion;

/**
 * Merge video & audio files
 *
 * @param filenames           The video & audio filenames
 * @param folderPath          The path to folder that hosts video & audio files, and also, the merged file will be exporeted there.
 * @param preferredResultName The preferred merging result filename
 * @param completion          The bloack to execute when completed.
 */
+ (void)mergeVideoNAudioFiles:(NSArray <NSString *> *)filenames
                 atFolderPath:(NSString *)folderPath
          preferredResultName:(NSString *)preferredResultName
                   completion:(VMVideoNAudioMergerCompletion)completion;

//+ (void)mergeVideoFileAtPath:(NSString *)videoFilePath
//         withAudioFileAtPath:(NSString *)audioFilePath
//              intoResultPath:(NSString *)resultPath
//                  completion:(VMVideoNAudioMergerCompletion)completion;

@end

NS_ASSUME_NONNULL_END
