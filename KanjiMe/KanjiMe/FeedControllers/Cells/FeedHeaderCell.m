//
//  FeedHeaderCell.m
//  KanjiMe
//
//  Created by Lion User on 9/7/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "FeedHeaderCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilHelper.h"

@implementation FeedHeaderCell
@synthesize titleLabel, subTitleLabel, likeButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)awakeFromNib{
    if ([UtilHelper isVersion6AndBelow]) {
        self.headerContainer.backgroundColor = [UIColor whiteColor];
    } else {
        self.headerContainer.tintColor = [UIColor whiteColor];
    }
    
    self.headerContainer.layer.cornerRadius = 3.0f;
    self.headerContainer.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.likeButton.layer.cornerRadius = 4.0f;
}


@end
