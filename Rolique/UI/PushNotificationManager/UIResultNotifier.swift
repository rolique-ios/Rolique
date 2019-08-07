//
//  PushNotificationManager.swift
//  Utils
//
//  Created by Bohdan Savych on 8/7/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct Constants {
  static var viewHeight: CGFloat { return 90 }
  static var offScreenOrigin: CGPoint {
    return CGPoint(x: 0, y: -20 - Constants.viewHeight)
  }
  static var onScreenOrigin: CGPoint {
    return CGPoint(x: 0, y: 20)
  }
}

final class UIResultNotifier {
  static let shared = UIResultNotifier()
  
  private var window: UIWindow {
    return UIApplication.shared.windows.first!
  }
  
  private lazy var view = NotificationReminderView(frame: CGRect(origin: Constants.offScreenOrigin, size: CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height), height: Constants.viewHeight)))
  
  private init() {
    window.addSubview(view)
    window.bringSubviewToFront(view)
  }
  
  var onNotificationTap: (() -> Void)?
  
  func showAndHideIfNeeded(text: String) {
    if view.alpha == 1 {
      hide {
        self.show(text: text)
      }
    } else {
      self.show(text: text)
    }
  }
  
  private func show(text: String) {
    view.configure(text: text)
    view.onTap = { [weak self] in
      self?.hide(completion: nil)
    }
    self.view.alpha = 1
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, animations: {
      self.view.frame.origin = Constants.onScreenOrigin
    }, completion: nil)
  }
  
  func hide(completion: (() -> Void)?) {
    UIView.animate(withDuration: 0.2, animations: {
      self.view.alpha = 0
    }, completion: { _ in
      self.view.frame.origin = Constants.offScreenOrigin
      completion?()
    })
  }
}
