//
//  ModalPresentationHandler.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 10/1/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class ModalPresentationHandler: NSObject, UIAdaptivePresentationControllerDelegate {
  var willPresentVC: Completion?
  var willDismissVC: Completion?
  var didDismissVC: Completion?
  private let shouldDissmiss: Bool
  
  init(presentNVC: UINavigationController?, shouldDissmiss: Bool = true) {
    self.shouldDissmiss = shouldDissmiss
    super.init()
    presentNVC?.presentationController?.delegate = self
  }
  
  init(presentVC: UIViewController?, shouldDissmiss: Bool = true) {
    self.shouldDissmiss = shouldDissmiss
    super.init()
    presentVC?.presentationController?.delegate = self
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
