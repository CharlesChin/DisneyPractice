//
//  MasterViewController.m
//  PinPad
//
//  Created by Melissa on 12/18/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <Parse/Parse.h>

@interface MasterViewController (){
    int pin;
}

@property NSMutableArray *objects;
@property NSMutableArray *parents;
@property NSMutableArray *kids;
@property NSArray *allParentsIDs;
@property NSArray *allKidsIDs;
@property NSArray *allIDs;
@property NSMutableArray *allParentsPIN;
@property NSMutableArray *allKidsPIN;


@end

@implementation MasterViewController

#pragma mark - Viewcontroller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
 
    // compose the family info: 2 kids 1 parent just to demonstrate
    NSDictionary *JamesPSullivan = [NSDictionary dictionaryWithObjectsAndKeys:@"James ",@"firstname",@"Sullivan",@"lastname",@"James.jpg",@"pic",@"holder",@"accountType",@"26",@"age",@"Fg2zF7SLFi",@"ID", nil];
    NSDictionary *MikeWazowsky = [NSDictionary dictionaryWithObjectsAndKeys:@"Mike ",@"firstname",@"Wazowsky",@"lastname",@"Mikey.jpeg",@"pic",@"member",@"accountType",@"22",@"age",@"rGX1dRfLsx",@"ID", nil];
    NSDictionary *Boo = [NSDictionary dictionaryWithObjectsAndKeys:@"Boo ",@"firstname",@"Sullivan",@"lastname",@"Boo.jpeg",@"pic",@"member",@"accountType",@"4",@"age",@"DfJ1BzGnjh",@"ID", nil];
    self.parents = [NSMutableArray arrayWithObjects:JamesPSullivan,nil];
    self.kids = [NSMutableArray arrayWithObjects:MikeWazowsky,Boo, nil];
    self.allParentsIDs = [[NSArray alloc] initWithObjects:@"Fg2zF7SLFi", nil];
    self.allKidsIDs = [[NSArray alloc] initWithObjects:@"rGX1dRfLsx",@"DfJ1BzGnjh", nil];
    self.allIDs = [[NSArray alloc] initWithObjects:@"Fg2zF7SLFi",@"rGX1dRfLsx",@"DfJ1BzGnjh", nil];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    self.allParentsPIN = [[NSMutableArray alloc] init];
    self.allKidsPIN = [[NSMutableArray alloc] init];
    [self ConfigurePfQuery];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Parse Database

- (void)ConfigurePfQuery{
    
    // Create the PFQuery and retrieve by ID
    PFQuery *query = [PFQuery queryWithClassName:@"userPin"];
    for (int i = 0; i < [self.allParentsIDs count]; i++) {
        PFObject *parentObj = [query getObjectWithId:self.allParentsIDs[i]];
        [self.allParentsPIN addObject:[parentObj valueForKey:@"PIN"]]; // add parent PIN to array
    }
    for (int j = 0; j < [self.allKidsIDs count]; j++) {
        PFObject *kidObj = [query getObjectWithId:self.allKidsIDs[j]];
        [self.allKidsPIN addObject:[kidObj valueForKey:@"PIN"]]; // add kid PIN to array
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.parents count];
    }
    return [self.kids count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [self.parents[indexPath.row] valueForKey:@"firstname"];
        cell.detailTextLabel.text = [self.parents[indexPath.row] valueForKey:@"lastname"];
        cell.imageView.image = [UIImage imageNamed:[self.parents[indexPath.row] valueForKey:@"pic"]];
    }
    if (indexPath.section == 1) {
        cell.textLabel.text = [self.kids[indexPath.row] valueForKey:@"firstname"];
        cell.detailTextLabel.text = [self.kids[indexPath.row] valueForKey:@"lastname"];
        cell.imageView.image = [UIImage imageNamed:[self.kids[indexPath.row] valueForKey:@"pic"]];
    }
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Me";
    }else
        return @"Family";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"PIN REQUIRED" message:@"Please enter the old PIN to proceed" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES; // old PIN input set as secure text entry
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    
    [alert addAction: [UIAlertAction actionWithTitle:@"Proceed" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        DetailViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"detailedVC"];
        
        if (indexPath.section == 0 && [alert.textFields[0].text intValue] == [self.allParentsPIN[indexPath.row] intValue]) {
            // for parents, check pins and pass value
            dvc.profileName = [[self.parents[indexPath.row] valueForKey:@"firstname"] stringByAppendingString:[self.parents[indexPath.row] valueForKey:@"lastname"]];
            dvc.detailedImg = [UIImage imageNamed:[self.parents[indexPath.row] valueForKey:@"pic"]];
            dvc.profileID = [self.parents[indexPath.row] valueForKey:@"ID"];
            dvc.allParentsIDs = self.allParentsIDs;
            dvc.allKidsIDs = self.allKidsIDs;
            [self.navigationController pushViewController:dvc animated:YES];
        }else if (indexPath.section == 1 && [alert.textFields[0].text intValue] == [self.allKidsPIN[indexPath.row] intValue]){
            // for kids, check pins and pass value
            dvc.profileName = [[self.kids[indexPath.row] valueForKey:@"firstname"] stringByAppendingString:[self.kids[indexPath.row] valueForKey:@"lastname"]];
            dvc.detailedImg = [UIImage imageNamed:[self.kids[indexPath.row] valueForKey:@"pic"]];
            dvc.profileID = [self.kids[indexPath.row] valueForKey:@"ID"];
            dvc.allParentsIDs = self.allParentsIDs;
            dvc.allKidsIDs = self.allKidsIDs;
            [self.navigationController pushViewController:dvc animated:YES];
        }else{
            // show another alert when old PIN is invalid
            UIAlertController *smallAlert = [UIAlertController alertControllerWithTitle:@"PIN INVALID" message:@"Make sure to enter the correct 4-digits PIN" preferredStyle:UIAlertControllerStyleAlert];
            [smallAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:smallAlert animated:YES completion:nil];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"Cancel pressed");
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];

        if (indexPath.section == 0) {
            [self.parents removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        if (indexPath.section == 1) {
            [self.kids removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [tableView endUpdates];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
