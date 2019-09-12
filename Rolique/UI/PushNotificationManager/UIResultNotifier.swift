//
//  PushNotificationManager.swift
//  Utils
//
//  Created by Bohdan Savych on 8/7/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

private struct Constants {
  static var viewHeight: CGFloat { return 90 }
  static var topConstraintOffsetShow: CGFloat { return 5 }
  static var topConstraintOffsetHide: CGFloat { return -5 - Constants.viewHeight }
}

final class UIResultNotifier {
  static let shared = UIResultNotifier()
  
  private var window: UIWindow {
    return UIApplication.shared.windows.first!
  }
  
  private lazy var view = NotificationReminderView()
  private var timer: Timer?
  private var topConstraint: Constraint?
  
  private init() {
    window.addSubview(view)
    window.bringSubviewToFront(view)
    view.alpha = 0
    view.snp.makeConstraints { maker in
      topConstraint = maker.top.equalTo(window.safeAreaLayoutGuide).offset(Constants.topConstraintOffsetHide).constraint
      maker.centerX.equalToSuperview()
      maker.height.equalTo(Constants.viewHeight)
      maker.width.equalTo(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height))
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
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
  
  func showAndHideAfterTime(text: String, timeInterval: TimeInterval? = nil) {
    if view.alpha == 1 {
      timer?.invalidate()
      hide {
        self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval ?? 2.0, repeats: false) { timer in
          self.hide(completion: nil)
        }
        self.show(text: text)
      }
    } else {
      timer = Timer.scheduledTimer(withTimeInterval: timeInterval ?? 2.0, repeats: false) { timer in
        self.hide(completion: nil)
      }
      self.show(text: text)
    }
  }
  
  private func show(text: String) {
    view.configure(text: text)
    view.onTap = { [weak self] in
      self?.hide(completion: nil)
    }
    self.view.alpha = 1
    topConstraint?.update(offset: Constants.topConstraintOffsetShow)
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, animations: {
      self.window.layoutSubviews()
    }, completion: nil)
  }
  
  func hide(completion: (() -> Void)?) {
    timer?.invalidate()
    self.topConstraint?.update(offset: Constants.topConstraintOffsetHide)
    UIView.animate(withDuration: 0.2, animations: {
      self.view.alpha = 0
      self.window.layoutSubviews()
    }, completion: { _ in
      completion?()
    })
  }
}
