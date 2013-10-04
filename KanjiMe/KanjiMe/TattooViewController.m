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
@property (weak, nonatomic) IBOutlet UITextField *inputLastName;
@property (weak, nonatomic) IBOutlet UITextField *inputEmail;

@end

@implementation TattooViewController
@synthesize inputEmail, inputLastName, inputName;

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
    self.inputLastName.delegate = self;
    self.inputEmail.delegate = self;
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

@end
