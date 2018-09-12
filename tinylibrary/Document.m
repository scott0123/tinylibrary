//
//  Document.m
//  tinylibrary
//
//  Created by ScottLiu on 9/10/18.
//  Copyright © 2018 Scott Liu. All rights reserved.
//

#import "Document.h"

@implementation Document

// This method is called by the UIDocument subclass instance when data is to be written to the file or document. The method is responsible for gathering the data to be written and returning it in the form of a Data or FileWrapper object.
- (id)contentsForType:(NSString*)typeName error:(NSError **)errorPtr {
    // Encode your document with an instance of NSData or NSFileWrapper
    return [[NSData alloc] init];
}

// Called by the subclass instance when data is being read from the file or document. The method is passed the content that has been read from the file by the UIDocument subclass and is responsible for loading that data into the application’s internal data model.
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)errorPtr {
    // Load your document from contents
    if([typeName isEqual: @"public.plain-text"]){
        self.contents = [NSString stringWithUTF8String:[contents bytes]];
    } else {
        printf("Unexpected type: %s\n", [typeName UTF8String]);
    }
    return YES;
}

@end
