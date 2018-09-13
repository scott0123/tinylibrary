//
//  TextViewController.m
//  tinylibrary
//
//  Created by ScottLiu on 9/10/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import "TextViewController.h"

@interface TextViewController()

@property (strong, nonatomic) IBOutlet UILabel *nightModeLabel;
@property (strong, nonatomic) IBOutlet UITextView *contentView;

@end

@implementation TextViewController
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Register for when this app will resign active ad go to the background
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(viewWillResignActive)
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
    
    // Access the document
    [self.document openWithCompletionHandler:^(BOOL success) {
        if (success) {
            // Display the content of the document, e.g.:
            self.contentView.text = self.document.contents;
            
            // need to load the progress slightly after since the text takes a while to fully load
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loadProgress];
            });
        } else {
            // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (IBAction)donePressed {
    
    // dismiss this view controller
    [self dismissDocumentViewController];
}
- (IBAction)NightModeChanged:(UISwitch *)sender {
    if(sender.isOn){
        self.view.backgroundColor = [UIColor blackColor];
        self.contentView.backgroundColor = [UIColor blackColor];
        self.contentView.textColor = [UIColor whiteColor];
        self.nightModeLabel.textColor = [UIColor whiteColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.textColor = [UIColor blackColor];
        self.nightModeLabel.textColor = [UIColor blackColor];
    }
}

- (void)loadProgress {
    // Scroll to where it was before
    // load the data from user preferences if applicable
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"%@+%@", self.document.fileURL.absoluteString, @"scrollPosition"];
    NSInteger scrollPosition = [[defaults objectForKey:key] longValue];
    [self.contentView scrollRangeToVisible:NSMakeRange(scrollPosition, 1)];
    printf("Loading offset: %ld\n", scrollPosition);
    
    
    /* Doesnt work well with very large text files
     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
     NSString* key = [NSString stringWithFormat:@"%@+%@", self.document.fileURL.absoluteString, @"scrollOffset"];
     CGPoint scrollOffset = CGPointFromString([defaults objectForKey:key]);
     [self.contentView setContentOffset:scrollOffset animated:YES];
     printf("restored offset to %f\n", scrollOffset.y);
     */
}

- (void) saveProgress {
    // Save the current scroll offset
    // save it directly to user preferences
    CGRect bounds = self.contentView.bounds;
    CGPoint boundEnd = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"%@+%@", self.document.fileURL.absoluteString, @"scrollPosition"];
    UITextPosition* lastWord = [self.contentView characterRangeAtPoint:boundEnd].start;
    NSInteger scrollPosition = [self.contentView offsetFromPosition:self.contentView.beginningOfDocument toPosition:lastWord];
    [defaults setObject:[NSNumber numberWithLong:scrollPosition] forKey:key];
    printf("Storing offset %ld\n", scrollPosition);
    [defaults synchronize];
    
    
    /* Doesnt work well with very large text files
     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
     printf("current offset %f\n", self.contentView.contentOffset.y);
     NSString* key = [NSString stringWithFormat:@"%@+%@", self.document.fileURL.absoluteString, @"scrollOffset"];
     CGPoint scrollOffset = self.contentView.contentOffset;
     [defaults setObject:NSStringFromCGPoint(scrollOffset) forKey:key];
     printf("storing offset %f\n", self.contentView.contentOffset.y);
     [defaults synchronize];
     */
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self saveProgress];
}

// put the progress saving code here as well in case user accidentally force quits
- (void)viewWillResignActive{
    [self saveProgress];
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
