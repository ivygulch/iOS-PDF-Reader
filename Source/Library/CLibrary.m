//
//  CLibrary.m
//  iOS-PDF-Reader
//
//  Created by Jonathan Wight on 06/04/11.
//  Copyright 2012 Jonathan Wight. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Jonathan Wight.

#import "CLibrary.h"

#import "CPDFDocumentPageViewController.h"
#import "NSFileManager_BugFixExtensions.h"
#import "CPDFDocument.h"

@implementation CLibrary

- (void)scanDirectories
    {
    NSFileManager *theFileManager = [NSFileManager defaultManager];

    NSURL *theDocumentsURL = [[theFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    NSURL *theInboxURL = [theDocumentsURL URLByAppendingPathComponent:@"Inbox"];
    NSError *theError = NULL;
    NSEnumerator *theEnumerator = NULL;
    id theErrorHandler = ^(NSURL *url, NSError *error) { NSLog(@"ERROR: %@", error); return(YES); };

    if ([theFileManager fileExistsAtPath:theInboxURL.path])
        {
        for (NSURL *theURL in [theFileManager tx_enumeratorAtURL:theInboxURL includingPropertiesForKeys:NULL options:0 errorHandler:theErrorHandler])
            {
            NSURL *theDestinationURL = [theDocumentsURL URLByAppendingPathComponent:[theURL lastPathComponent]];
            BOOL theResult = [theFileManager moveItemAtURL:theURL toURL:theDestinationURL error:&theError];
            NSLog(@"MOVING: %@ %d %@", theURL, theResult, theError);
            }
        }

    NSArray *theAllURLs = @[];
    NSArray *theURLs = NULL;

    NSURL *theBundleURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Samples"];
    theBundleURL = [theBundleURL URLByStandardizingPath];
    theEnumerator = [theFileManager tx_enumeratorAtURL:theBundleURL includingPropertiesForKeys:NULL options:0 errorHandler:theErrorHandler];
    theURLs = [theEnumerator allObjects];
    theAllURLs = [theAllURLs arrayByAddingObjectsFromArray:theURLs];

    theEnumerator = [theFileManager tx_enumeratorAtURL:theDocumentsURL includingPropertiesForKeys:NULL options:0 errorHandler:theErrorHandler];
    theURLs = [theEnumerator allObjects];
    theAllURLs = [theAllURLs arrayByAddingObjectsFromArray:theURLs];


    theAllURLs = [theAllURLs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastPathComponent LIKE '*.pdf'"]];

    theAllURLs = [theAllURLs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//        return(YES);
        return ([[NSFileManager defaultManager] fileExistsAtPath:[evaluatedObject path]]);
        }]];

    theAllURLs = [theAllURLs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return([[obj1 lastPathComponent] compare:[obj2 lastPathComponent]]);
        }];

    self.URLs = theAllURLs;
    }

@end
