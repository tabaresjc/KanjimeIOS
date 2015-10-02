//
//  WelcomeTattooViewController.m
//  KanjiMe
//
//  Created by Lion User on 10/5/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "WelcomeTattooViewController.h"

@interface WelcomeTattooViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *viewBackground;


@end

@implementation WelcomeTattooViewController
@synthesize viewBackground;

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
    [self.viewBackground setImage:[UIImage tallImageNamed:@"welcome_tattoo.png"]];
}

- (IBAction)viewSamples:(id)sender {
    [self performSegueWithIdentifier:@"ViewSample" sender:self];
}

- (IBAction)purchaseTattoo:(id)sender {
    [self performSegueWithIdentifier:@"ViewPurchase" sender:self];
}




@end
