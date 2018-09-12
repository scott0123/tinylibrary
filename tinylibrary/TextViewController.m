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
            // Scroll to where it was before
            // load the data from user preferences if applicable
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* key = [NSString stringWithFormat:@"%@+%@", self.document.fileURL.absoluteString, @"scrollOffset"];
            CGPoint scrollOffset = CGPointFromString([defaults objectForKey:key]);
            // there is currently a bug where changing animated to NO makes it not scroll at all
            [self.contentView setContentOffset:scrollOffset animated:YES];
        } else {
            // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        }
    }];
}

- (IBAction)donePressed {
    // Save the current scroll offset
    // save it directly to user preferences
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"%@+%@", self.document.fileURL.absoluteString, @"scrollOffset"];
    CGPoint scrollOffset = self.contentView.contentOffset;
    [defaults setObject:NSStringFromCGPoint(scrollOffset) forKey:key];
    [defaults synchronize];
    // dismiss this view controller
    [self dismissDocumentViewController];
}

- (void)dismissDocumentViewController {
    [self dismissViewControllerAnimated:YES completion:^ {
        [self.document closeWithCompletionHandler:nil];
    }];
}

-(BOOL)prefersStatusBarHidden{
    // make the top bar hidden (we could somehow display time/battery by drawing it later)
    return YES;
}

@end
