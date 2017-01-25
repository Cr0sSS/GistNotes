//
//  NotesViewController.m
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import "NotesViewController.h"
#import "GistDetailsViewController.h"

#import "GistsListCell.h"
#import "DataManager.h"
#import "Gist+CoreDataClass.h"


@interface NotesViewController ()

@property (strong, nonatomic) NSArray* gists;

@end

@implementation NotesViewController

static NSDateFormatter* currentDateFormat;
static NSString* const cellIdentifier = @"GistsListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"My Notes";

    currentDateFormat = [NSDateFormatter new];
    [currentDateFormat setDateFormat:@"HH:mm dd.MM.yyyy"];

    [self fillMainArray];
}


- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Data

- (void)fillMainArray {
    self.gists = [[DataManager sharedManager] gistsWithNotes];
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.gists count];
}


- (GistsListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GistsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Gist* gist = self.gists[indexPath.row];
    
    if (![gist.changedName isEqualToString:@""]) {
        cell.nameLabel.text = gist.changedName;
    } else {
        NSString* name = gist.name;
        cell.nameLabel.text = [name isEqualToString:@""] ? @"<no name>" : name;
    }
    
    cell.ownerLoginLabel.text = gist.ownerLogin ? gist.ownerLogin : @"<no author>";
    cell.dateLabel.text = [currentDateFormat stringFromDate:gist.createDate];
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GistDetailsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GistDetailsVC"];
    vc.gist = self.gists[indexPath.row];
    vc.onlyOriginalInfo = NO;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
