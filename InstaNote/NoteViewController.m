//
//  NoteViewController.m
//  InstaNote
//
//  Created by Mark Meyer on 5/14/14.
//  Copyright (c) 2014 Mark Meyer. All rights reserved.
//

#import "NoteViewController.h"
#import "DBManager.h"

#import <EventKit/EventKit.h>

@interface NoteViewController ()

@property (strong,nonatomic) EKEventStore *store;
@property (strong,nonatomic) NSRegularExpression *regex;

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
    
    doneButton.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Done", nil)];
    self.listButton.title = [NSString stringWithFormat:NSLocalizedString(@"List", nil)];
    
    [self.listButton setAccessibilityLabel:NSLocalizedString(@"List", nil)];
    [self.cloudButton setAccessibilityLabel:NSLocalizedString(@"Cloud", nil)];
    
    [cameraButton addTarget:self action:@selector(cameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton addTarget:self action:@selector(doneTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.textView setInputAccessoryView:accessoryView];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.regex = [NSRegularExpression
                  regularExpressionWithPattern:@"TODO:"
                  options:NSRegularExpressionCaseInsensitive
                  error:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.file) {
        self.navigationItem.title = self.file.info.path.name;
        self.textView.text = [self.file readString:nil];
    }
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
    if (alertView.tag == 12) {
        if (buttonIndex == 1) {
            UITextField *textfield = [alertView textFieldAtIndex:0];
            NSLog(@"filename: %@", textfield.text);
            [[DBManager sharedManager] creatFile:textfield.text completion:^(BOOL completed, DBFile *file) {
                if (completed) {
                    self.file = file;
                    self.navigationItem.title = self.file.info.path.name;
                    [self.file writeString:self.textView.text error:nil];
                } else {
                    //TODO alert or something
                }
            }];
        }
    } else {
        [[DBManager sharedManager] initializeAccountLinkFromView:self.navigationController];
    }
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

- (IBAction)cloudTapped:(id)sender {
    NSLog(@"cloudTapped");
    if ([self.textView.text length] > 0) {
        [self checkForToDoInString:self.textView.text];
        
        if (self.file) {
            [self.file writeString:self.textView.text error:nil];
        } else { //Create new file
            UIAlertView *av =
            [[UIAlertView alloc]
             initWithTitle:@"Filename" message:@"Please enter a filename" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            av.alertViewStyle = UIAlertViewStylePlainTextInput;
            av.tag = 12;
            
            [av addButtonWithTitle:@"Submit"];
            [av show];
        }
    }
}

- (void)checkForToDoInString:(NSString*)string {
    [self.regex enumerateMatchesInString:string options:0
                                   range:NSMakeRange(0, 5)
                              usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                                  if(!self.store) {
                                      self.store = [[EKEventStore alloc] init];
                                      [self.store requestAccessToEntityType:EKEntityTypeReminder
                                                                 completion:^(BOOL granted, NSError *error) {
                                                                     if (granted) {
                                                                         [self storeReminderString:string];
                                                                     }
                                                                 }];
                                  } else if ([EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder] == EKAuthorizationStatusAuthorized) {
                                      [self storeReminderString:string];
                                  }
                              }];
}

- (void)storeReminderString:(NSString*)string {
    NSLog(@"Storing reminder %@",string);
    
    EKReminder *reminder = [EKReminder reminderWithEventStore:self.store];
    [reminder setTitle: [string substringWithRange:NSMakeRange(5, [string length] - 5)]];
    EKCalendar *defaultReminderList = [self.store defaultCalendarForNewReminders];
    
    [reminder setCalendar:defaultReminderList];
    
    NSError *error = nil;
    BOOL success = [self.store saveReminder:reminder
                                     commit:YES
                                      error:&error];
    if (!success) {
        NSLog(@"Error saving reminder: %@", [error localizedDescription]);
    }
   
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
