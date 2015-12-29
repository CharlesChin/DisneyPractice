//
//  DetailViewController.m
//  PinPad
//
//  Created by Melissa on 12/18/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

#import "DetailViewController.h"
#import <Parse/Parse.h>


@interface DetailViewController (){
    
    BOOL pass;
}

@property (weak, nonatomic) IBOutlet UITextField *confirmNewPinInput;
@property (weak, nonatomic) IBOutlet UITextField *pinInputTextbox;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)ResetBtnPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resetBtnOutlet;
@property (nonatomic) NSString *accountType;
@property (nonatomic) PFQuery *query;

@end

@implementation DetailViewController 

#pragma mark - Viewcontroller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    pass = NO;
    
    self.query = [PFQuery queryWithClassName:@"userPin"]; // set up PFQuery

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
    [NSTimer scheduledTimerWithTimeInterval:0.01f target:self
                                   selector:@selector(checkPinValidity) userInfo:nil repeats:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
  
    // Create the PFQuery and check current user's accountType
    [self.query getObjectInBackgroundWithId:self.profileID block:^(PFObject *pfObject, NSError *error) {
        
        self.accountType = [pfObject valueForKey:@"accountType"];
        [pfObject saveInBackground];
    }];
    
    self.allIDs = [[NSMutableArray alloc] initWithArray:self.allParentsIDs];
    [self.allIDs addObjectsFromArray:self.allKidsIDs];
    
}

#pragma mark - RESET press & PIN logics

- (void)checkPinValidity{
    
    //textbox border red when not 4 digits, a sequence, or all same; green when 4 only
    int inputKey = [self.pinInputTextbox.text intValue];
    
    int key1 = inputKey/1000;
    int key2 = inputKey/100 %10;
    int key3 = inputKey/10 %10;
    int key4 = inputKey %10;
    
    if ([self.pinInputTextbox.text isEqualToString:@""]) {
        
        self.pinInputTextbox.layer.borderColor=[[UIColor redColor]CGColor]; // change border color
        self.pinInputTextbox.layer.borderWidth=1.0;
        self.errorLabel.text = @"*required fields";
        
    }else{
        
        // 4 digits?
        if (self.pinInputTextbox.text.length != 4) {
            
            self.pinInputTextbox.layer.borderColor=[[UIColor redColor]CGColor]; // No
            self.pinInputTextbox.layer.borderWidth=1.0;
            self.errorLabel.text = @"PIN has to be 4 digits";
            
        }else{    // YES: check sequence, repeadance

            if ((key1+1 == key2) && (key1+2 == key3) && (key1+3 == key4)) {
                NSLog(@"it is a sequence!");
                self.errorLabel.text = @"PIN can not be sequential digits";
                return;
            }
            
            if ((key1 == key2) && (key1 == key3) && (key1 == key4)) {
                NSLog(@"all are equal");
                self.errorLabel.text = @"PIN has to use at minimum 2 differnt numbers";
                return;
            }
            
            if ((key1-1 == key2) && (key1-2 == key3) && (key1-3 == key4)) {
                NSLog(@"it is a sequence!");
                self.errorLabel.text = @"PIN can not be sequential digits";
                return;
            }
            
            self.pinInputTextbox.layer.borderColor=[[UIColor lightGrayColor]CGColor]; // first box correct
            self.pinInputTextbox.layer.borderWidth=1.0;
            self.errorLabel.text = @"";
        }
    }
    
    if ([self.confirmNewPinInput.text isEqualToString:@""]) {
        
        self.confirmNewPinInput.layer.borderColor=[[UIColor redColor]CGColor];
        self.confirmNewPinInput.layer.borderWidth=1.0;
        
    }else{
        
        if (![self.confirmNewPinInput.text isEqualToString:self.pinInputTextbox.text]) {
            self.confirmNewPinInput.layer.borderColor=[[UIColor redColor]CGColor];
            self.confirmNewPinInput.layer.borderWidth=1.0;
            self.errorLabel.text = @"PINs do not match";
            pass = NO;
        }else if (self.confirmNewPinInput.text.length == 4){
            self.errorLabel.text = @"";
            self.confirmNewPinInput.layer.borderColor=[[UIColor lightGrayColor]CGColor]; // two boxes match
            self.confirmNewPinInput.layer.borderWidth=1.0;
            pass = YES;
        }
    }
}

- (IBAction)ResetBtnPress:(id)sender {

    if (pass && [self.accountType isEqualToString:@"member"]) {

        [self.query getObjectInBackgroundWithId:self.profileID block:^(PFObject *pfObject, NSError *error) {
            
            [pfObject setObject:self.pinInputTextbox.text forKey:@"PIN"];
            [pfObject saveInBackground];
        }];
        [self popCurrentViewWhenResetIsSuccessful];
        
    }else if(pass && [self.accountType isEqualToString:@"holder"]){
        // change all PIN
        for (int i=0; i<[self.allIDs count]; i++) {
            PFObject *object = [self.query getObjectWithId:self.allIDs[i]];
            [object setObject:self.pinInputTextbox.text forKey:@"PIN"];
            [object save];
        }
        [self popCurrentViewWhenResetIsSuccessful];
    }
}

- (void)popCurrentViewWhenResetIsSuccessful{
    
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"SUCCESS!" message:@"Your PIN has been successfully set" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.navigationController popToRootViewControllerAnimated:YES]; // pop it
    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)checkPinAvailability{
    
    if (pass){
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

#pragma mark - Some tweaks on the keyboard

-(void)dismissKeyboard { //dissmiss two login textField keyboards
    [self.pinInputTextbox resignFirstResponder];
    [self.confirmNewPinInput resignFirstResponder];
}

#define kMin 50

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    //move the main view, so that the keyboard does not hide it.
    if (self.view.frame.origin.y + self.pinInputTextbox.frame.origin. y >= kMin) {
        [self setViewMovedUp:YES];
    }
    if (self.view.frame.origin.y + self.confirmNewPinInput.frame.origin. y >= kMin) {
        [self setViewMovedUp:YES];
    }
}



//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y = kMin - self.pinInputTextbox.frame.origin.y ;
        
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y = 0;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)keyboardWillShow:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    
    if ([self.pinInputTextbox isFirstResponder] && self.pinInputTextbox.frame.origin.y + self.view.frame.origin.y >= kMin)
    {
        [self setViewMovedUp:YES];
    }
    else if (![self.pinInputTextbox isFirstResponder] && self.pinInputTextbox.frame.origin.y  + self.view.frame.origin.y < kMin)
    {
        [self setViewMovedUp:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    if (self.view.frame.origin.y < 0 ) {
        [self setViewMovedUp:NO];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


@end
