//
//  GistDetailsViewController.h
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Gist;

@interface GistDetailsViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) Gist* gist;
@property (assign, nonatomic) BOOL onlyOriginalInfo;

@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *gistNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UILabel *notesNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;


@end
