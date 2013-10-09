//
//  TattooViewController.m
//  KanjiMe
//
//  Created by Juan Tabares on 10/4/13.
//  Copyright (c) 2013 Alteran System. All rights reserved.
//

#import "TattooViewController.h"
#import "RestApiFetcher.h"
#import "Order+Rest.h"
#import "MainAppDelegate.h"

@interface TattooViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputName;
@property (weak, nonatomic) IBOutlet UITextField *inputEmail;
@property (weak, nonatomic) IBOutlet UITextField *inputTattooText;
@property (weak, nonatomic) IBOutlet UITextField *inputComments;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) Order *order;
@property (nonatomic) OrderSteps orderStatus;
@property (strong,nonatomic) CoreDataHandler *coreDataRep;
@end

@implementation TattooViewController
@synthesize inputComments, inputEmail, inputName, inputTattooText;
@synthesize priceLabel;
@synthesize order;
@synthesize orderStatus;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CoreDataHandler *)coreDataRep
{
    if(!_coreDataRep){
        MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _coreDataRep = appDelegate.coreDataHandler;
    }
    return _coreDataRep;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.inputName.delegate = self;
    self.inputTattooText.delegate = self;
    self.inputEmail.delegate = self;
    self.inputComments.delegate = self;
    
    self.inputName.text = @"Juan Tabares";
    self.inputTattooText.text = @"Juan Tabares";
    self.inputEmail.text = @"juan.ctt2002@live.com";
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Confirmation"]) {
        if([segue.destinationViewController respondsToSelector:@selector(setMessageToView:withOrderStatus:)]){
            [segue.destinationViewController performSelector:@selector(setMessageToView:withOrderStatus:)
                                                  withObject:self.order
                                                  withObject:[NSNumber numberWithInt:(int)self.orderStatus]];
        }
    }
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
    [PayPalPaymentViewController prepareForPaymentUsingClientId:PAYPAL_CLIENTID];
    
    // Create a PayPalPaymentViewController with the credentials and payerId, the PayPalPayment
    // from the previous step, and a PayPalPaymentDelegate to handle the results.
    
    
    PayPalPaymentViewController *paymentViewController;
    
    
    paymentViewController = [[PayPalPaymentViewController alloc] initWithClientId:PAYPAL_CLIENTID
                                                                    receiverEmail:PAYPAL_EMAIL
                                                                          payerId:aPayerId
                                                                          payment:payment
                                                                         delegate:self];
    
    // Present the PayPalPaymentViewController.
    self.orderStatus = ORDERSTART;    
    [self presentViewController:paymentViewController animated:YES completion:nil];
    
}

- (void)payPalPaymentDidComplete:(PayPalPayment *)completedPayment
{
    self.orderStatus = ORDER_API_COMLETED;
    // Payment was processed successfully; send to server for verification and fulfillment.
    [self verifyCompletedPayment:completedPayment];
}

- (void)payPalPaymentDidCancel
{
    // The payment was canceled; dismiss the PayPalPaymentViewController.
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)verifyCompletedPayment:(PayPalPayment *)completedPayment {
    // Send the entire confirmation dictionary
    // Send confirmation to your server; your server should verify the proof of payment
    // and give the user their goods or services. If the server is not reachable, save
    // the confirmation and try again later.
    self.order = [self.coreDataRep getOrderFromParameters:self.inputName.text
                                                withEmail:self.inputEmail.text
                                               withTattoo:self.inputTattooText.text
                                             withComments:self.inputComments.text
                                          withPaymentInfo:completedPayment.confirmation];
    
    NSDictionary *httpDataOrder = [self.order getHttpDataForCreation];
    NSLog(@"%@",httpDataOrder);
    RestApiFetcher *apiFetcher = [[RestApiFetcher alloc] init];
//    NSDictionary *httpDataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                        httpDataOrder, @"Order",
//                                        nil];
    
    [apiFetcher createOrder:httpDataOrder
                    success:^(id jsonData) {
                        order.is_sent = true;
                        self.orderStatus = ORDER_CONFIRMATION;
                        // Dismiss the PayPalPaymentViewController.
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [self performSegueWithIdentifier:@"Confirmation" sender:self];
                    }
                    failure:^(NSError *error) {
                        order.is_sent = false;
                        self.orderStatus = ORDER_ERROR;
                        [self performSegueWithIdentifier:@"Confirmation" sender:self];
                    }];
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
