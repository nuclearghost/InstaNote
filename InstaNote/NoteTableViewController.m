//
//  NoteTableViewController.m
//  InstaNote
//
//  Created by Mark Meyer on 5/17/14.
//  Copyright (c) 2014 Mark Meyer. All rights reserved.
//

#import "NoteTableViewController.h"

@interface NoteTableViewController ()

@property (nonatomic, assign) BOOL loadingFiles;
@property (strong, nonatomic) NSMutableArray *contents;

@end

@implementation NoteTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.contents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    DBFileInfo *info = [_contents objectAtIndex:[indexPath row]];
    cell.textLabel.text = [info.path name];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((NSInteger)[_contents count] <= [indexPath row]) return;
    
    DBFileInfo *info = [_contents objectAtIndex:[indexPath row]];
    DBFile *file = [[[DBManager sharedManager] getFileSystem] openFile:info.path error:nil];

    
    [self performSegueWithIdentifier:@"noteSegue" sender:file];
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"noteSegue"]) {
        NoteViewController *nvc = (NoteViewController*)[segue destinationViewController];
        nvc.file = (DBFile*)sender;
    }
}


- (void)loadFiles {
    if (_loadingFiles) return;
    _loadingFiles = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
        NSArray *immContents = [[[DBManager sharedManager] getFileSystem] listFolder:[DBPath root] error:nil];
        NSMutableArray *mContents = [NSMutableArray arrayWithArray:immContents];
        //[mContents sortUsingFunction:sortFileInfos context:NULL];
        dispatch_async(dispatch_get_main_queue(), ^() {
            self.contents = mContents;
            _loadingFiles = NO;
            [self.tableView reloadData];
        });
    });
}
- (IBAction)addTapped:(id)sender {
    NSLog(@"addTapped");
    [self performSegueWithIdentifier:@"noteSegue" sender:nil];
}
@end
