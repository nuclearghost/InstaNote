//
//  NoteViewController.h
//  InstaNote
//
//  Created by Mark Meyer on 5/14/14.
//  Copyright (c) 2014 Mark Meyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteViewController : UIViewController <UITextViewDelegate>

- (IBAction)listTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
