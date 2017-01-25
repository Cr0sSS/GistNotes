//
//  AllInOneViewController.m
//  GistNotes
//
//  Created by Admin on 25.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import "AllInOneViewController.h"
#import "GistDetailsViewController.h"

#import "ServerManager.h"
#import "DataManager.h"

#import "GistsListCell.h"
#import "Gist+CoreDataClass.h"


@interface AllInOneViewController ()

@property (strong, nonatomic) NSMutableArray* gists;
@property (strong, nonatomic) NSArray* notes;

@property (assign, nonatomic) NSInteger page;

@end

@implementation AllInOneViewController

static NSDateFormatter* currentDateFormat;
static NSString* const cellIdentifier = @"GistsListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"All-In-One";
    
    currentDateFormat = [NSDateFormatter new];
    [currentDateFormat setDateFormat:@"HH:mm dd.MM.yyyy"];
    
    self.gistsTableView.refreshControl = [UIRefreshControl new];
    [self.gistsTableView.refreshControl addTarget:self action:@selector(refreshGistsData) forControlEvents:UIControlEventValueChanged];
    
    [self refreshGistsData];
}


- (void)viewDidAppear:(BOOL)animated {
    [self.gistsTableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fillNotesArray];
        [self.notesTableView reloadData];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Data

- (void)refreshGistsData {
    self.page = 1;
    
    [[ServerManager sharedManager]
     getPublicGistsFromServerOnPage:self.page
     onSuccess:^(NSMutableArray *gists) {
         
         self.gists = gists;
         [self.gistsTableView.refreshControl endRefreshing];
         [self.gistsTableView reloadData];
     }
     onFailure:^(NSError *error) {
         
     }];
}


- (void)loadExtraGistsData {
    self.page++;
    
    [[ServerManager sharedManager]
     getPublicGistsFromServerOnPage:self.page
     onSuccess:^(NSMutableArray *gists) {
         
         [self.gists addObjectsFromArray:gists];
         [self.gistsTableView reloadData];
     }
     onFailure:^(NSError *error) {
         
         
     }];
}


- (void)fillNotesArray {
    self.notes = [[DataManager sharedManager] gistsWithNotes];
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [tableView isEqual:self.gistsTableView] ? @"Gists" : @"Notes";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableView isEqual:self.gistsTableView] ? [self.gists count] : [self.notes count];
}


- (GistsListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GistsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Gist* gist;
    if ([tableView isEqual:self.gistsTableView]) {
        gist = self.gists[indexPath.row];
        cell.noteLabel.hidden = !gist.edited;

        NSString* name = gist.name;
        cell.nameLabel.text = [name isEqualToString:@""] ? @"<no name>" : name;
        
    } else {
        gist = self.notes[indexPath.row];

        if (![gist.changedName isEqualToString:@""]) {
            cell.nameLabel.text = gist.changedName;
        } else {
            NSString* name = gist.name;
            cell.nameLabel.text = [name isEqualToString:@""] ? @"<no name>" : name;
        }
    }

    cell.ownerLoginLabel.text = gist.ownerLogin ? gist.ownerLogin : @"<no author>";
    cell.dateLabel.text = [currentDateFormat stringFromDate:gist.createDate];
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GistDetailsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GistDetailsVC"];
    vc.gist = [tableView isEqual:self.gistsTableView] ? self.gists[indexPath.row] : self.notes[indexPath.row];
    vc.onlyOriginalInfo = NO;
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual:self.gistsTableView]) {
        if (indexPath.row == [self.gists count] - 40) {
            [self loadExtraGistsData];
        }
    }
}

@end
