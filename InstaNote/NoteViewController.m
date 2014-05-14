//
//  NoteViewController.m
//  InstaNote
//
//  Created by Mark Meyer on 5/14/14.
//  Copyright (c) 2014 Mark Meyer. All rights reserved.
//

#import "NoteViewController.h"

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
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

- (void)doneTapped:(id)sender {
    NSLog(@"doneTapped");
    [self.textView endEditing:YES];
}

- (IBAction)listTapped:(id)sender {
    NSLog(@"listTapped");
    [self performSegueWithIdentifier:@"listSegue" sender:self];
}
@end
