## WCStackNavigationController
A small class that creates a stack view like those seen on Path, Facebook, and more.  Closely follows the UINavigationController pattern with push and pop methods.

---
### Why?
There are a lot of really nice stack view controllers out there, but I wanted to create something that was simple to use and gave me the ability to push and pop controllers on the navigation list with no real effort.

### Using WCStackNavigationController
There are a couple of ways you can use this controller, you can either extend it, so you can design/layout your own navigation list view (which is a tableView, of course).  When extending just make sure to only override UITableView datasource methods, and if you override selectRowAtIndexPath, be sure to call super.  The other way (as a simple demo in the app delegate shows) is to just drop it in and start using it.

There is a category that adds to items to UIViewController based objects, UIViewController+WCStackNavigationController, I would throw this in your prefetch so all your view controllers can have the added attributes.

The attributes added are:

* stackTitle - This is the title you would like to see displayed on the navigation menu.
* stackIcon - The image you would like to use to display with your stackTitle on the navigation list.

#### Delegate Methods (All Optional)

```objectivec
// If Yes, when a controller in navigation is selected, the view will slide closed.
- (BOOL)stackControllerWillCloseNavigationWhenSelected;

// The size of the visible view when slide to the right
- (CGFloat)stackControllerSlideOffset;

// Allow for user to swipe the nav open/close
- (BOOL)stackControllerEnableSwipeForNavigation;

// Called before moving to a new view/view controller.
- (void)stackController:(WCStackNavigationController *)stackController willNavigateToViewController:(UIViewController *)viewController;
- (void)stackController:(WCStackNavigationController *)stackController willNavigateFromViewController:(UIViewController *)viewController;

// Called when navgation to the new controller is complete.
- (void)stackController:(WCStackNavigationController *)stackController didNavigateToViewController:(UIViewController *)viewController;
- (void)stackController:(WCStackNavigationController *)stackController didNavigateFromViewController:(UIViewController *)viewController;
```

#### Public Methods
```objectivec
// Push a controller on to the stack and display as current view
- (void)pushViewController:(UIViewController *)viewController;

// Remove a controller from the stack, if removing current controller, will move to previous controller
- (void)popViewController:(UIViewController *)viewController;

// Hides Navigation bar
- (void)setNavigationBarHidden:(BOOL)shouldHide;

// Hides Navigation bar with some animation
- (void)setNavigationBarHidden:(BOOL)shouldHide animated:(BOOL)animated;
```

#### Customization

If you want to customize the look of your our stack nav controller, you can. If you wish to alter the cells, you just have to extend WCStackNavigationController and simply overwrite:

```objectivec
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
```

---

#### Notes:

* This project uses ARC
* Initial project with many plans to expand.

#### To-Dos
* Ability to not have/not add item to the navigation list
* Optional Right side menu/nav.

---

As usual, if you have any suggestions, contributions, etc.. Feel free to message me here or hit me up on twitter (@wesscope).

Thanks,

Wess