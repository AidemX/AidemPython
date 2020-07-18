//
//  VMVideoNAudioMerger.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 17/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef void (^VMVideoNAudioMergerCompletion)(NSString *_Nullable savedPath, NSString *_Nullable errorMessage);

@interface VMVideoNAudioMerger : NSObject

+ (void)mergeVideoFileAtPath:(NSString *)videoFilePath
         withAudioFileAtPath:(NSString *)audioFilePath
              intoResultPath:(NSString *)resultPath
                  completion:(VMVideoNAudioMergerCompletion)completion;

@end

NS_ASSUME_NONNULL_END
