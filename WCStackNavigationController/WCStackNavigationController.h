//
//  WCStackNavigationController.h
//  Gathering
//
//  Created by Wess Cope on 5/7/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCStackNavigationDelegate;
@interface WCStackNavigationController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) id<WCStackNavigationDelegate>delegate;
@property (strong, nonatomic) UIBarButtonItem   *stackToggleButtonItem;
@property (strong, nonatomic) UINavigationBar   *navigationBar;

- (void)pushViewController:(UIViewController *)viewController;
- (void)popViewController:(UIViewController *)viewController;
- (void)setNavigationBarHidden:(BOOL)shouldHide;
- (void)setNavigationBarHidden:(BOOL)shouldHide animated:(BOOL)animated;
@end

@protocol WCStackNavigationDelegate <NSObject>

@optional
- (BOOL)stackControllerWillCloseNavigationWhenSelected;
- (CGFloat)stackControllerSlideOffset;
- (BOOL)stackControllerEnableSwipeForNavigation;
- (void)stackController:(WCStackNavigationController *)stackController willNavigateToViewController:(UIViewController *)viewController;
- (void)stackController:(WCStackNavigationController *)stackController didNavigateToViewController:(UIViewController *)viewController;
- (void)stackController:(WCStackNavigationController *)stackController willNavigateFromViewController:(UIViewController *)viewController;
- (void)stackController:(WCStackNavigationController *)stackController didNavigateFromViewController:(UIViewController *)viewController;

@end
