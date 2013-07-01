//
//  CPDFPageRenderer.m
//  PDFReader
//
//  Created by Jonathan Wight on 6/30/13.
//  Copyright (c) 2013 toxicsoftware.com. All rights reserved.
//

#import "CPDFPageRenderer.h"

#import "CPDFPage.h"
#import "CPersistentCache.h"
#import "Geometry.h"
#import "CPDFDocument.h"

@interface CPDFPageRenderer ()
@property (readonly, nonatomic, strong) CPersistentCache *cache;
@end

@implementation CPDFPageRenderer

static id gSharedInstance = NULL;

+ (instancetype)sharedInstance
    {
    static dispatch_once_t sOnceToken = 0;
    dispatch_once(&sOnceToken, ^{
        gSharedInstance = [[self alloc] init];
        });
    return(gSharedInstance);
    }

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        _cache = [[CPersistentCache alloc] initWithName:@"PDFPageRenderer"];
        }
    return self;
    }

- (UIImage *)imageForPage:(CPDFPage *)inPage box:(CGPDFBox)inBox size:(CGSize)inSize scale:(CGFloat)inScale
    {
    CGRect theImageBox = CGPDFPageGetBoxRect(inPage.cg, inBox);
    if (CGSizeEqualToSize(inSize, CGSizeZero))
        {
        inSize = theImageBox.size;
        }

    NSString *theKey = [NSString stringWithFormat:@"Document_%@_PageImage_%d_%d_%g_%g_%g", [inPage.document.URL lastPathComponent], inPage.pageNumber, inBox, inSize.width, inSize.height, inScale];
    theKey = [theKey stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    theKey = [theKey stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    NSLog(@"%@", theKey);
    UIImage *theImage = [self.cache objectForKey:theKey];
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

	CGContextDrawPDFPage(theContext, inPage.cg);

    theImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    [self.cache setObject:theImage forKey:theKey];

    return(theImage);
    }


@end
