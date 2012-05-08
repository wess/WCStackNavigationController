//
//  UIViewController+WCStackNavigationController.m
//  Gathering
//
//  Created by Wess Cope on 5/7/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//

#import "UIViewController+WCStackNavigationController.h"
#import <objc/objc-runtime.h>

@implementation UIViewController (WCStackNavigationController)
@dynamic stackTitle;
@dynamic stackIcon;

- (void)setStackTitle:(NSString *)stackTitle
{
    objc_setAssociatedObject(self, "WC_STACK_TITLE_STRING", stackTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)stackTitle
{
    return (NSString *)objc_getAssociatedObject(self, "WC_STACK_TITLE_STRING");
}

- (void)setStackIcon:(UIImage *)stackIcon
{
    objc_setAssociatedObject(self, "WC_STACK_ICON_IMAGE", stackIcon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)stackIcon
{
    return objc_getAssociatedObject(self, "WC_STACK_ICON_IMAGE");
}

@end
