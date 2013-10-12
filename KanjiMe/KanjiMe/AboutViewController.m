//
//  AboutViewController.m
//  KanjiMe
//
//  Created by Juan Tabares on 10/10/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    if ([[segue identifier] isEqualToString:@"SendUrl"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setUrlToWebView:withTitle:)]){
            NSIndexPath *indexPath = (NSIndexPath *)sender;            
            
            NSString *urlString = @"http://www.learnjapanese123.com/";
            NSString *titleString = @"LearnJapanese123";
            
            if(indexPath.section==2){
                if(indexPath.row == 0) {
                    urlString = @"https://www.facebook.com/Japanese.Language.Culture";
                    titleString = @"Facebook Fan Page";
                } else if(indexPath.row == 1) {
                    urlString = @"https://twitter.com/japanese123";
                    titleString = @"Twitter Feed";
                } else if(indexPath.row == 2) {
                    urlString = @"http://www.youtube.com/user/10minsJapanese";
                    titleString = @"Youtube Channel";
                }
            } else if(indexPath.section==3){
                urlString = @"http://www.linkedin.com/in/juanctt";
                titleString = @"Linkedin";
            }
            
            [segue.destinationViewController performSelector:@selector(setUrlToWebView:withTitle:)
                                                  withObject:urlString
                                                  withObject:titleString];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section==2){
        return 4;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        return 90.0f;
    } else {
        return 50.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==1 || section==2 || section==3){
       return 35.0f;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2 || indexPath.section==3) {
        [self performSegueWithIdentifier: @"SendUrl" sender:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(indexPath.section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
    } else if(indexPath.section==1){
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Kazue Kaneko";
        cell.detailTextLabel.text = @"www.learnjapanese123.com";
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else if(indexPath.section==3){
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Juan Tabares";
        cell.detailTextLabel.text = @"juan.ctt@live.com";
        cell.imageView.image = [UIImage tallImageNamed:@"linkedin_color_48.png"];
    } else if(indexPath.section==4){
        cell = [tableView dequeueReusableCellWithIdentifier:@"FooterCell" forIndexPath:indexPath];
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LinkCell" forIndexPath:indexPath];
        
        if(indexPath.row==0){
            cell.textLabel.text = @"Facebook Fan Page";
            cell.imageView.image = [UIImage tallImageNamed:@"facebook_color_48.png"];
        } else if(indexPath.row==1){
            cell.textLabel.text = @"Twitter feed";
            cell.imageView.image = [UIImage tallImageNamed:@"twitter_color_48.png"];
        } else if(indexPath.row==2){
            cell.textLabel.text = @"Youtube Channel";
            cell.imageView.image = [UIImage tallImageNamed:@"youtube_color_48.png"];
        } else if(indexPath.row==3){
            cell.textLabel.text = @"LearnJapanese123";
            cell.imageView.image = [UIImage tallImageNamed:@"learnjapaneselogo_48.png"];
        }
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *titleText = @"";
    
    if(section==1){
        titleText = @"Content Provided By";
    } else if (section==2){
        titleText = @"Links";
    } else if (section==3){
        titleText = @"Developed By";
    } else {
        return nil;
    }
    
    UIImageView *headerTitleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
    
    
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width - 10, 30)];
    sectionTitleLabel.textColor = [UIColor blackColor];
    sectionTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleView.backgroundColor = [UIColor lightGrayColor];
    sectionTitleLabel.text = titleText;
    sectionTitleLabel.font = [UIFont fontWithName:@"MyriadPro-Cond" size:17];
    [sectionTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [headerTitleView addSubview:sectionTitleLabel];
    
    return headerTitleView;
}

@end
