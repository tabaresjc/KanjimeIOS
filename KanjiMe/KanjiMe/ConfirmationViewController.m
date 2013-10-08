//
//  ConfirmationViewController.m
//  KanjiMe
//
//  Created by Juan Tabares on 10/8/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "Order+Rest.h"

@interface ConfirmationViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;
@property (weak, nonatomic) IBOutlet UIButton *buttonOk;
@property (strong, nonatomic) Order *order;
@property (nonatomic) OrderSteps orderStatus;
@end

@implementation ConfirmationViewController
@synthesize backgroundImage,messageLabel,buttonCancel,buttonOk;
@synthesize order,orderStatus;

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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    switch (self.orderStatus) {
        case ORDER_API_COMLETED:
        {
            [self.buttonCancel setTitle:@"Retry?" forState:UIControlStateNormal];
            self.messageLabel.text = @"Pending confirmation from server";
            break;
        }
        case ORDER_CONFIRMATION:
        {
            [self.buttonCancel setHidden:YES];
            self.messageLabel.text = @"Completed\n"
            "You shall receive a confirmation message within minutes\n\n"
            "Please press Ok to continue";
            break;
        }
        case ORDER_API_CANCELED:
        default:
            [self.buttonCancel setTitle:@"Retry?" forState:UIControlStateNormal];
            self.messageLabel.text = @"Order canceled due to problems with Paypal service\n\n"
            "Would you like to retry?";
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMessageToView:(id)orderObject withOrderStatus:(id)orderStatusObject
{
    self.order = (Order *)orderObject;
    NSNumber *numberObject = (NSNumber *)orderStatusObject;
    self.orderStatus = (OrderSteps)[numberObject integerValue];
}

- (IBAction)cancelAction:(id)sender {
}

- (IBAction)okAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
