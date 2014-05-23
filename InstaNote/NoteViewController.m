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
@property BOOL pictureMode;

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
    
    self.pictureMode = NO;
    self.imgView.hidden = YES;
    self.captionField.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.file) {
        self.navigationItem.title = self.file.info.path.name;
        NSString *extension = [self.file.info.path.name substringFromIndex:([self.file.info.path.name length] - 3)];
        if ([extension isEqualToString:@"txt"]) {
            self.textView.text = [self.file readString:nil];
            self.pictureMode = NO;
            self.imgView.hidden = YES;
            self.captionField.hidden = YES;
        } else {
            self.imgView.image = [[UIImage alloc] initWithData:[self.file readData:nil]];
            self.pictureMode = YES;
            self.imgView.hidden = NO;
            self.captionField.hidden = NO;
            self.textView.hidden = YES;
        }
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[DBManager sharedManager] accountAvailable]) {
        [[[UIAlertView alloc]
          initWithTitle:@"Link Account" message:@"You must link your dropbox account to proceed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]
         show];
    } else if (self.pictureMode) {
        [self.captionField becomeFirstResponder];
    } else {
        [self.textView becomeFirstResponder];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.file) {
        [self.file close];
    }
        
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Alert View

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 12) {
        if (buttonIndex == 1) {
            UITextField *textfield = [alertView textFieldAtIndex:0];
            NSLog(@"filename: %@", textfield.text);
            [[DBManager sharedManager] creatFile:textfield.text withExtension:self.pictureMode ? @"jpg" : @"txt" completion:^(BOOL completed, DBFile *file) {
                if (completed) {
                    self.file = file;
                    self.navigationItem.title = self.file.info.path.name;
                    if (self.pictureMode) {
                        [self.file writeData:UIImageJPEGRepresentation(self.imgView.image, 0.7) error:nil];
                    } else {
                        [self.file writeString:self.textView.text error:nil];
                    }
                } else {
                    //TODO alert or something
                }
            }];
        }
    } else {
        [[DBManager sharedManager] initializeAccountLinkFromView:self.navigationController];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"caption done tapped");
    return YES;
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
    [self.textView endEditing:YES];
    self.pictureMode = YES;
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
    if (self.pictureMode) {
        [self overlayText];
        if (self.file) {
            [self.file writeData:UIImageJPEGRepresentation(self.imgView.image, 0.7) error:nil];
        } else {
            [self alertForFilename];
        }
    } else {
        if ([self.textView.text length] > 0) {
            [self checkForToDoInString:self.textView.text];
            
            if (self.file) {
                [self.file writeString:self.textView.text error:nil];
            } else { //Create new file
                [self alertForFilename];
            }
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

//From this SO question http://stackoverflow.com/questions/6992830/how-to-write-text-on-image-in-objective-c-iphone

- (void)overlayText {
    if (self.captionField.text.length > 0) {
        UIFont *font = [UIFont systemFontOfSize:92];
        UIGraphicsBeginImageContext(self.imgView.image.size);
        [self.imgView.image drawInRect:CGRectMake(0,0, self.imgView.image.size.width, self.imgView.image.size.height)];
        CGRect rect = CGRectMake(0, 0, self.imgView.image.size.width, self.imgView.image.size.height);
        [self.captionField.text drawInRect:CGRectIntegral(rect) withAttributes:@{NSFontAttributeName: font,
                                                                                 NSForegroundColorAttributeName: [UIColor whiteColor]}];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.imgView.image = newImage;
    }
}

-(void)alertForFilename {
    UIAlertView *av =
    [[UIAlertView alloc]
     initWithTitle:@"Filename" message:@"Please enter a filename" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    av.tag = 12;
    
    [av addButtonWithTitle:@"Submit"];
    [av show];
}

#pragma mark - DBCameraViewControllerDelegate

- (void) captureImageDidFinish:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    self.imgView.image = image;
    
    self.textView.hidden = YES;
    
    self.imgView.hidden = NO;
    self.captionField.hidden = NO;
    [self.captionField becomeFirstResponder];
    
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
