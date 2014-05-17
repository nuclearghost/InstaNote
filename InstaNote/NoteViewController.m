//
//  NoteViewController.m
//  InstaNote
//
//  Created by Mark Meyer on 5/14/14.
//  Copyright (c) 2014 Mark Meyer. All rights reserved.
//

#import "NoteViewController.h"
#import "DBManager.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

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
    UIView *accessoryView = [[[NSBundle mainBundle]
                              loadNibNamed:@"AccessoryView"
                              owner:self options:nil]
                             firstObject];
    UIButton *cameraButton = (UIButton*)[accessoryView viewWithTag:200];
    UIButton *doneButton = (UIButton*)[accessoryView viewWithTag:300];
    
    [cameraButton addTarget:self action:@selector(cameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton addTarget:self action:@selector(doneTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.textView setInputAccessoryView:accessoryView];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[DBManager sharedManager] accountAvailable]) {
        [[[UIAlertView alloc]
          initWithTitle:@"Link Account" message:@"You must link your dropbox account to proceed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]
         show];
    } else {
        [self.textView becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [[DBManager sharedManager] initializeAccountLinkFromView:self.navigationController];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)cameraTapped:(id)sender {
    NSLog(@"cameraTapped");
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[DBCameraContainer alloc] initWithDelegate:self]];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)doneTapped:(id)sender {
    NSLog(@"doneTapped");
    [self.textView endEditing:YES];
}

- (IBAction)listTapped:(id)sender {
    NSLog(@"listTapped");
    [self performSegueWithIdentifier:@"listSegue" sender:self];
}

#pragma mark - DBCameraViewControllerDelegate

- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    [imgView setFrame:CGRectMake(0, 0, 320, 320)];
    [self.textView addSubview:imgView];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
