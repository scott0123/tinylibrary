//
//  TextViewController.m
//  tinylibrary
//
//  Created by ScottLiu on 9/10/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import "TextViewController.h"

@interface TextViewController()

@property (strong, nonatomic) IBOutlet UITextView *contentView;

@end

@implementation TextViewController
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Access the document
    [self.document openWithCompletionHandler:^(BOOL success) {
        if (success) {
            // Display the content of the document, e.g.:
            self.contentView.text = self.document.contents;
        } else {
            // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        }
    }];
}

- (IBAction)dismissDocumentViewController {
    [self dismissViewControllerAnimated:YES completion:^ {
        [self.document closeWithCompletionHandler:nil];
    }];
}

-(BOOL)prefersStatusBarHidden{
    // make the top bar hidden (we could somehow display time/battery by drawing it later)
    return YES;
}

@end
