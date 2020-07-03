//
//  TableViewDownloadingCell.h
//  PythonForVideoMemos-Demo
//
//  Created by Kjuly on 3/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import UIKit;

// View
#import "VMDownloadProcessButton.h"


NS_ASSUME_NONNULL_BEGIN

@interface TableViewDownloadingCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) VMDownloadProcessButton *downloadProcessButton;

@end

NS_ASSUME_NONNULL_END
