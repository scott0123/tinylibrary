//
//  HTMLViewController.h
//  tinylibrary
//
//  Created by ScottLiu on 6/6/19.
//  Copyright © 2019 Scott Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "Document.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTMLViewController : UIViewController <WKNavigationDelegate>

@property (strong) Document *document;

@end

NS_ASSUME_NONNULL_END
