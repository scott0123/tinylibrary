//
//  HTMLViewController.m
//  tinylibrary
//
//  Created by ScottLiu on 6/6/19.
//  Copyright © 2019 Scott Liu. All rights reserved.
//

#import "HTMLViewController.h"

@interface HTMLViewController()

@property (strong, nonatomic) IBOutlet UILabel *nightModeLabel;
@property (strong, nonatomic) IBOutlet WKWebView *webView;

@property (strong, nonatomic) IBOutlet UISlider *autoscrollSlider;
@property (strong, nonatomic) NSTimer *autoscrollTimer;
@property (strong, nonatomic) NSString* dayCSS;
@property (strong, nonatomic) NSString* nightCSS;

@end

@implementation HTMLViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // dont sleep
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    // Register for when this app will resign active and go to the background
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(viewWillResignActive)
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
    
    
    NSString* resources = [[NSBundle mainBundle] resourcePath];
    NSString* dayPath = [resources stringByAppendingPathComponent:@"day.css"];
    NSString* nightPath = [resources stringByAppendingPathComponent:@"night.css"];
    self.dayCSS = [NSString stringWithContentsOfFile:dayPath encoding:NSUTF8StringEncoding error:nil];
    self.nightCSS = [NSString stringWithContentsOfFile:nightPath encoding:NSUTF8StringEncoding error:nil];
    
    // Access the document
    [self.document openWithCompletionHandler:^(BOOL success) {
        if (success) {
            // Display the content of the document, e.g.:
            // my sample code to load google
            //NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]];
            //[self.webView loadRequest:req];
            
            NSString* contents = self.document.contents;
            NSString* htmlString = [NSString stringWithFormat:@"<html>\
                                    <head>\
                                    <link rel=\"stylesheet\" href=\"day.css\">\
                                    </head>\
                                    <body>\
                                    %@\
                                    </body>", contents];
            [self.webView loadHTMLString:htmlString baseURL:[NSBundle mainBundle].resourceURL];
            
            
            // need to load the progress slightly after since the text takes a while to fully load
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self loadProgress];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // autoscroll feature
                    self.autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:(0.03)
                                                                            target:self selector:@selector(autoscrollTimerFired) userInfo:nil repeats:YES];
                });
            });
        } else {
            // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        }
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    NSString *cssString = [self.dayCSS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)";
    NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString];
    [webView evaluateJavaScript:javascriptWithCSSString completionHandler:nil];
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
        self.webView.backgroundColor = [UIColor blackColor];
        // not sure how to do this just yet
        //self.webView.textColor = [UIColor whiteColor];
        self.nightModeLabel.textColor = [UIColor whiteColor];
        
        NSString *cssString = [self.nightCSS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)";
        NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString];
        [self.webView evaluateJavaScript:javascriptWithCSSString completionHandler:nil];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.webView.backgroundColor = [UIColor whiteColor];
        //self.webView.textColor = [UIColor blackColor];
        self.nightModeLabel.textColor = [UIColor blackColor];
        
        NSString *cssString = [self.dayCSS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)";
        NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString];
        [self.webView evaluateJavaScript:javascriptWithCSSString completionHandler:nil];
    }
}

- (void)loadProgress {
    // Scroll to where it was before
    // load the data from user preferences if applicable
    /*
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"%@+%@", self.document.fileURL.absoluteString, @"scrollRect"];
    NSData* rectData = [defaults objectForKey:key];
    CGRect scrollRect = [[NSKeyedUnarchiver unarchiveObjectWithData:rectData] CGRectValue];
    NSLog(@"%@", NSStringFromCGRect(scrollRect));
    CGRect scrollRect2 = CGRectMake(100, 100, 120, 120);
    [self.webView.scrollView scrollRectToVisible:scrollRect2 animated:NO];
    */
    
     // Doesnt work well with very large text files
     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
     NSString* key = [NSString stringWithFormat:@"%@+%@", self.document.fileURL.absoluteString, @"scrollOffset"];
     CGPoint scrollOffset = CGPointFromString([defaults objectForKey:key]);
     [self.webView.scrollView setContentOffset:scrollOffset animated:YES];
     printf("restored offset to %f\n", scrollOffset.y);
    
}

- (void) saveProgress {
    // Save the current visible scroll rect
    // save it directly to user preferences
    /*
    CGRect scrollRect = CGRectMake(self.webView.scrollView.contentOffset.x, self.webView.scrollView.contentOffset.y, self.webView.scrollView.contentOffset.x + self.webView.scrollView.bounds.size.width, self.webView.scrollView.contentOffset.y + self.webView.scrollView.bounds.size.height);
    NSLog(@"%@", NSStringFromCGRect(scrollRect));
    NSData* rectData = [NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:scrollRect]];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"%@+%@", self.document.fileURL.absoluteString, @"scrollRect"];
    [defaults setObject:rectData forKey:key];
    [defaults synchronize];
    */
    
     // Doesnt work well with very large text files
     NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
     printf("current offset %f\n", self.webView.scrollView.contentOffset.y);
     NSString* key = [NSString stringWithFormat:@"%@+%@", self.document.fileURL.absoluteString, @"scrollOffset"];
     CGPoint scrollOffset = self.webView.scrollView.contentOffset;
     [defaults setObject:NSStringFromCGPoint(scrollOffset) forKey:key];
     printf("storing offset %f\n", self.webView.scrollView.contentOffset.y);
     [defaults synchronize];
    
}

- (void)autoscrollTimerFired {
    
    float scrollSpeed = self.autoscrollSlider.value;
    scrollSpeed *= scrollSpeed;
    CGPoint scrollPoint = self.webView.scrollView.contentOffset;
    scrollPoint = CGPointMake(scrollPoint.x, scrollPoint.y + scrollSpeed);
    [self.webView.scrollView setContentOffset:scrollPoint animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self saveProgress];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
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
