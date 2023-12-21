//
//  VMTrackMergingAsset.h
//  AidemPythonDemo
//
//  Created by Kjuly on 18/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import Foundation;
@import AVFoundation;


NS_ASSUME_NONNULL_BEGIN

@interface VMTrackMergingAsset : AVURLAsset

@property (nonatomic, assign) AVMediaType   interestedTrackMediaType;
@property (nonatomic, strong) AVAssetTrack *interestedTrack;

@end

NS_ASSUME_NONNULL_END
