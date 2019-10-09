//
//  ModalPresentationHandler.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 10/1/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class ModalPresentationHandler: NSObject, UIAdaptivePresentationControllerDelegate {
  private var willPresentVC: Completion?
  private var willDismissVC: Completion?
  private var didDismissVC: Completion?
  private let shouldDissmiss: Bool
  
  init(shouldDissmiss: Bool = true, willPresentVC: Completion? = nil, willDismissVC: Completion? = nil, didDismissVC: Completion? = nil) {
    self.shouldDissmiss = shouldDissmiss
    super.init()
    self.willPresentVC = willPresentVC
    self.willDismissVC = willDismissVC
    self.didDismissVC = didDismissVC
  }
  
  func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
    willPresentVC?()
  }
  
  @available(iOS 13.0, *)
  func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
    return shouldDissmiss
  }
  
  @available(iOS 13.0, *)
  func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
    willDismissVC?()
  }
  
  @available(iOS 13.0, *)
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    didDismissVC?()
  }
}
