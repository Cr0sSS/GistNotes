//
//  GistsListCell.h
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GistsListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ownerLoginLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
