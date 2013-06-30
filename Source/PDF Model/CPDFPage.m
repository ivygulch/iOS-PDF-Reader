//
//  CPDFPage.m
//  iOS-PDF-Reader
//
//  Created by Jonathan Wight on 02/20/11.
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

#import "CPDFPage.h"

#import "CPDFDocument.h"
#import "CPDFDocument_Private.h"
#import "Geometry.h"
#import "CPersistentCache.h"
#import "CPDFAnnotation.h"

@interface CPDFPage ()
@end

#pragma mark -

@implementation CPDFPage

@synthesize cg = _cg;
@synthesize annotations = _annotations;

- (id)initWithDocument:(CPDFDocument *)inDocument pageNumber:(NSInteger)inPageNumber;
	{
	if ((self = [super init]) != NULL)
		{
        _document = inDocument;
        _pageNumber = inPageNumber;
		}
	return(self);
	}

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (#%d, %@)", [super description], self.pageNumber, NSStringFromCGRect(self.mediaBox)]);
    }

- (CGPDFPageRef)cg
    {
    if (_cg == NULL)
        {
        _cg = CGPDFPageRetain(CGPDFDocumentGetPage(self.document.cg, self.pageNumber));
        }
    return(_cg);
    }

- (CGRect)mediaBox
    {
    return(CGPDFPageGetBoxRect(self.cg, kCGPDFMediaBox));
    }

- (CGRect)cropBox
    {
    return(CGPDFPageGetBoxRect(self.cg, kCGPDFCropBox));
    }

- (CGRect)bleedBox
    {
    return(CGPDFPageGetBoxRect(self.cg, kCGPDFBleedBox));
    }

- (CGRect)trimBox
    {
    return(CGPDFPageGetBoxRect(self.cg, kCGPDFTrimBox));
    }

- (CGRect)artBox
    {
    return(CGPDFPageGetBoxRect(self.cg, kCGPDFArtBox));
    }

- (CGRect)rectForBox:(CGPDFBox)inBox;
    {
    CGRect theBox = CGPDFPageGetBoxRect(self.cg, inBox);
    return theBox;
    }
    
- (UIImage *)imageForBox:(CGPDFBox)inBox withSize:(CGSize)inSize scale:(CGFloat)inScale
    {
    CGRect theImageBox = CGPDFPageGetBoxRect(self.cg, inBox);
    if (CGSizeEqualToSize(inSize, CGSizeZero))
        {
        inSize = theImageBox.size;
        }

    NSString *theKey = [NSString stringWithFormat:@"PageImage_%d_%d_%f_%f_%f", self.pageNumber, inBox, inSize.width, inSize.height, inScale];
    NSLog(@"%@", theKey);
    UIImage *theImage = [self.document.cache objectForKey:theKey];
    if (theImage != NULL)
        {
        return(theImage);
        }

    UIGraphicsBeginImageContextWithOptions(inSize, NO, inScale);

    CGContextRef theContext = UIGraphicsGetCurrentContext();

	CGContextSaveGState(theContext);



    const CGRect theRenderRect = ScaleAndAlignRectToRect(theImageBox, (CGRect){ .size = inSize }, ImageScaling_Proportionally, ImageAlignment_Center);

    // Fill just the render rect with white.
    CGContextSetRGBFillColor(theContext, 1.0,1.0,1.0,1.0);
    CGContextFillRect(theContext, theRenderRect);

    // Flip the context so that the PDF page is rendered right side up.
	CGContextTranslateCTM(theContext, 0.0, inSize.height);
	CGContextScaleCTM(theContext, 1.0, -1.0);

	// Scale the context so that the PDF page is rendered at the correct size for the zoom level.
    CGContextTranslateCTM(theContext, -(theImageBox.origin.x - theRenderRect.origin.x), -(theImageBox.origin.y - theRenderRect.origin.y));
	CGContextScaleCTM(theContext, theRenderRect.size.width / theImageBox.size.width, theRenderRect.size.height / theImageBox.size.height);

	CGContextDrawPDFPage(theContext, self.cg);

    theImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    [self.document.cache setObject:theImage forKey:theKey];

    return(theImage);
    }


- (NSArray *)annotations
    {
    if (_annotations == NULL)
        {
        NSMutableArray *theAnnotations = [NSMutableArray array];

        CGPDFDictionaryRef theDictionary = CGPDFPageGetDictionary(self.cg);

        CGPDFArrayRef thePDFAnnotationsArray = NULL;
        CGPDFDictionaryGetArray(theDictionary, "Annots", &thePDFAnnotationsArray);
        size_t theCount = CGPDFArrayGetCount(thePDFAnnotationsArray);
        for (size_t N = 0; N != theCount; ++N)
            {
            CGPDFDictionaryRef theObject;
            CGPDFArrayGetDictionary(thePDFAnnotationsArray, N, &theObject);
            CPDFAnnotation *theAnnotation = [[CPDFAnnotation alloc] initWithDictionary:theObject];
            [theAnnotations addObject:theAnnotation];
            }

    //    CGPDFDictionaryApplyBlock(theDictionary, ^(const char *key, CGPDFObjectRef value) {
    //        NSLog(@"%s", key);
    //        });

        _annotations = [theAnnotations copy];
        }
    return(_annotations);
    }

@end
