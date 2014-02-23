//
//  FeedDetailViewController.m
//  KanjiMe
//
//  Created by Lion User on 8/29/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "FeedDetailViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RestApiHelpers.h"
#import "Collection+Rest.h"
#import "FeedCell4.h"
#import "VideoPlayerCell.h"
#import "FeedHeaderCell.h"
#import "MBProgressHUD.h"
#import "MainAppDelegate.h"
#import "UtilHelper.h"

@interface FeedDetailViewController ()

@property (strong,nonatomic) CoreDataHandler *coreDataRep;
@property (strong, nonatomic) NSArray *listOfNames;
@property (strong, nonatomic) Collection *collection;
@property (strong, nonatomic) UIFont *fontForTitle;
@property (strong, nonatomic) UIFont *fontForText;
@property (strong, nonatomic) UIFont *fontForRemark;
@property (strong, nonatomic) UIWebView *videoView;

@end

@implementation FeedDetailViewController

#pragma mark - Managing the detail item

- (UIFont *)fontForTitle
{
    if(!_fontForTitle){
        _fontForTitle = [UIFont fontWithName:@"MyriadPro-BoldCond" size:17.0f];
    }
    return _fontForTitle;
}
- (UIFont *)fontForText
{
    if(!_fontForText){
        _fontForText = [UIFont fontWithName:@"MyriadPro-Cond" size:14.0f];
    }
    return _fontForText;
}
- (UIFont *)fontForRemark
{
    if(!_fontForRemark){
        _fontForRemark = [UIFont fontWithName:@"MyriadPro-BoldIt" size:12.0f];
    }
    return _fontForRemark;
}

- (CoreDataHandler *)coreDataRep
{
    if(!_coreDataRep){
        MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _coreDataRep = appDelegate.coreDataHandler;
    }
    return _coreDataRep;
}

