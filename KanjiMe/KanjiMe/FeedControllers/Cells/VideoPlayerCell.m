//
//  VideoPlayerCell.m
//  KanjiMe
//
//  Created by Juan Tabares on 1/26/14.
//  Copyright (c) 2014 LearnJapanese123. All rights reserved.
//

#import "VideoPlayerCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UtilHelper.h"

@interface VideoPlayerCell()

@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@end

@implementation VideoPlayerCell
@synthesize urlVideo;

- (MPMoviePlayerController *)videoPlayer
{
    if(!_videoPlayer){
        _videoPlayer = [[MPMoviePlayerController alloc] init];
    }
    return _videoPlayer;
}

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

- (IBAction)playVideo:(id)sender {
    NSURL *movieURL = [NSURL URLWithString:self.urlVideo];
    [self.videoPlayer setContentURL:movieURL];
    [self.videoPlayer prepareToPlay];
    if([UtilHelper isVersion6AndBelow]) {
        [self.videoPlayer.view setFrame: self.superview.bounds];
        [self.superview addSubview:self.videoPlayer.view];
    } else {
        [self.videoPlayer.view setFrame: self.superview.superview.bounds];
        [self.superview.superview addSubview:self.videoPlayer.view];
    }    
    [self.videoPlayer play];
}
@end
