//
//  CPDFDocumentPageCollectionViewController.m
//  PDFReader
//
//  Created by Jonathan Wight on 6/30/13.
//  Copyright (c) 2013 toxicsoftware.com. All rights reserved.
//

#import "CPDFDocumentPageCollectionViewController.h"

#import "CPDFDocument.h"
#import "CHostingCollectionViewCell.h"
#import "CPDFPageViewController.h"
#import "CPDFPage.h"

@interface CPDFDocumentPageCollectionViewController ()

@end

@implementation CPDFDocumentPageCollectionViewController

- (void)viewDidLoad
    {
    [super viewDidLoad];
    //
    Class theCellClass = [CHostingCollectionViewCell subclassWithViewControllerClass:[CPDFPageViewController class]];

//    UICollectionViewFlowLayout *theLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
//    theLayout.itemSize = self.view.bounds.size;

    [self.collectionView registerClass:theCellClass forCellWithReuseIdentifier:@"PAGE"];
    }

- (void)viewWillAppear:(BOOL)animated
    {
    UICollectionViewFlowLayout *theLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    theLayout.itemSize = self.view.bounds.size;
    }

- (void)setDocumentURL:(NSURL *)documentURL
    {
    _documentURL = documentURL;
    CPDFDocument *theDocument = [[CPDFDocument alloc] initWithURL:documentURL];
    self.document = theDocument;
    }

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
    {
    return(self.document.numberOfPages);
    }

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
    {
    CPDFPage *thePage = [self.document pageForPageNumber:indexPath.item + 1];

    CHostingCollectionViewCell *theCell = (CHostingCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PAGE" forIndexPath:indexPath];
    theCell.hostedViewController;
    theCell.parentViewController = self;

    CPDFPageViewController *theViewController = (CPDFPageViewController *)theCell.hostedViewController;
    theViewController.page = thePage;

    return(theCell);
    }


@end
