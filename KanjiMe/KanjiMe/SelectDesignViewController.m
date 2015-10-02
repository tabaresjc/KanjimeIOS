//
//  SelectDesignViewController.m
//  KanjiMe
//
//  Created by Lion User on 10/10/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "SelectDesignViewController.h"
#import "TattooSelectionCell.h"

@interface SelectDesignViewController ()

@end

@implementation SelectDesignViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"CheckOutView"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setSelection:)]){
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            [segue.destinationViewController performSelector:@selector(setSelection:)
                                                  withObject:indexPath];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TattooSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DesignCell" forIndexPath:indexPath];
    
    cell.TattooPlaceHolder.image = [UIImage tallImageNamed:[NSString stringWithFormat:@"image%d.png", indexPath.row+1]];
    cell.selectionNumberLabel.text = [NSString stringWithFormat:@"%d", indexPath.row+1];
    if((indexPath.row%2)==0){
        cell.contentView.backgroundColor = UIColorFromRGBWithAlpha(0xf0f0f0, 1);
    } else {
        cell.contentView.backgroundColor = UIColorFromRGBWithAlpha(0xffffff, 1);
    }
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *headerTitleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    
    
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width - 10, 30)];
    sectionTitleLabel.textColor = [UIColor blackColor];
    sectionTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleView.backgroundColor = [UIColor lightGrayColor];
    sectionTitleLabel.text = @"Please select one design for your tattoo";
    sectionTitleLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:17];
    [sectionTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [headerTitleView addSubview:sectionTitleLabel];
    
    return headerTitleView;
}


@end
