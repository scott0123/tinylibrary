//
//  ShareViewController.m
//  tinylibraryshare
//
//  Created by ScottLiu on 5/23/19.
//  Copyright © 2019 Scott Liu. All rights reserved.
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UserNotifications/UserNotifications.h>


@interface ShareViewController ()
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *filenameTextView;
@property (strong) NSString* urlString;
@property (strong) NSString* titleString;

@end

@implementation ShareViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = item.attachments.firstObject;
    if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList
                                        options:nil
                              completionHandler:^(NSDictionary *dictionary, NSError *error) {
                                  NSDictionary *results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey];
                                  self.titleString = results[@"title"];
                                  self.urlString = results[@"url"];
                                  printf("Title: %s\n", self.titleString.UTF8String);
                                  printf("URL: %s\n", self.urlString.UTF8String);
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self.filenameTextView setText:self.titleString];
                                      [self.filenameTextView becomeFirstResponder];
                                  });
                              }];
    }
    printf("view appeared\n");
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (IBAction)cancel:(UIButton *)sender {
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* groupContainerURL = [fm containerURLForSecurityApplicationGroupIdentifier:@"group.com.scott-liu.tinylibrary"];
    
    printf("testPath: %s\n", groupContainerURL.path.UTF8String);
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}
- (IBAction)save:(UIButton *)sender {
    // if the url or name is not available, dont do it
    if(([self.titleString length] == 0) || ([self.urlString length] == 0)){
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }
    // Send to server
    NSString* base_url = @"http://heckyesmarkdown.com/go/";
    NSString* full_url = [NSString stringWithFormat:@"%@?u=%@&read=1&md=0", base_url, self.urlString];
    NSURL* url = [NSURL URLWithString:full_url];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        printf("http response: %ld\n", (long)httpResponse.statusCode);
        if(httpResponse.statusCode == 200) {
            NSString *pageString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *fileName = [NSString stringWithFormat:@"%@.html", self.titleString];
            
            NSFileManager* fileManager = [NSFileManager defaultManager];
            NSURL* groupContainerURL = [fileManager containerURLForSecurityApplicationGroupIdentifier:@"group.com.scott-liu.tinylibrary"];
            
            NSString* filePath = [groupContainerURL.path stringByAppendingPathComponent:fileName];
            [pageString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            printf("saved to %s\n", filePath.UTF8String);
            dispatch_async(dispatch_get_main_queue(), ^{
                // maybe add a loading bar
                NSMutableDictionary* info = [NSMutableDictionary dictionary];
                [info setValue:fileName forKey:@"fileName"];
                [info setValue:filePath forKey:@"filePath"];
                [self sendNotification: info];
                [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
            });
        }
    }];
    printf("Sending HTTP GET...\n");
    [dataTask resume];
    // disable the interface
    [self.cancelButton setEnabled:NO];
    [self.saveButton setEnabled:NO];
    [self.titleLabel setText:@"Please wait..."];
    [self.filenameTextView setTextColor:[UIColor lightGrayColor]];
}

-(void)sendNotification:(NSDictionary*) info{
    printf("Sending local notification\n");
    UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
    objNotificationContent.title = [NSString localizedUserNotificationStringForKey:@"Ready!" arguments:nil];
    objNotificationContent.body = [NSString localizedUserNotificationStringForKey:@"Tap here to read it in tinylibrary"
                                                                        arguments:nil];
    objNotificationContent.sound = [UNNotificationSound defaultSound];
    objNotificationContent.userInfo = info;
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1f repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"notification.com.scott-liu.tinylibrary"
                                                                          content:objNotificationContent trigger:trigger];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Local Notification succeeded");
        }
        else {
            NSLog(@"Local Notification failed");
        }
    }];
    // try to get rid of the notification after 5 seconds
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(cancelDeliveredNotification)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)cancelDeliveredNotification {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllDeliveredNotifications];
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}
@end
