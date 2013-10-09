//
//  CreditsViewController.m
//  KanjiMe
//
//  Created by Lion User on 9/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "CreditsViewController.h"

@interface CreditsViewController ()
@property (strong, nonatomic) IBOutlet UILabel *providerTitle;
@property (strong, nonatomic) IBOutlet UILabel *providerContent;
@property (strong, nonatomic) IBOutlet UILabel *developerTitle;
@property (strong, nonatomic) IBOutlet UILabel *developerContent;
@property (strong, nonatomic) IBOutlet UILabel *footer;

@end

@implementation CreditsViewController
@synthesize providerContent, providerTitle;
@synthesize developerTitle, developerContent;
@synthesize footer;


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
    [self setStyle];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setStyle
{
    [self.view setBackgroundColor:MAIN_BACK_COLOR];
    
    UIFont *fontForTitle = [UIFont fontWithName:@"MyriadPro-BoldCond" size:21.0f];
    UIFont *fontForContent = [UIFont fontWithName:@"MyriadPro-Cond" size:17.0f];
    
    UIFont *fontForDeveloperTitle = [UIFont fontWithName:@"MyriadPro-BoldCond" size:16.0f];
    UIFont *fontForDeveloperContent = [UIFont fontWithName:@"MyriadPro-Cond" size:13.0f];
    
    UIFont *fontForFooter = [UIFont fontWithName:@"MyriadPro-Cond" size:11.0f];
    providerTitle.attributedText = [self getModifiedMutableString:providerTitle withFont:fontForTitle];
    providerContent.attributedText = [self getModifiedMutableString:providerContent withFont:fontForContent];
    
    developerTitle.attributedText = [self getModifiedMutableString:developerTitle withFont:fontForDeveloperTitle];
    developerContent.attributedText = [self getModifiedMutableString:developerContent withFont:fontForDeveloperContent];
    
    footer.attributedText = [self getModifiedMutableString:footer withFont:fontForFooter];
}

- (NSMutableAttributedString *)getModifiedMutableString:(UILabel *)controlBase withFont:(UIFont *)newFont
{
    NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:controlBase.attributedText];
    
    [newAttributedString addAttribute:NSFontAttributeName value:newFont range:NSMakeRange(0, [newAttributedString.string length])];
    
    return newAttributedString;
}



- (IBAction)sendToWebView:(UIButton *)sender
{
    [self performSegueWithIdentifier: @"SendUrl" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SendUrl"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setUrlToWebView:withTitle:)]){
            UIButton *button = (UIButton *)sender;
            NSString *urlString = @"http://www.learnjapanese123.com/";
            NSString *titleString = @"LearnJapanese123";
            
            if(button.tag == 1) {
                urlString = @"https://www.facebook.com/Japanese.Language.Culture";
                titleString = @"Facebook Fan Page";
            } else if(button.tag == 2) {
                urlString = @"https://twitter.com/japanese123";
                titleString = @"Twitter Feed";
            } else if(button.tag == 3) {
                urlString = @"http://www.youtube.com/user/10minsJapanese";
                titleString = @"Youtube Channel";
            }
            
            [segue.destinationViewController performSelector:@selector(setUrlToWebView:withTitle:)
                                                  withObject:urlString
                                                  withObject:titleString];
        }
    }
}



@end
