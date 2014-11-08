MSTDropDownPresentationController
====================

[![CI Status](http://img.shields.io/travis/masahikot/MSTDropDownPresentationController.svg?style=flat)](https://travis-ci.org/Masahiko Tsujita/MSTDropDownPresentationController)
[![Version](https://img.shields.io/cocoapods/v/MSTDropDownPresentationController.svg?style=flat)](http://cocoadocs.org/docsets/MSTDropDownPresentationController)
[![License](https://img.shields.io/cocoapods/l/MSTDropDownPresentationController.svg?style=flat)](http://cocoadocs.org/docsets/MSTDropDownPresentationController)
[![Platform](https://img.shields.io/cocoapods/p/MSTDropDownPresentationController.svg?style=flat)](http://cocoadocs.org/docsets/MSTDropDownPresentationController)

##Overview
A Drop Down Presentation Controller like [Tweetbot 3](http://tapbots.com/software/tweetbot/)'s Timeline/Lists switcher.

![](./Screenshot.png)

## Requirements
iOS 8 & iOS SDK 8.0 and later.
## Installation

MSTDropDownPresentationController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MSTDropDownPresentationController"
```

## Usage
###1. Adopt UIViewControllerTransitioningDelegate
```objective-c
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[MSTDropDownPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[MSTDropDownAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[MSTDropDownAnimationController alloc] init];
}
```
###2. Present View Controller with Custom Presentation
```objective-c
- (IBAction)showDropDownViewController:(id)sender {
    ViewController *viewController = [[ViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    viewController.transitioningDelegate = self;
    [self presentViewController:viewController animated:YES completion:NULL];
}
```

## License

MSTDropDownPresentationController is available under the MIT license. See the LICENSE file for more info.

