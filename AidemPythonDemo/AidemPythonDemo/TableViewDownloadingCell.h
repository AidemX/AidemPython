//
//  TableViewDownloadingCell.h
//  AidemPythonDemo
//
//  Created by Kjuly on 3/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

@import UIKit;

// View
#import "VMPythonDownloadProcessButton.h"


NS_ASSUME_NONNULL_BEGIN

@protocol TableViewDownloadingCellDelegate;


@interface TableViewDownloadingCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) VMPythonDownloadProcessButton *downloadProcessButton;

@property (nonatomic, weak) id <TableViewDownloadingCellDelegate> delegate;

@end


@protocol TableViewDownloadingCellDelegate <NSObject>

@required
- (void)didPressDownloadProcessButtonOnTableViewDownloadingCell:(TableViewDownloadingCell *)cell;

@end

NS_ASSUME_NONNULL_END
