//
//  GistDetailsViewController.h
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Gist;

@interface GistDetailsViewController : UIViewController

@property (strong, nonatomic) Gist* gist;

@end
