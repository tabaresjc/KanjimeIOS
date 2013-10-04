//
//  FeedCell4.m
//  ADVFlatUI
//
//  Created by Tope on 03/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "FeedCell4.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilHelper.h"

@implementation FeedCell4

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

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
        self.feedContainer.backgroundColor = [UIColor whiteColor];
    } else {
        self.feedContainer.tintColor = [UIColor whiteColor];
    }
    
    self.feedContainer.layer.cornerRadius = 3.0f;
    self.feedContainer.clipsToBounds = YES;    
    self.kanjiLabel.layer.cornerRadius = 3.0f;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
