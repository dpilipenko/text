//
//  Document.m
//  Text
//
//  Created by Dmitriy Pilipenko on 3/7/13.
//  Copyright (c) 2013 Dmitriy Pilipenko. All rights reserved.
//

#import "Document.h"

@implementation Document

NSString *textViewString;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        textViewString = [NSString string];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    if (textViewString != nil) {
        [_myTextView setString:textViewString];        
    }

}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    return [super dataOfType:typeName error:outError];
}
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    return [super readFromData:data ofType:typeName error:outError];
}


- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    
    NSString *myData = [[_myTextView textStorage] string];
    
    // setup vars
    FILE *fp = NULL;
    NSString *filePath = [absoluteURL path];
    const char *fpath = [filePath UTF8String];
    // open file
    fp = fopen(fpath, "w");
    if (fp == NULL) {
        NSLog(@"There was an error creating the file");
        return NO;
    }
    // obtain memory size
    size_t strlength = 0;
    strlength = strlen([myData UTF8String]);
    // write memory to file
    fwrite([myData UTF8String], strlength, 1, fp);
    // close file
    fclose(fp);
    NSLog(@"File was written successfully");
    return YES;
    
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    // setup vars
    char *buffer = NULL;
    FILE *fp = NULL;
    NSString *filePath = [absoluteURL path];
    const char *fpath = [filePath UTF8String];
    // open file
    fp = fopen(fpath, "r");
    if (fp == NULL) {
        NSLog(@"There was an error opening the file");
        return NO;
    }
    // obtain file size:
    fseek(fp, 0, SEEK_END);
    long lSize = ftell(fp);
    rewind(fp);
    // alloc memory
    buffer = (char *) malloc(sizeof(char)*lSize);
    if (buffer == NULL) {
        NSLog(@"There was an error allocating buffer memory");
        return NO;
    }
    // read to memory
    size_t result = 0;
    result = fread(buffer, 1, lSize, fp);
    if (result != lSize) {
        NSLog(@"There was an error reading the file");
        return NO;
    }
    // convert to Obj-C object
    NSString *fileData = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    // close file
    fclose(fp);
    free(buffer);
    // do Obj-C stuff
    textViewString = fileData;
    return YES;
}

@end
