//
//  TattooViewController.m
//  KanjiMe
//
//  Created by Juan Tabares on 10/4/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "TattooViewController.h"

@interface TattooViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputName;
@property (weak, nonatomic) IBOutlet UITextField *inputEmail;
@property (weak, nonatomic) IBOutlet UITextField *inputTattooText;
@property (weak, nonatomic) IBOutlet UITextField *inputComments;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation TattooViewController
@synthesize inputComments, inputEmail, inputName, inputTattooText;
@synthesize priceLabel;

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
    self.inputName.delegate = self;
    self.inputTattooText.delegate = self;
    self.inputEmail.delegate = self;
    self.inputComments.delegate = self;
    
    //self.inputName.text = @"Juan";
    //self.inputLastName.text = @"Tabares";
    //self.inputEmail.text = @"juan.ctt2002@live.com"
    [self.priceLabel.layer setCornerRadius:5.0];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}


- (IBAction)setPayment:(id)sender {
    
    if (![self validateInputs]) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"Please make sure to enter the required fields"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    // Create a PayPalPayment
    PayPalPayment *payment = [[PayPalPayment alloc] init];
    payment.amount = [[NSDecimalNumber alloc] initWithString:@"10.00"];
    payment.currencyCode = @"USD";
    payment.shortDescription = @"KanjiMe Tattoo";
    
    // Check whether payment is processable.
    if (!payment.processable) {
        // If, for example, the amount was negative or the shortDescription was empty, then
        // this payment would not be processable. You would want to handle that here.
    }
    
    // Start out working with the test environment! When you are ready, remove this line to switch to live.
    [PayPalPaymentViewController setEnvironment:PayPalEnvironmentNoNetwork];
    
    // Provide a payerId that uniquely identifies a user within the scope of your system,
    // such as an email address or user ID.
    NSString *aPayerId = self.inputEmail.text;
    
    // Start out working with the test environment! When you are ready, remove this line to switch to live.
    [PayPalPaymentViewController setEnvironment:PayPalEnvironmentSandbox];
    [PayPalPaymentViewController prepareForPaymentUsingClientId:@"Af0hqBDuovancbyuNJm2O3P3G39AHtulPtrbwXeeOoDTKBEWurI0xhNNOOi4"];
    
    // Create a PayPalPaymentViewController with the credentials and payerId, the PayPalPayment
    // from the previous step, and a PayPalPaymentDelegate to handle the results.
    
    
    PayPalPaymentViewController *paymentViewController;
    
    
    paymentViewController = [[PayPalPaymentViewController alloc] initWithClientId:@"Af0hqBDuovancbyuNJm2O3P3G39AHtulPtrbwXeeOoDTKBEWurI0xhNNOOi4"
                                                                    receiverEmail:@"juan_tabares001-facilitator@hotmail.com"
                                                                          payerId:aPayerId
                                                                          payment:payment
                                                                         delegate:self];
    
    // Present the PayPalPaymentViewController.
    [self presentViewController:paymentViewController animated:YES completion:nil];
}

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment
{
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
    
    // Dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalPaymentDidCancel
{
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    // Send the entire confirmation dictionary
//    NSData *confirmation = [NSJSONSerialization dataWithJSONObject:completedPayment.confirmation
//                                                           options:0
//                                                             error:nil];
    
    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
}

- (BOOL)validateInputs
{
    BOOL ret = YES;
    
    if (NSStringIsEmpty(self.inputName.text)) {
        ret = NO;
        [self.inputName setBackgroundColor:UIColorFromRGBWithAlpha(0xFFCCCC,0.3)];
    } else {
        [self.inputName setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    }
    
    if (NSStringIsEmpty(self.inputTattooText.text)) {
        ret = NO;
        [self.inputTattooText setBackgroundColor:UIColorFromRGBWithAlpha(0xFFCCCC,0.3)];
    } else {
        [self.inputName setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    }
    
    if(![self NSStringIsValidEmail:self.inputEmail.text]){
        ret = NO;
        [self.inputEmail setBackgroundColor:UIColorFromRGBWithAlpha(0xFFCCCC,0.3)];
    } else {
        [self.inputName setBackgroundColor:UIColorFromRGB(0xFFFFFF)];
    }
    
    return ret;
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
