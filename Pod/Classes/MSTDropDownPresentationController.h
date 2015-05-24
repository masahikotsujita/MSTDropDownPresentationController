//
//  Copyright (c) 2014 Masahiko Tsujita <masahikot.uec@icloud.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>

/**
MSTDropDownPresentationController is a object that controls Tweetbot-3-list-selector-like (drop down) view controller transition.
You should use this class with MSTDropDownAnimationController together. Otherwise, it may causes unexpected problem.
*/
@interface MSTDropDownPresentationController : UIPresentationController <UIGestureRecognizerDelegate>

///-----------------------------------------------------------------------------
/// @name Customizing Presentation Controller Appearances
///-----------------------------------------------------------------------------

/**
Corner radius of content view. The bottom corners of content view will be clipped by specified corner radius. The default value is 15 point.
*/
@property (assign, nonatomic) CGFloat cornerRadius;

/**
Layout margins of container view. Top value is ignored. The default margins are 8 points on each side.
*/
@property (assign, nonatomic) UIEdgeInsets layoutMargins;

/**
The background view's alpha value. The default value is 0.5.
*/
@property (assign, nonatomic) CGFloat backgroundAlpha;

///-----------------------------------------------------------------------------
/// @name Customizing Interface Behaviours
///-----------------------------------------------------------------------------

/**
A Boolean value indicating whether presented view controller should be dismissed when user tap background view(non-content area).
If this property is NO, presentation controller doesn't provide any way to dismiss presented view controller, so presented view controller may have to provide some way to do that, such as "Cancel" button on alert controller.
*/
@property (assign, nonatomic) BOOL dismissesOnBackgroundTap;

@end

/**
MSTDropDownAnimationController is a object that controls animation in MSTDropDownPresentationController presentation.
You should use this class with MSTDropDownPresentationController together. Otherwise, it may causes unexpected problem.
*/
@interface MSTDropDownAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@end

/**
MSTDropDownPresentationControllerSupport category adds MSTDropDownPresentationController supporting methods to UIViewController.
*/
@interface UIViewController (MSTDropDownPresentationControllerSupport)

/**
Obtain a transitioning delegate object which vends presentation controller and animation controller for drop down transition.
*/
- (id <UIViewControllerTransitioningDelegate>)mst_dropDownTransitioningDelegate;

@property (strong, nonatomic, readonly) MSTDropDownPresentationController *mst_dropDownPresentationController;

@end

/**
MSTDropDownStoryboardSegue is a custom storyboard segue which performs drop down transition.
*/
@interface MSTDropDownStoryboardSegue : UIStoryboardSegue

/**
A Boolean value indicating whether receiver is unwind segue or not.
*/
@property (assign, nonatomic) BOOL unwinding;

@end
