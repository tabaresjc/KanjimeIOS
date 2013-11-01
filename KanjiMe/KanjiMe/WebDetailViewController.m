//
//  WebDetailViewController.m
//  KanjiMe
//
//  Created by Lion User on 9/16/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "WebDetailViewController.h"

@interface WebDetailViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *mainWebView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSURL *baseUrl;
@property (strong, nonatomic) NSString *titleOfView;
@end

@implementation WebDetailViewController

@synthesize baseUrl, titleOfView;

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
    
    if(self.baseUrl){
        self.mainWebView.delegate = self;
        [self.spinner startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.baseUrl];
        [self.mainWebView loadRequest:request];
        [self setTitle:self.titleOfView];
    }    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
    
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)setUrlToWebView:(NSString *)urlString withTitle:(NSString *)title
{
    self.baseUrl = [NSURL URLWithString:urlString];
    self.titleOfView = title;
}

- (IBAction)launchUrl:(id)sender {
    
    
    NSURL *inputURL = self.baseUrl;
    NSString *scheme = inputURL.scheme;
    
    // Replace the URL Scheme with the Chrome equivalent.
    NSString *chromeScheme = nil;
    if ([scheme isEqualToString:@"http"]) {
        chromeScheme = @"safari";
    } else if ([scheme isEqualToString:@"https"]) {
        chromeScheme = @"safaris";
    }
    
    // Proceed only if a valid Google Chrome URI Scheme is available.
    if (chromeScheme) {
        NSString *absoluteString = [inputURL absoluteString];
        NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
        NSString *urlNoScheme =
        [absoluteString substringFromIndex:rangeForScheme.location];
        NSString *chromeURLString =
        [chromeScheme stringByAppendingString:urlNoScheme];
        NSURL *chromeURL = [NSURL URLWithString:chromeURLString];
        
        // Open the URL with Chrome.
        [[UIApplication sharedApplication] openURL:chromeURL];
    }
}
@end
