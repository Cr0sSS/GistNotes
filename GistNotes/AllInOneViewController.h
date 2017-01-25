//
//  AllInOneViewController.h
//  GistNotes
//
//  Created by Admin on 25.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllInOneViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *gistsTableView;
@property (weak, nonatomic) IBOutlet UITableView *notesTableView;

@end
