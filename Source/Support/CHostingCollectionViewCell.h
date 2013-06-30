//
//  CHostingCollectionViewCell.h
//  Test
//
//  Created by Jonathan Wight on 6/20/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHostingCollectionViewCell : UICollectionViewCell

@property (readonly, nonatomic, assign) Class hostedViewControllerClass;
@property (readonly, nonatomic, strong) UIViewController *hostedViewController;
@property (readwrite, nonatomic, weak) UIViewController *parentViewController;

+ (Class)subclassWithViewControllerClass:(Class)inViewControllerClass;

@end
