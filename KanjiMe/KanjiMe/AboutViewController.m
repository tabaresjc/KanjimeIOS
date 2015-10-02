//
//  AboutViewController.m
//  KanjiMe
//
//  Created by Lion User on 10/10/13.
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
                urlString = @"https://itunes.apple.com/us/app/travelers-japanese/id447519027?mt=8";
                titleString = @"Traveler's Japanese";
            } else if(indexPath.section==3){
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
            } else if(indexPath.section==4){
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
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section==3){
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
    if(section>=0 && section<=4){
       return 30.0f;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/travelers-japanese/id447519027"]];
    } else if(indexPath.section==3 || indexPath.section==4) {
        [self performSegueWithIdentifier: @"SendUrl" sender:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/travelers-japanese/id447519027?mt=8"]];
    } else if(indexPath.section==3 || indexPath.section==4) {
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
    } else if(indexPath.section==2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"LinkCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Traveler's Japanese";
        cell.imageView.image = [UIImage tallImageNamed:@"traveler_japanese_48.png"];
    } else if(indexPath.section==3){
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
            cell.imageView.image = [UIImage tallImageNamed:@"learnjapanese_logo_48.png"];
        }
    } else if(indexPath.section==4){
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell" forIndexPath:indexPath];
        cell.textLabel.text = @"name";
        cell.detailTextLabel.text = @"name@email.com";
        cell.imageView.image = [UIImage tallImageNamed:@"linkedin_color_48.png"];
    } else if(indexPath.section==5){
        cell = [tableView dequeueReusableCellWithIdentifier:@"FooterCell" forIndexPath:indexPath];
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *titleText = @"";

    if(section==0){
        titleText = @"KanjiMe iOS";
    } else if(section==1){
        titleText = @"Content Provided By";
    } else if (section==2){
        titleText = @"Apps";
    } else if (section==3){
        titleText = @"Links";
    } else if (section==4){
        titleText = @"Developed By";
    } else {
        return nil;
    }

    UIImageView *headerTitleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];


    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width - 10, 25)];
    sectionTitleLabel.textColor = [UIColor whiteColor];
    sectionTitleLabel.backgroundColor = [UIColor clearColor];
    headerTitleView.backgroundColor = [UIColor lightGrayColor];
    sectionTitleLabel.text = titleText;
    sectionTitleLabel.font = [UIFont fontWithName:@"MyriadPro-BoldCond" size:20];
    [sectionTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [headerTitleView addSubview:sectionTitleLabel];

    return headerTitleView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 40.0f;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (IBAction)cancelDialog:(UIStoryboardSegue *)segue
{

}

@end
