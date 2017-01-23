//
//  GistsViewController.m
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import "GistsViewController.h"
#import "GistDetailsViewController.h"

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
    
    [self refreshData];
    
    self.navigationItem.title = @"All Gists";
    
    currentDateFormat = [NSDateFormatter new];
    [currentDateFormat setDateFormat:@"HH:mm dd.MM.yyyy"];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];

    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)refreshData {
    [[ServerManager sharedManager] getPublicGistsFromServerOnSuccess:^(NSMutableArray *gists) {
        
        self.page = 1;
        self.gists = gists;
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        
    } onFailure:^(NSError *error) {
        
    }];
}


- (void)loadExtraData {
    self.page++;
    
    [[ServerManager sharedManager]
     getExtraPublicGistsFromServerOnPage:self.page
     
     onSuccess:^(NSMutableArray *gists) {
         [self.gists addObjectsFromArray:gists];
         [self.tableView reloadData];
         
     }
     onFailure:^(NSError *error) {
        
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.gists count];
}


- (GistsListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GistsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Gist* gist = self.gists[indexPath.row];
    
    cell.ownerLoginLabel.text = gist.ownerLogin;
    cell.nameLabel.text = gist.name;
    cell.dateLabel.text = [currentDateFormat stringFromDate:gist.createDate];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GistDetailsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GistDetailsVC"];
    vc.gist = self.gists[indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.gists count] - 40) {
        [self loadExtraData];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
