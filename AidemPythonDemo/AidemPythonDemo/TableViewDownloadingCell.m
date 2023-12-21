//
//  TableViewDownloadingCell.m
//  AidemPythonDemo
//
//  Created by Kjuly on 3/7/2020.
//  Copyright © 2020 Kjuly. All rights reserved.
//

#import "TableViewDownloadingCell.h"

#import "Constants.h"


@implementation TableViewDownloadingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *contentView = self.contentView;
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor labelColor];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_nameLabel];
    
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.textColor = [UIColor secondaryLabelColor];
    _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_infoLabel];
    
    CGSize size = CGSizeMake(kTableViewCellDownloadProcessButtonSizeLength, kTableViewCellDownloadProcessButtonSizeLength);
    _downloadProcessButton = [[VMPythonDownloadProcessButton alloc] initWithSize:size padding:kTableViewCellDownloadProcessButtonPadding tintColor:nil];
    [_downloadProcessButton addTarget:self action:@selector(_didPressDownloadProcessButton) forControlEvents:UIControlEventTouchUpInside];
    _downloadProcessButton.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_downloadProcessButton];
    
    [NSLayoutConstraint activateConstraints:
     @[[_nameLabel.leftAnchor constraintEqualToAnchor:contentView.leftAnchor constant:15.f],
       [_nameLabel.heightAnchor constraintEqualToConstant:kTableViewCellNameLabelHeight],
       [_nameLabel.bottomAnchor constraintEqualToAnchor:contentView.centerYAnchor],
       [_nameLabel.rightAnchor constraintEqualToAnchor:_downloadProcessButton.leftAnchor constant:-5.f],
       
       [_infoLabel.leftAnchor constraintEqualToAnchor:_nameLabel.leftAnchor],
       [_infoLabel.heightAnchor constraintEqualToConstant:kTableViewCellInfoLabelHeight],
       [_infoLabel.topAnchor constraintEqualToAnchor:contentView.centerYAnchor],
       [_infoLabel.rightAnchor constraintEqualToAnchor:_nameLabel.rightAnchor],
       
       [_downloadProcessButton.centerYAnchor constraintEqualToAnchor:contentView.centerYAnchor],
       [_downloadProcessButton.widthAnchor constraintEqualToConstant:kTableViewCellDownloadProcessButtonSizeLength],
       [_downloadProcessButton.heightAnchor constraintEqualToConstant:kTableViewCellDownloadProcessButtonSizeLength],
       [_downloadProcessButton.rightAnchor constraintEqualToAnchor:contentView.rightAnchor constant:-5.f],
     ]];
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

#pragma mark - Private

- (void)_didPressDownloadProcessButton
{
  [self.delegate didPressDownloadProcessButtonOnTableViewDownloadingCell:self];
}

@end
