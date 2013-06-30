//
//  CPDFDocumentPageCollectionViewController.h
//  PDFReader
//
//  Created by Jonathan Wight on 6/30/13.
//  Copyright (c) 2013 toxicsoftware.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPDFDocument;

@interface CPDFDocumentPageCollectionViewController : UICollectionViewController

@property (readwrite, nonatomic, strong) NSURL *documentURL;
@property (readwrite, nonatomic, strong) CPDFDocument *document;

@end
