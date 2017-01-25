//
//  GistDetailsViewController.m
//  GistNotes
//
//  Created by Admin on 22.01.17.
//  Copyright © 2017 Andrey Kuznetsov. All rights reserved.
//

#import "GistDetailsViewController.h"

#import "Gist+CoreDataClass.h"

#import <UIImageView+AFNetworking.h>


@interface GistDetailsViewController ()

@end

@implementation GistDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.onlyOriginalInfo) {
        self.navigationItem.title = @"Original Gist Info";
        
        [self showOriginalGistInfo];
        [self disableEditing];
        
    } else {
        self.navigationItem.title = @"Details";
        
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"OriginalGist"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(actionShowOriginalGist)];
        self.navigationItem.rightBarButtonItem = button;
        
        if (self.gist.edited) {
            [self showNoteInfo];
        } else {
            [self showOriginalGistInfo];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    if (!self.onlyOriginalInfo) {
        [self checkChanges];
    }
}


#pragma mark - View Data

- (void)showNoteInfo {
    [self showOwnerInfo];
    self.nameTextField.text = self.gist.changedName;
    self.notesTextView.text = self.gist.note;
}


- (void)showOriginalGistInfo {
    [self showOwnerInfo];
    self.nameTextField.text = self.gist.name;
}


- (void)disableEditing {
    self.gistNameLabel.text = @"Original Gist Name";
    self.notesNameLabel.hidden = YES;
    self.notesTextView.hidden = YES;
    
    
}


- (void)showOwnerInfo {
    self.loginLabel.text = self.gist.ownerLogin;
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.gist.avatarURLString]];
    __weak UIImageView* weakImageView = self.avatarImageView;
    
    [self.avatarImageView setImageWithURLRequest:request
                                placeholderImage:nil
                                         success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                             
                                             weakImageView.image = image;
                                             [weakImageView layoutSubviews];
                                         }
                                         failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
                                         }];
}


#pragma mark - Actions

- (void)actionShowOriginalGist {
    [self checkChanges];
    
    GistDetailsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GistDetailsVC"];
    
    vc.gist = self.gist;
    vc.onlyOriginalInfo = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)checkChanges {
    NSString* newName = self.nameTextField.text;
    NSString* newNote = self.notesTextView.text;
        
    if (self.gist.edited && ![newName isEqualToString:self.gist.changedName]) {
        [self saveNote];
        
    } else if (![newName isEqualToString:self.gist.name] || ![newNote isEqualToString:self.gist.note]) {
        [self saveNote];
    }
}


- (void)saveNote {
    self.gist.edited = YES;
    self.gist.note = self.notesTextView.text;
    self.gist.changedName = self.nameTextField.text;
    
    [self.gist.managedObjectContext save:nil];
}


#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return !self.onlyOriginalInfo;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return NO;
}

@end
