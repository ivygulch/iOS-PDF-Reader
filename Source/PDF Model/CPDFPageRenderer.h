//
//  CPDFPageRenderer.h
//  PDFReader
//
//  Created by Jonathan Wight on 6/30/13.
//  Copyright (c) 2013 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CPDFPage;

@interface CPDFPageRenderer : NSObject

+ (instancetype)sharedInstance;

- (UIImage *)imageForPage:(CPDFPage *)inPage box:(CGPDFBox)inBox size:(CGSize)inSize scale:(CGFloat)inScale;

@end
