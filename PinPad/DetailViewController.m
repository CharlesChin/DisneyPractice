//
//  DetailViewController.m
//  PinPad
//
//  Created by Melissa on 12/18/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

#import "DetailViewController.h"
#import <Parse/Parse.h>


@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *confirmNewPinInput;
@property (weak, nonatomic) IBOutlet UITextField *pinInputTextbox;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)ResetBtnPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resetBtnOutlet;

@end

@implementation DetailViewController 

#pragma mark - Viewcontroller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    //hide keyboard when click non-textbox area
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    // passing values between VCs
    self.myProfileImgView.image = self.detailedImg;
    self.detailDescriptionLabel.text = self.profileName;
    
    // updating reset button color every 0.01 sec
    [NSTimer scheduledTimerWithTimeInterval:0.01f target:self
                                   selector:@selector(checkPinAvailability) userInfo:nil repeats:YES];
    
}

#pragma mark - RESET press & PIN logics

- (IBAction)ResetBtnPress:(id)sender {
    
    // reset back to originals
    self.pinInputTextbox.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    self.pinInputTextbox.layer.borderWidth=1.0;
    self.confirmNewPinInput.layer.borderColor=[[UIColor lightGrayColor]CGColor];
    self.confirmNewPinInput.layer.borderWidth=1.0;
    self.errorLabel.text = @"";
    
    int inputKey = [self.pinInputTextbox.text intValue];
    
    int key1 = inputKey/1000;
    int key2 = inputKey/100 %10;
    int key3 = inputKey/10 %10;
    int key4 = inputKey %10;
    
    if ([self.pinInputTextbox.text isEqualToString:@""]||[self.confirmNewPinInput.text isEqualToString:@""]) {
        
        if ([self.pinInputTextbox.text isEqualToString:@""]) {
            self.pinInputTextbox.layer.borderColor=[[UIColor redColor]CGColor]; // change border color 
            self.pinInputTextbox.layer.borderWidth=1.0;
        }
        if ([self.confirmNewPinInput.text isEqualToString:@""]) {
            self.confirmNewPinInput.layer.borderColor=[[UIColor redColor]CGColor];
            self.confirmNewPinInput.layer.borderWidth=1.0;
        }
        self.errorLabel.text = @"*required fields";
        return;
    }
    
    if (self.pinInputTextbox.text.length == 4) {
        
        if ((key1+1 == key2) && (key1+2 == key3) && (key1+3 == key4)) {
            NSLog(@"it is a sequence!");
            self.errorLabel.text = @"PIN can not be sequential digits";
            self.pinInputTextbox.text = @"";
            self.confirmNewPinInput.text = @"";
            return;
        }
        
        if ((key1 == key2) && (key1 == key3) && (key1 == key4)) {
            NSLog(@"all are equal");
            self.errorLabel.text = @"PIN has to use at minimum 2 differnt numbers";
            self.pinInputTextbox.text = @"";
            self.confirmNewPinInput.text = @"";
            return;
        }
        
        if ((key1-1 == key2) && (key1-2 == key3) && (key1-3 == key4)) {
            NSLog(@"it is a sequence!");
            self.errorLabel.text = @"PIN can not be sequential digits";
            self.pinInputTextbox.text = @"";
            self.confirmNewPinInput.text = @"";
            return;
        }
        
        if ([self.pinInputTextbox.text intValue] == [self.confirmNewPinInput.text intValue]) {
            
            NSLog(@"PIN set");
            
            // Create the PFQuery and retrieve data by ID
            PFQuery *query = [PFQuery queryWithClassName:@"userPin"];
            
            [query getObjectInBackgroundWithId:@"Fg2zF7SLFi" block:^(PFObject *pfObject, NSError *error) {
                
                [pfObject setObject:self.pinInputTextbox.text forKey:@"PIN"];
                [pfObject saveInBackground];
            }];
            
            [self showAlertWithTitle:@"SUCCESS!" andMessage:@"Your PIN has been saved successfully!"];
        }else{
            self.errorLabel.text = @"PINs do not match";
            self.confirmNewPinInput.text = @"";
            self.pinInputTextbox.text = @"";
        }
    }else{
        self.pinInputTextbox.text = @"";
        self.confirmNewPinInput.text = @"";
        self.errorLabel.text = @"PIN must be 4 digits long";
    }
}

- (void)checkPinAvailability{
    
    if ([self.pinInputTextbox.text intValue] == [self.confirmNewPinInput.text intValue] && self.pinInputTextbox.text.length ==4){
        self.resetBtnOutlet.layer.backgroundColor = [[UIColor greenColor] CGColor];
    }else{
        self.resetBtnOutlet.layer.backgroundColor = [[UIColor groupTableViewBackgroundColor] CGColor];
    }
}

- (void) showAlertWithTitle:(NSString *)title andMessage: (NSString *)message{
    
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    //add "OK" button on alert
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

-(void)dismissKeyboard { //dissmiss two login textField keyboards
    [self.pinInputTextbox resignFirstResponder];
    [self.confirmNewPinInput resignFirstResponder];
}


@end
