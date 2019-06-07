//
//  DocumentBrowserViewController.m
//  tinylibrary
//
//  Created by ScottLiu on 9/10/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import "DocumentBrowserViewController.h"
#import "Document.h"
#import "DocumentViewController.h"
#import "TextViewController.h"
#import "HTMLViewController.h"

@interface DocumentBrowserViewController () <UIDocumentBrowserViewControllerDelegate>

@end

@implementation DocumentBrowserViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.allowsDocumentCreation = YES;
    self.allowsPickingMultipleItems = NO;
    
    // Update the style of the UIDocumentBrowserViewController
    // self.browserUserInterfaceStyle = UIDocumentBrowserUserInterfaceStyleDark;
    // self.view.tintColor = [UIColor whiteColor];
    
    // Specify the allowed content types of your application via the Info.plist.
    
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark UIDocumentBrowserViewControllerDelegate

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didRequestDocumentCreationWithHandler:(void (^)(NSURL * _Nullable, UIDocumentBrowserImportMode))importHandler {
    NSURL *newDocumentURL = nil;
    
    // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
    // Make sure the importHandler is always called, even if the user cancels the creation request.
    if (newDocumentURL != nil) {
        importHandler(newDocumentURL, UIDocumentBrowserImportModeMove);
    } else {
        importHandler(newDocumentURL, UIDocumentBrowserImportModeNone);
    }
}

-(void)documentBrowser:(UIDocumentBrowserViewController *)controller didPickDocumentURLs:(NSArray<NSURL *> *)documentURLs {
    NSURL *sourceURL = documentURLs.firstObject;
    if (!sourceURL) {
        return;
    }
    
    // Present the Document View Controller for the first document that was picked.
    // If you support picking multiple items, make sure you handle them all.
    [self presentDocumentAtURL:sourceURL];
}

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didImportDocumentAtURL:(NSURL *)sourceURL toDestinationURL:(NSURL *)destinationURL {
    // Present the Document View Controller for the new newly created document
    [self presentDocumentAtURL:destinationURL];
}

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller failedToImportDocumentAtURL:(NSURL *)documentURL error:(NSError * _Nullable)error {
    // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
}

// MARK: Document Presentation

- (void)presentDocumentAtURL:(NSURL *)documentURL {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // IF TEXT FILE
    if ([documentURL.pathExtension isEqual:@"txt"]){
        TextViewController *textViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TextViewController"];
        textViewController.document = [[Document alloc] initWithFileURL:documentURL];
        [self presentViewController:textViewController animated:NO completion:nil];
    } else if ([documentURL.pathExtension isEqual:@"html"]){
        // IF HTML FILE
        HTMLViewController *htmlViewController = [storyBoard instantiateViewControllerWithIdentifier:@"HTMLViewController"];
        htmlViewController.document = [[Document alloc] initWithFileURL:documentURL];
        [self presentViewController:htmlViewController animated:NO completion:nil];
    }  else if ([documentURL.pathExtension isEqual:@"rtf"]){
        // IF RTF FILE
        TextViewController *textViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TextViewController"];
        textViewController.document = [[Document alloc] initWithFileURL:documentURL];
        [self presentViewController:textViewController animated:NO completion:nil];
    } else {
        // IF NOT TEXT FILE
        printf("Non-text extension: %s", [documentURL.pathExtension UTF8String]);
        DocumentViewController *documentViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DocumentViewController"];
        documentViewController.document = [[Document alloc] initWithFileURL:documentURL];
        [self presentViewController:documentViewController animated:YES completion:nil];
    }
}

@end
