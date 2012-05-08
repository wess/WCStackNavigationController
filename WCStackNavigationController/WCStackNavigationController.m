//
//  WCStackNavigationController.m
//  Gathering
//
//  Created by Wess Cope on 5/7/12.
//  Copyright (c) 2012 Wess Cope. All rights reserved.
//

#import "WCStackNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+WCStackNavigationController.h"

@interface WCStackNavigationController ()
{
    BOOL _isShowingBackNavigation;
 
    UITableView     *_backNavigation;
    UIView          *_topView;
    UIView          *_currentView;
    UIViewController *_currentViewController;
}

- (void)transitionToViewController:(UIViewController *)viewController;
- (void)toggleNavigationView:(id)sender;
- (void)swipeLeftToCloseNavigationView:(UIGestureRecognizer *)gesture;
- (void)swipeRightToOpenNavigationView:(UIGestureRecognizer *)gesture;
@end

@implementation WCStackNavigationController
@synthesize delegate                = _delegate;
@synthesize stackToggleButtonItem   = _stackToggleButtonItem;
@synthesize navigationBar           = _navigationBar;

- (void)setNavigationBarHidden:(BOOL)shouldHide
{
    [self setNavigationBarHidden:shouldHide animated:NO];
}

- (void)setNavigationBarHidden:(BOOL)shouldHide animated:(BOOL)animated
{
    CGFloat duration = (animated)? 8.3f : 0.0f;
    [UIView animateWithDuration:duration animations:^{
        _navigationBar.hidden = shouldHide;
        
        CGRect currentFrame = _currentView.frame;

        if(shouldHide)
        {
            currentFrame = _topView.frame;
        }
        else 
        {
            currentFrame.size.height    -= _navigationBar.frame.size.height;
            currentFrame.origin.y       += _navigationBar.frame.size.height;
        }

        _currentView.frame = currentFrame;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isShowingBackNavigation = NO;
    
    _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 44.0f)];
    
    _backNavigation             = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _backNavigation.delegate    = self;
    _backNavigation.dataSource  = self;
    
    [self.view addSubview:_backNavigation];
    
    _topView = [[UIView alloc] initWithFrame:self.view.bounds];
    _topView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    [self.view addSubview:_topView];

    [_topView addSubview:_navigationBar];
    
    
    CGPathRef path = CGPathCreateWithRect(_topView.bounds, NULL);
    
    _topView.layer.shadowPath       = path;
    _topView.layer.shadowColor      = [UIColor blackColor].CGColor;
    _topView.layer.shadowOffset     = CGSizeMake(-2.0f, 0.0f);
    _topView.layer.shadowOpacity    = 0.4f;
    _topView.layer.shadowRadius     = 4.0f;
    
    CGPathRelease(path);
    
    CGRect currentViewFrame = _topView.frame;
    if(!_navigationBar.hidden)
    {
        currentViewFrame.size.height    -= _navigationBar.frame.size.height;
        currentViewFrame.origin.y       += _navigationBar.frame.size.height;
    }

    _currentView = [[UIView alloc] initWithFrame:currentViewFrame];
    [_topView addSubview:_currentView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    UIViewController *viewController = [self.childViewControllers objectAtIndex:0];
    NSIndexPath *currentPath         = [NSIndexPath indexPathForRow:[self.childViewControllers indexOfObject:viewController] inSection:0];
    [_backNavigation selectRowAtIndexPath:currentPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self transitionToViewController:viewController];
    
    BOOL canSwipe = NO;
    if([self.delegate respondsToSelector:@selector(stackControllerEnableSwipeForNavigation)])
        canSwipe = [self.delegate stackControllerEnableSwipeForNavigation];
    
    if(canSwipe)
    {
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftToCloseNavigationView:)];
        leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightToOpenNavigationView:)];
        rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        
        self.view.gestureRecognizers = [NSArray arrayWithObjects:leftSwipe, rightSwipe, nil];
    }
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return YES;
}

