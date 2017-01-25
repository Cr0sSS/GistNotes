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
    
    [[ServerManager sharedManager] getExtraPublicGistsFromServerOnPage:self.page
     
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
    
    NSString* name = gist.name;
    if ([name isEqualToString:@""]) {
        cell.nameLabel.text = @"<no name>";
        
    } else {
        cell.nameLabel.text = name;
    }
    
    cell.ownerLoginLabel.text = gist.ownerLogin ? gist.ownerLogin : @"<no author>";
    cell.dateLabel.text = [currentDateFormat stringFromDate:gist.createDate];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
