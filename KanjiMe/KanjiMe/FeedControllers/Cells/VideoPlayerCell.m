//
//  VideoPlayerCell.m
//  KanjiMe
//
//  Created by Lion User on 1/26/14.
//  Copyright (c) 2014 LearnJapanese123. All rights reserved.
//

#import "VideoPlayerCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UtilHelper.h"

@interface VideoPlayerCell()

@end

@implementation VideoPlayerCell
@synthesize bgView;

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
        self.bgView.backgroundColor = [UIColor whiteColor];
    } else {
        self.bgView.tintColor = [UIColor whiteColor];
    }
    
    self.bgView.layer.cornerRadius = 3.0f;
    self.bgView.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
