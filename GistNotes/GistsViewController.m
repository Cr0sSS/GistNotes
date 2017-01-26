//
//  GistsViewController.m
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import "GistsViewController.h"
#import "GistDetailsViewController.h"
#import "ErrorController.h"

#import "GistsListCell.h"
#import "ServerManager.h"
#import "Gist+CoreDataClass.h"


@interface GistsViewController ()

@property (strong, nonatomic) NSMutableArray* gists;
@property (assign, nonatomic) NSInteger page;

@end

@implementation GistsViewController

static NSDateFormatter* currentDateFormat;
static NSString* const cellIdentifier = @"GistsListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"All Gists";
    
    currentDateFormat = [NSDateFormatter new];
    [currentDateFormat setDateFormat:@"HH:mm dd.MM.yyyy"];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    [self refreshData];
}


- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Data

- (void)refreshData {
    self.page = 1;
    
    [[ServerManager sharedManager]
     getPublicGistsFromServerOnPage:self.page
     onSuccess:^(NSMutableArray *gists) {
        
        self.gists = gists;
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        
     }
     onFailure:^(NSError *error) {
         [self showError:error];
     }];
}


- (void)loadExtraData {
    self.page++;
    
    [[ServerManager sharedManager]
     getPublicGistsFromServerOnPage:self.page
     onSuccess:^(NSMutableArray *gists) {
         [self.gists addObjectsFromArray:gists];
         [self.tableView reloadData];
         
     }
     onFailure:^(NSError *error) {
         [self showError:error];
     }];
}


#pragma mark - Error

- (void)showError:(NSError*)error {
    [ErrorController errorControllerWithTitle:@"Gists View Error" message:[error localizedDescription]];
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
    
    NSString* name = gist.name;
    cell.nameLabel.text = [name isEqualToString:@""] ? @"<no name>" : name;
    
    cell.ownerLoginLabel.text = gist.ownerLogin ? gist.ownerLogin : @"<no author>";
    cell.dateLabel.text = [currentDateFormat stringFromDate:gist.createDate];
    
    cell.noteLabel.hidden = !gist.edited;
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


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.gists count] - 40) {
        [self loadExtraData];
    }
}

@end
