//
//  StylishCellViewCell.h
//  KanjiMe
//
//  Created by Lion User on 5/27/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StylishCellViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (nonatomic) BOOL like;


@end