- (void)setDetail:(id)newDetailItem
{
    self.collection = (Collection *)newDetailItem;
    NSError *e = [[NSError alloc] init];
    id data = [NSJSONSerialization JSONObjectWithData:[self.collection.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&e];
    
    self.listOfNames = [data valueForKeyPath:@"kanjiList"];
    self.title = self.collection.title;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    if ([UtilHelper isVersion6AndBelow]) {
        self.feedTableView.backgroundColor = [UIColor colorWithRed:242.0/255 green:235.0/255 blue:241.0/255 alpha:1.0];
    } else {
        self.feedTableView.tintColor = [UIColor colorWithRed:242.0/255 green:235.0/255 blue:241.0/255 alpha:1.0];
    }
    self.feedTableView.separatorColor = [UIColor clearColor];
#if !TARGET_IPHONE_SIMULATOR
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    bannerView_ = [AdMobLoader getNewBannerView:self];
    [bannerView_ setDelegate:self];
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[AdMobLoader getNewRequest]];
#endif
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    [UIView beginAnimations:@"BannerSlide" context:nil];
    UIEdgeInsets inset = UIEdgeInsetsMake(50, 0, 0, 0);
    self.tableView.contentInset = inset;
    self.tableView.contentOffset = CGPointMake(0.0f, -50.0f);
    [self.view addSubview:bannerView_];
    
    CGRect banFrame = bannerView_.frame;
    banFrame.origin.y = -50;
    [bannerView_ setFrame:banFrame];
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.coreDataRep.currentCollection = self.collection;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.coreDataRep.currentCollection = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section==0)
        return 1;
    else {
        int count = [self.listOfNames count];
        if ([self.collection has_url]) {
            count += 1;
        }
        return count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        FeedHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCellHeader"];
        
        NSDictionary *subTitleAtributes = [cell.subTitleLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
        
        cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Kanji: %@",self.collection.subtitle] attributes:subTitleAtributes];
        cell.subTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Katakana: %@",self.collection.extraTitle] attributes:subTitleAtributes];
        cell.likeButton.selected = [self.collection.favorite boolValue];
        
        return cell;
    } else {
        if (indexPath.row == 0 && [self.collection has_url]) {
            VideoPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoLinkCell"];
            
            return cell;
        } else {
            FeedCell4* cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell4"];
            
            int index = self.collection.has_url ? indexPath.row - 1 : indexPath.row;
            
            NSDictionary *dataObject = [self.listOfNames objectAtIndex:index];
            
            NSDictionary *attributes = [(NSAttributedString *)cell.kanjiLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
            
            // Set new text with extracted attributes
            cell.kanjiLabel.attributedText = [[NSAttributedString alloc] initWithString:[dataObject objectForKey:@"kanji"] attributes:attributes];
            NSString *meaning = [self returnString:[dataObject valueForKey:@"meaning"]];
            NSString *kunyomi = [self returnString:[dataObject valueForKey:@"kunyomi"]];
            NSString *onyomi = [self returnString:[dataObject valueForKey:@"onyomi"]];
            
            NSMutableAttributedString *lineOne = [self getString:@"Meaning:\r" withText:meaning];
            cell.lineOne.attributedText = lineOne;
            NSMutableAttributedString *lineTwo_One = [self getString:@"Kun-Yomi:\r" withText:kunyomi];
            NSMutableAttributedString *lineTwo_Two = [self getString:@"On-Yomi:\r" withText:onyomi];
            
            NSString *spacing = @"\r\r\r\r\r";
            NSMutableAttributedString *lineTwo = [[NSMutableAttributedString alloc] initWithString:spacing];
            [lineTwo insertAttributedString:lineTwo_Two atIndex:0];
            [lineTwo insertAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\r\r"] atIndex:0];
            [lineTwo insertAttributedString:lineTwo_One atIndex:0];
            
            cell.lineTwo.attributedText = lineTwo;
            cell.lineTwo.lineBreakMode = NSLineBreakByClipping;
            
            return cell;
        }

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 75.0f;
    } else if (indexPath.row == 0 && [self.collection has_url]) {
        return 60.0f;
    } else {
        return 265.0f;
    }
}

- (NSMutableAttributedString *)getString:(NSString *)title withText:(NSString *)text
{
    NSArray *rangeOfFormat = [self getRange:text];
    
    NSString *newText = [text stringByReplacingOccurrencesOfString:@"*" withString:@""];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:newText];
    
    [content addAttribute:NSFontAttributeName value:self.fontForText range:NSMakeRange(0, [newText length])];
    for (id object in rangeOfFormat) {
        NSRange r = [object rangeValue];
        [content addAttribute:NSFontAttributeName
                        value:self.fontForRemark
                        range:r];
        [content addAttribute:NSBackgroundColorAttributeName
                  value:[UIColor yellowColor]
                  range:r];
    }
    NSMutableAttributedString *mainTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [mainTitle addAttribute:NSFontAttributeName value:self.fontForTitle range:NSMakeRange(0, [title length])];
       
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:content];
    [result insertAttributedString:mainTitle atIndex:0];
    
    return  result;
}

- (NSMutableArray *)getRange:(NSString *)text
{
    int pos, len;
    NSRange range;
    NSMutableArray *listData = [[NSMutableArray alloc] init];
    
    NSString *newText = [NSString stringWithString:text];
    
    while (1) {
        range = [newText rangeOfString:@"*"];
        if(range.location == NSNotFound) break;
        pos = range.location;
        newText = [newText stringByReplacingCharactersInRange:range withString:@""];
        range = [newText rangeOfString:@"*"];
        newText = [newText stringByReplacingCharactersInRange:range withString:@""];
        
        len = range.location - pos;
        [listData addObject:[NSValue valueWithRange:NSMakeRange(pos, len)]];
    }
    
    return listData;
}

- (NSString *)returnString:(id)object
{
    NSString *string = [object description];
    int value = [string length];
    return [string substringWithRange:NSMakeRange(0, value)];
}

- (IBAction)callLike:(UIButton *)sender {
    
    dispatch_queue_t saveDocumentQueue = dispatch_queue_create("SaveDocument",nil);
    dispatch_async(saveDocumentQueue, ^{
        
        [self.collection setFavorite:[NSNumber numberWithBool:![self.collection.favorite boolValue]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.selected = [self.collection.favorite boolValue];
        });
    });
}

- (IBAction)playVideo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.collection.url_video]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"playVideo"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setUrlToWebView:withTitle:)]){
            NSString *urlString = self.collection.url_video;
            NSString *titleString = [NSString stringWithFormat:@"%@ - %@", self.collection.title, self.collection.subtitle];
            
            
            [segue.destinationViewController performSelector:@selector(setUrlToWebView:withTitle:)
                                                  withObject:urlString
                                                  withObject:titleString];
        }
    }
}

@end
