//
//  CDemoTableViewCell.h
//  Test
//
//  Created by Jonathan Wight on 6/20/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDemoTableViewCell : UITableViewCell

@property (readonly, nonatomic, assign) Class hostedViewControllerClass;
@property (readonly, nonatomic, strong) UIViewController *hostedViewController;
@property (readwrite, nonatomic, weak) UIViewController *parentViewController;
//@property (readwrite, nonatomic, strong) id representedObject;

+ (Class)subclassWithViewControllerClass:(Class)inViewControllerClass;

@end
