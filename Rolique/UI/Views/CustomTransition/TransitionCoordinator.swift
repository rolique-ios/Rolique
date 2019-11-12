//
//  TransitionCoordinator.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/25/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

extension UINavigationController {
  static private var coordinatorHelperKey = "UINavigationController.TransitionCoordinatorHelper"
  
  var transitionCoordinatorHelper: TransitionCoordinator? {
    return objc_getAssociatedObject(self, &UINavigationController.coordinatorHelperKey) as? TransitionCoordinator
  }
  
  func addCustomTransitioning() {
    var object = objc_getAssociatedObject(self, &UINavigationController.coordinatorHelperKey)
    
    guard object == nil else {
      return
    }
    
    object = TransitionCoordinator()
    let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
    objc_setAssociatedObject(self, &UINavigationController.coordinatorHelperKey, object, nonatomic)
    
    let coordinator = object as! TransitionCoordinator
    delegate = coordinator
    
    coordinator.swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
    view.addGestureRecognizer(coordinator.swipeGestureRecognizer!)
  }
  
  @objc func handleSwipe(sender: UIPanGestureRecognizer) {
    let translate = sender.translation(in: sender.view)
    let percent = translate.x / sender.view!.bounds.size.width
    if sender.state == .began {
        transitionCoordinatorHelper?.interactionController = UIPercentDrivenInteractiveTransition()
        self.popViewController(animated: true)
    } else if sender.state == .changed {
        transitionCoordinatorHelper?.interactionController?.update(percent)
    } else if sender.state == .ended {
        let velocity = sender.velocity(in: sender.view)
        if percent > 0.5 || velocity.x > 50 {
            transitionCoordinatorHelper?.interactionController?.finish()
        } else {
            transitionCoordinatorHelper?.interactionController?.cancel()
        }
        transitionCoordinatorHelper?.interactionController = nil
    }
  }
  
  func renewCustomTransition() {
    guard let transitionCoordinatorHelper = transitionCoordinatorHelper else { return }
    delegate = transitionCoordinatorHelper
    transitionCoordinatorHelper.swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
    view.addGestureRecognizer(transitionCoordinatorHelper.swipeGestureRecognizer!)
  }
  
  func removeCustomTransition() {
    delegate = nil
    transitionCoordinatorHelper?.swipeGestureRecognizer.map { view.removeGestureRecognizer($0) }
  }
}

final class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
  var swipeGestureRecognizer: UIPanGestureRecognizer?
  var interactionController: UIPercentDrivenInteractiveTransition?
  
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    switch operation {
    case .push:
      return TransitionAnimator(presenting: true)
    case .pop:
      return TransitionAnimator(presenting: false)
    default:
      return nil
    }
  }
  
  func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactionController
  }
}
