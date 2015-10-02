//
//  TattooSelectionCell.m
//  KanjiMe
//
//  Created by Lion User on 10/10/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "TattooSelectionCell.h"

@implementation TattooSelectionCell
@synthesize TattooPlaceHolder, selectionNumberLabel;

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

@end