#pragma mark - Navigation Actions
- (void)transitionToViewController:(UIViewController *)viewController
{
    if([self.delegate respondsToSelector:@selector(stackController:willNavigateToViewController:)])
        [self.delegate stackController:self willNavigateToViewController:viewController];
    
    if([self.delegate respondsToSelector:@selector(stackController:willNavigateFromViewController:)])
        [self.delegate stackController:self willNavigateFromViewController:_currentViewController];
    
    UIBarButtonItem *navButtonItem;
    if(_stackToggleButtonItem)
    {
        [_stackToggleButtonItem setTarget:self];
        [_stackToggleButtonItem setAction:@selector(toggleNavigationView:)];
        
        navButtonItem = _stackToggleButtonItem;
    }
    else 
    {
        navButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(toggleNavigationView:)];
    }

    viewController.navigationItem.leftBarButtonItem = navButtonItem;
    viewController.view.frame                       = _currentView.frame;
    
    [UIView transitionFromView:_currentView toView:viewController.view duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [_navigationBar pushNavigationItem:viewController.navigationItem animated:NO];
        
        if(finished) 
        {
            if([self.delegate respondsToSelector:@selector(stackController:didNavigateFromViewController:)])
                [self.delegate stackController:self didNavigateFromViewController:_currentViewController];
            
            _currentView            = viewController.view;
            _currentViewController  = viewController;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.childViewControllers indexOfObject:viewController] inSection:0];
            [_backNavigation selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            if([self.delegate respondsToSelector:@selector(stackController:didNavigateToViewController:)])
                [self.delegate stackController:self didNavigateToViewController:_currentViewController];
        }
    }];
}

- (void)pushViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    [_backNavigation reloadData];
    [self transitionToViewController:viewController];
}

- (void)popViewController:(UIViewController *)viewController
{
    if([viewController isEqual:_currentViewController])
    {
        NSInteger prevIndex     = ([self.childViewControllers indexOfObject:viewController] - 1);
        NSIndexPath *indexPath  = [NSIndexPath indexPathForRow:prevIndex inSection:0];
        
        [_backNavigation selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self transitionToViewController:[self.childViewControllers objectAtIndex:prevIndex]];
        [viewController removeFromParentViewController];
    }
    
    [viewController removeFromParentViewController];
    [_backNavigation reloadData];
}

- (void)toggleNavigationView:(id)sender
{
    CGFloat slideOffset = [self.delegate respondsToSelector:@selector(stackControllerSlideOffset)]? [self.delegate stackControllerSlideOffset] : 50.0f;
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect topFrame     = _topView.frame;
        topFrame.origin.x   = (_isShowingBackNavigation)? 0.0f : (self.view.bounds.size.width - slideOffset);
        _topView.frame      = topFrame;
        
        _isShowingBackNavigation = !_isShowingBackNavigation;
    }];
    
}

- (void)swipeLeftToCloseNavigationView:(UIGestureRecognizer *)gesture
{
    if(!_isShowingBackNavigation)
        return;
    
    [self toggleNavigationView:nil];
}

- (void)swipeRightToOpenNavigationView:(UIGestureRecognizer *)gesture
{
    if(_isShowingBackNavigation)
        return;
    
    [self toggleNavigationView:nil];
}


#pragma mark - UITableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.childViewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"BACK_NAV_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    UIViewController *controller    = [self.childViewControllers objectAtIndex:indexPath.row];
    cell.textLabel.text             = controller.stackTitle? controller.stackTitle : [NSString stringWithFormat:@"Controller %d", indexPath.row];
    cell.imageView.image            = controller.stackIcon? controller.stackIcon : nil;
    
    return cell;
}

#pragma mark - UITableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = [self.childViewControllers objectAtIndex:indexPath.row];
    if([viewController isEqual:_currentViewController])
        return;
    
    [self transitionToViewController:viewController];
    
    if([self.delegate respondsToSelector:@selector(stackControllerWillCloseNavigationWhenSelected)])
    {
        BOOL shouldClose = [self.delegate stackControllerWillCloseNavigationWhenSelected];
        if(shouldClose)
            [self toggleNavigationView:nil];
    }
}


@end
