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
        // this is legacy code that doesnt take into account different text encoding schemes
        //self.contents = [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
        
        // we shall take the first 128 bytes from the content and analyze it to see what encoding the text is using
        NSData* subdata = nil;
        unsigned int subdata_max_range = 128;
        if([contents length] < 128) {
            subdata_max_range = (unsigned int)[contents length];
        }
        subdata = [contents subdataWithRange:NSMakeRange(0, subdata_max_range)];
        NSStringEncoding encoding = [NSString stringEncodingForData:subdata encodingOptions:nil convertedString:nil usedLossyConversion:0];
        self.contents = [[NSString alloc] initWithData:contents encoding:encoding];
    } else if([typeName isEqual: @"public.html"]){
        self.contents = [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
    } else if([typeName isEqual: @"public.rtf"]){
        self.contents = [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
    } else {
        printf("Unexpected type: %s\n", [typeName UTF8String]);
    }
    return YES;
}

@end
