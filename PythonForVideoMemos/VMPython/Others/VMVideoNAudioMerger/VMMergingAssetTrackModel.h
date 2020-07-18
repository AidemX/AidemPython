//
//  VMMergingAssetTrackModel.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 18/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;
@import AVFoundation;


NS_ASSUME_NONNULL_BEGIN

@interface VMMergingAssetTrackModel : NSObject

@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, assign) AVMediaType   mediaType;
@property (nonatomic, strong) AVAssetTrack *track;
@property (nonatomic, assign) CMTime        duration;

@end

NS_ASSUME_NONNULL_END
