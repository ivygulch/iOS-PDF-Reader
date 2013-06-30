//
//  CHostingCollectionViewCell.m
//  Test
//
//  Created by Jonathan Wight on 6/20/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "CHostingCollectionViewCell.h"

#import <objc/runtime.h>

@implementation CHostingCollectionViewCell

+ (Class)subclassWithViewControllerClass:(Class)inViewControllerClass
	{
	NSString *theClassName = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(self), NSStringFromClass(inViewControllerClass)];
    Class theNewClass = NSClassFromString(theClassName);
    if (theNewClass == NULL)
        {
        theNewClass = objc_allocateClassPair(self, [theClassName UTF8String], 0);
        NSParameterAssert(theNewClass != NULL);

        id (^theBlock)(void) = ^(void) { return(inViewControllerClass); };

        IMP theIMP = imp_implementationWithBlock([theBlock copy]);
        NSParameterAssert(theIMP != NULL);
            
        Method theMethod = class_getInstanceMethod(self, NSSelectorFromString(@"hostedViewControllerClass"));
        NSParameterAssert(theMethod != NULL);

        BOOL theResult = class_addMethod(theNewClass, NSSelectorFromString(@"hostedViewControllerClass"), theIMP, method_getTypeEncoding(theMethod));
        NSParameterAssert(theResult == YES);
        }

	return(theNewClass);
	}

- (id)initWithFrame:(CGRect)frame
    {
    if ((self = [super initWithFrame:frame]) != NULL)
        {
		Class theClass = self.hostedViewControllerClass;
		UIViewController *theViewController = [[theClass alloc] initWithNibName:NULL bundle:NULL];
		self.hostedViewController = theViewController;
        }
    return self;
    }

- (void)prepareForReuse
    {
    [super prepareForReuse];
    //
    NSLog(@"tesT");
    }

- (void)setParentViewController:(UIViewController *)parentViewController
    {
    if (_parentViewController != parentViewController)
        {
        if (_hostedViewController != NULL && _hostedViewController.parentViewController != NULL)
            {
            [_hostedViewController willMoveToParentViewController:NULL];
            [_hostedViewController removeFromParentViewController];
            }

        _parentViewController = parentViewController;

        if (_hostedViewController != NULL)
            {
            [_hostedViewController willMoveToParentViewController:self.parentViewController];
            [self.parentViewController addChildViewController:_hostedViewController];
            }
        }
    }

- (void)setHostedViewController:(UIViewController *)hostedViewController
	{
	if (_hostedViewController != hostedViewController)
		{
        _hostedViewController = hostedViewController;

		UIView *theHostedView = _hostedViewController.view;
		NSParameterAssert(theHostedView != NULL);
		theHostedView.translatesAutoresizingMaskIntoConstraints = NO;
        theHostedView.frame = self.contentView.bounds;
		[self.contentView addSubview:theHostedView];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:NULL views:@{ @"view": theHostedView }]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:NULL views:@{ @"view": theHostedView }]];
		}
	}

@end
