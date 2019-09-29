//
//  TransitionAnimator.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/25/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

private struct Constants {
  static var bias: CGFloat { return 100 }
  static var animationDuration: TimeInterval  = 0.2
  static var defaultViewWidth: CGFloat = 320
}

final class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  private var viewWidth: CGFloat?
  private let presenting: Bool
  
  init(presenting: Bool) {
    self.presenting = presenting
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return Constants.animationDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
    guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
    if viewWidth == nil { viewWidth = fromViewController.view.bounds.size.width }
    let startX = fromViewController.view.bounds.width
    let startFrame = CGRect(x: startX, y: 0, width: viewWidth ?? Constants.defaultViewWidth, height: fromViewController.view.bounds.size.height)
    let transformedStartFrame = transitionContext.containerView.convert(startFrame, to: fromViewController.view)
    let endX = fromViewController.view.bounds.size.width - (viewWidth ?? 0)
    let endFrame = CGRect(x: endX, y: 0, width: viewWidth ?? Constants.defaultViewWidth, height: fromViewController.view.bounds.size.height)
    let transformedEndFrame = transitionContext.containerView.convert(endFrame, to: fromViewController.view)
    
    if presenting {
      transitionContext.containerView.addSubview(fromViewController.view)
      transitionContext.containerView.addSubview(toViewController.view)
      toViewController.view.frame = transformedStartFrame
      UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseInOut, animations: {
        toViewController.view.frame = transformedEndFrame
        fromViewController.view.frame = CGRect(x: transformedEndFrame.origin.x - Constants.bias, y: 0, width: transformedEndFrame.width, height: transformedEndFrame.height)
      }, completion: { (finished) in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
    } else {
      transitionContext.containerView.addSubview(toViewController.view)
      transitionContext.containerView.addSubview(fromViewController.view)
      toViewController.view.frame = CGRect(x: transformedEndFrame.origin.x - Constants.bias, y: 0, width: transformedEndFrame.width, height: transformedEndFrame.height)
      UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveLinear, animations: {
        fromViewController.view.frame = transformedStartFrame
        toViewController.view.frame = transformedEndFrame
      }, completion: { (finished) in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
    }
  }
}
