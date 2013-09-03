//
//  StylishCellViewCell.m
//  KanjiMe
//
//  Created by Lion User on 5/27/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "StylishCellViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface  StylishCellViewCell()
@property (nonatomic) BOOL isNotFirtRun;
@property (strong, nonatomic) IBOutlet UIImageView *btnLike;

@end

@implementation StylishCellViewCell
@synthesize titleLabel, subTitleLabel, bgImageView, disclosureImageView, isNotFirtRun, btnLike;

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
    if(selected)
    {
        [self.bgImageView setImage:[UIImage tallImageNamed:@"ipad-list-item-selected.png"]];
        [disclosureImageView setImage:[UIImage tallImageNamed:@"ipad-arrow-selected.png"]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
        [subTitleLabel setTextColor:[UIColor whiteColor]];        
    }
    else
    {
        [bgImageView setImage:nil];
        [self.bgImageView setBackgroundColor:UIColorFromRGB(0xfffffb)];
        [disclosureImageView setImage:[UIImage tallImageNamed:@"ipad-arrow.png"]];
        [titleLabel setTextColor:[UIColor darkTextColor]];
        [titleLabel setShadowColor:[UIColor whiteColor]];
        [subTitleLabel setTextColor:[UIColor darkGrayColor]];
        
    }
    
    [titleLabel setShadowOffset:CGSizeMake(0, -1)];
    
    if(!self.isNotFirtRun){
        CALayer *l1 = [bgImageView layer];
        [l1 setMasksToBounds:YES];
        [l1 setCornerRadius:5.0];
        
        CALayer *l2 = [btnLike layer];
        [l2 setMasksToBounds:YES];
        [l2 setCornerRadius:5.0];
        
        self.like = NO;
        self.isNotFirtRun = true;
    }
    [super setSelected:selected animated:animated];
}


- (void)setLike:(BOOL)like
{
    _like = like;
    if(like){
        //[self.btnLike setBackgroundColor:UIColorFromRGBWithAlpha(0xFFC125,0.6)];
        [self.btnLike setHighlighted:YES];
        
    }else{
        //[self.btnLike setBackgroundColor:UIColorFromRGBWithAlpha(0xfffffc,0.6)];
        [self.btnLike setHighlighted:NO];
    }        
}



@end