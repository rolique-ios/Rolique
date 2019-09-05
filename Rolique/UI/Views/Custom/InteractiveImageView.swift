//
//  InteractiveImageView.swift
//  Rolique
//
//  Created by Andrii on 9/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

@objc protocol InteractiveImageViewDelegate: class {
  func interactiveImageView(_ interactiveImageView: InteractiveImageView, didDetectTapWithSender sender: UITapGestureRecognizer)
}

class InteractiveImageView: UIImageView {
  
  @IBInspectable var allowTap: Bool = false {
    didSet {
      if !allowTap {
        self.removeGestureRecognizer(tapper)
      } else {
        self.addGestureRecognizer(tapper)
      }
    }
  }
  @IBInspectable var allowInstantPreview: Bool = false {
    didSet {
      if allowInstantPreview {
        longer.minimumPressDuration = instantPressDuration
      }
    }
  }
  @IBInspectable var allowImageFullscreenPreview: Bool = false {
    didSet {
      if allowImageFullscreenPreview {
        allowTap = true
      }
    }
  }
  weak var delegate: InteractiveImageViewDelegate?
  
  private var tapper: UITapGestureRecognizer!
  private var longer: UILongPressGestureRecognizer!
  private var opened = false
  private var tempRect: CGRect?
  private var bgView: UIView!
  private var threeDtouch = false
  private var animated: Bool = true
  private var intDuration = 0.25
  private let forceLimit: CGFloat = 0.5
  
  private let longPressDuration: CFTimeInterval = 0.3
  private let instantPressDuration: CFTimeInterval = 0.08
  
  init() {
    super.init(frame: .zero)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  private func initialize() {
    tapper = UITapGestureRecognizer(target: self, action: #selector(tapperDidTap(sender:)))
    longer = UILongPressGestureRecognizer(target: self, action: #selector(longerDidTap(sender:)))
    longer.minimumPressDuration = longPressDuration
    self.addGestureRecognizer(longer)
    isUserInteractionEnabled = true
  }
  
  @objc func tapperDidTap(sender: UITapGestureRecognizer) {
    delegate?.interactiveImageView(self, didDetectTapWithSender: sender)
  }

  @objc func longerDidTap(sender: UILongPressGestureRecognizer) {
    if sender.state == .began {
      opened = true
      goFullScreen()
    } else if sender.state == .ended {
      exitFullScreen()
    }
  }
  
  // MARK: Actions of Gestures
  @objc func exitFullScreen () {
    if opened {
      NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
      let bluredView = bgView.subviews[0]
      let imageV = bgView.subviews[1] as! UIImageView
      UIView.animate(withDuration: intDuration, animations: {
        imageV.frame = self.tempRect!
        self.bgView.alpha = 0
        bluredView.alpha = 0
      }) { _ in
        self.bgView.removeFromSuperview()
        bluredView.removeFromSuperview()
        self.opened = false
      }
    }
  }
  
  func goFullScreen() {
    if let window = UIApplication.shared.delegate?.window {
      NotificationCenter.default.addObserver(self, selector: #selector(exitFullScreen), name: UIDevice.orientationDidChangeNotification, object: nil)
      bgView = UIView(frame: UIScreen.main.bounds)
      bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      bgView.alpha = 0
      bgView.backgroundColor = UIColor.clear
      let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
      let blurEffectView = UIVisualEffectView(effect: blurEffect)
      blurEffectView.frame = bgView.frame
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.bgView.addSubview(blurEffectView)
      let imageV = UIImageView(image: self.image)
      imageV.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      let point = self.convert(self.bounds, to: bgView)
      imageV.frame = point
      tempRect = point
      imageV.contentMode = .scaleAspectFit
      bgView.addSubview(imageV)
      window?.addSubview(bgView)
      if animated {
        UIView.animate(withDuration: intDuration, animations: {
          self.bgView.alpha = 1
          imageV.frame = self.bgView.frame
        })
      }
    }
  }
  
  func findParentViewController(view: UIView) -> UIViewController? {
    var parentResponder: UIResponder? = self
    while parentResponder != nil {
      parentResponder = parentResponder!.next
      if let viewController = parentResponder as? UIViewController {
        return viewController
      }
    }
    return nil
  }
}
