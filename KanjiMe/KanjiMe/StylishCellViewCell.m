//
//  StylishCellViewCell.m
//  KanjiMe
//
//  Created by Lion User on 5/27/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "StylishCellViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UtilHelper.h"

@interface  StylishCellViewCell()
@property (nonatomic) BOOL isNotFirtRun;
@property (strong, nonatomic) IBOutlet UIImageView *btnLike;
@property (strong, nonatomic) IBOutlet UILabel *badgeLabel;


@end

@implementation StylishCellViewCell
@synthesize titleLabel, subTitleLabel, bgImageView, disclosureImageView, isNotFirtRun, btnLike, badgeLabel;


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
        [self.bgImageView setImage:nil];
        [self.bgImageView setBackgroundColor:CELLS_BACK_COLOR];
        
        [disclosureImageView setImage:[UIImage tallImageNamed:@"ipad-arrow.png"]];
        [titleLabel setTextColor:[UIColor darkTextColor]];
        [titleLabel setShadowColor:[UIColor whiteColor]];
        [subTitleLabel setTextColor:[UIColor darkGrayColor]];
        
    }
    
    [super setSelected:selected animated:animated];
}

- (void)awakeFromNib
{
    [self.bgImageView.layer setCornerRadius:5.0];
    [self.btnLike.layer setCornerRadius:5.0];
    [self.badgeLabel.layer setCornerRadius:5.0];
    self.like = NO;
    [titleLabel setShadowOffset:CGSizeMake(0, -1)];
}

- (void)setNewItem:(BOOL)newItem
{
    _newItem = newItem;
//    if(newItem){
//        [self.bgImageView setBackgroundColor:CELLS_NEW_COLOR];
//    } else {
//        [self.bgImageView setBackgroundColor:CELLS_BACK_COLOR];
//        
//    }
    [self.badgeLabel setHidden:!newItem];
}


- (void)setLike:(BOOL)like
{
    _like = like;
    if(like){
        [self.btnLike setHighlighted:YES];
        
    }else{
        [self.btnLike setHighlighted:NO];
    }        
}



@end
