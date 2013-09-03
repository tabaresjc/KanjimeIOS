//
//  FeedCell4.m
//  ADVFlatUI
//
//  Created by Tope on 03/06/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "FeedCell4.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeedCell4

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.lineOne = [[UILabel alloc] init];
        self.lineTwo = [[UILabel alloc] init];
        self.kanjiLabel = [[UILabel alloc] init];
        self.feedContainer = [[UIView alloc] init];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)awakeFromNib{
    self.feedContainer.backgroundColor = [UIColor whiteColor];    
    self.feedContainer.layer.cornerRadius = 3.0f;
    self.feedContainer.clipsToBounds = YES;    
    self.kanjiLabel.layer.cornerRadius = 3.0f;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
