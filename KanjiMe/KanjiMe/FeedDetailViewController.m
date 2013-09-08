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
#import "RestApiHelpers.h"
#import "RestApiConstant.h"
#import "Collection.h"
#import "FeedCell4.h"
#import "FeedHeaderCell.h"
#import "MBProgressHUD.h"

@interface FeedDetailViewController ()
@property (strong, nonatomic) NSArray *listOfNames;
@property (strong, nonatomic) Collection *collection;
@property (strong, nonatomic) UIFont *fontForTitle;
@property (strong, nonatomic) UIFont *fontForText;
@property (strong, nonatomic) UIFont *fontForRemark;
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
- (void)setDetail:(id)newDetailItem withCell:(id)cell
{
    self.collection = (Collection *)newDetailItem;
    NSError *e = [[NSError alloc] init];
    id data = [NSJSONSerialization JSONObjectWithData:[self.collection.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&e];
    
    self.listOfNames = [data valueForKeyPath:@"kanjiList"];
    self.title = self.collection.title;
    //NSLog(@"%@",self.listOfNames);
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
    // Create a view of the standard size at the top of the screen.
    // Available AdSize constants are explained in GADAdSize.h.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // Specify the ad's "unit identifier". This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"ca-app-pub-9096893656708907/5942382873";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:@"2be07610ffc77e998855454a203a7b3a", nil];
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:request];
    
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    self.feedTableView.backgroundColor = [UIColor colorWithRed:242.0/255 green:235.0/255 blue:241.0/255 alpha:1.0];
    self.feedTableView.separatorColor = [UIColor clearColor];

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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return section!=2 ? 1 : [self.listOfNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdBanner"];
        return cell;
    } else if(indexPath.section==1){
        FeedHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCellHeader"];
        
        NSDictionary *subTitleAtributes = [cell.subTitleLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
        
        cell.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Kanji: %@",self.collection.subtitle] attributes:subTitleAtributes];
        cell.subTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Katakana: %@",self.collection.extraTitle] attributes:subTitleAtributes];
        cell.likeButton.selected = self.collection.favorite;
        
        return cell;
    } else {
        FeedCell4* cell = [tableView dequeueReusableCellWithIdentifier:@"FeedCell4"];
        NSDictionary *dataObject = [self.listOfNames objectAtIndex:indexPath.row];
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        return 55.0f;
    } else if(indexPath.section==1) {
        return 75.0f;
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
        [content addAttribute:NSFontAttributeName value:self.fontForRemark range:r];
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
    self.collection.favorite = !self.collection.favorite;
    sender.selected = self.collection.favorite;
}

- (IBAction)callShareActionSheet:(id)sender {
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Email", nil];
    [shareActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [shareActionSheet showInView:self.tabBarController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self shareToFacebook];
        }
            break;
        case 1:
        {
            [self shareToTwitter];
        }
            break;
        case 2:
        {
            [self shareByEmail];
        }
            break;
        default:
            break;
    }
}

- (NSString *)getCommonDescriptor
{
    return [NSString stringWithFormat:@"Check it out! The kanji for %@ is %@, Find yours at %@", self.collection.title, self.collection.subtitle, WEB_ENDPOINT_URL];
    
}

- (void)shareToFacebook
{
    [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:WEB_ENDPOINT_URL]
                                     name:@"KanjiMe! iOS"
                                  caption:@"KanjiMe!"
                              description:[self getCommonDescriptor]
                                  picture:[NSURL URLWithString:@"http://kanjime.learnjapanese123.com/img/iTunesArtwork.png"]
                              clientState:nil
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                      if(error) {
                                          NSLog(@"Error: %@", error.description);
                                      } else {
                                          NSLog(@"Success!");
                                      }
                                  }];
    
}


- (void)shareToTwitter
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[self getCommonDescriptor]];
        
        [tweetSheet addImage:[UIImage imageNamed:@"iTunesArtwork.png"]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        [RestApiHelpers setAlertMessage:@"You can't send a tweet right now, make sure"
         "your device has an internet connection and you have"
         "at least one Twitter account setup"
                    withTitle:@"Sorry"];
    }
}

- (void)shareByEmail
{
  
    // Email Subject
    NSString *emailTitle = @"KanjiMe! iOS";
    // Email Content
    NSString *messageBody = [self getCommonDescriptor];
    // To address
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
        
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    MBProgressHUD *emailMessageWindow = [MBProgressHUD showHUDAddedTo:self.view
                                                             animated:YES];
    emailMessageWindow.mode = MBProgressHUDModeIndeterminate;
    emailMessageWindow.labelText = @"Sending message...";
    switch (result)
    {
        case MFMailComposeResultCancelled:
            emailMessageWindow.labelText = @"Cancelled";
            break;
        case MFMailComposeResultSaved:
            emailMessageWindow.labelText = @"Saved";
            break;
        case MFMailComposeResultSent:
            emailMessageWindow.labelText = @"Sent";
            break;
        case MFMailComposeResultFailed:
            emailMessageWindow.labelText = @"Fail";
            break;
        default:
            break;
    }
    // Close the Mail Interface
    
    [self dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSThread sleepForTimeInterval:0.5];
            [emailMessageWindow hide:YES];
        });
    }];
}



@end
