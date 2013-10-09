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

- (void)setUrlToWebView:(NSString *)urlString withTitle:(NSString *)title
{
    self.baseUrl = [NSURL URLWithString:urlString];
    self.titleOfView = title;
}

@end
