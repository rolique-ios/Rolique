//
//  UIViewController.swift
//  Rolique
//
//  Created by Andrii Narinian on 9/1/17.
//  Copyright © 2017 Rolique. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

public extension UIViewController {
    var navigationBarHeight: CGFloat {
        let navigationBarFrame = navigationController?.navigationBar.frame ?? .zero
        return navigationBarFrame.origin.y + navigationBarFrame.height
    }
    
    var tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.size.height ?? 0
    }
    
    func presentPlayer(with url: URL, animated: Bool = true, completion: (() -> Void)? = nil) {
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true, completion: completion ?? { player.play() })
    }
    
    func close(animated: Bool = true, completion: (() -> Void)? = nil) {
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            navigationController?.popViewController(animated: animated)
            completion?()
        } else if presentingViewController != nil {
            dismiss(animated: animated, completion: completion)
        }
    }
  
    func showSpinner(shouldBlockUI: Bool) {
      let spinnerView = UIView(frame: .zero)
      spinnerView.backgroundColor = .black
      spinnerView.alpha = 0.4
      spinnerView.roundCorner(radius: 8)
      spinnerView.tag = "spinner_view_tag".hashValue
      
      view.addSubview(spinnerView, with: ConstraintsSettings(centerX: 0, centerY: 0, width: 100, height: 100))
      
      let spinner = ActivityIndicator(frame: .zero)
      spinner.animationDuration = 3
      spinner.rotationDuration = 3
      spinner.numSegments = 12
      spinner.strokeColor = .white
      spinner.lineWidth = 2
      spinner.tag = "spinner_tag".hashValue
      
      view.addSubview(spinner, with: ConstraintsSettings(centerX: 0, centerY: 0, width: 60, height: 60))
      
      spinnerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
      spinnerView.alpha = 0
      spinner.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
      spinner.alpha = 0
      
      UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, animations: {
        spinnerView.transform = CGAffineTransform.identity
        spinnerView.alpha = 0.4
        spinner.transform = CGAffineTransform.identity
        spinner.alpha = 1
      }) { success in
        spinner.startAnimating()
      }
      
      if shouldBlockUI { view.isUserInteractionEnabled = false }
    }
    
    func hideSpinner() {
      self.view.subviews.filter({ $0.tag == "spinner_view_tag".hashValue }).forEach { spinnerView in
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
          spinnerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
          spinnerView.alpha = 0
        }) { success in
          spinnerView.removeFromSuperview()
        }
        if !self.view.isUserInteractionEnabled { self.view.isUserInteractionEnabled = true }
      }
      self.view.subviews.filter({ $0.tag == "spinner_tag".hashValue }).forEach { spinner in
        guard let spinner = spinner as? ActivityIndicator else { return }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
          spinner.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
          spinner.alpha = 0
        }) { success in
          spinner.removeFromSuperview()
        }
        spinner.stopAnimating()
        if !self.view.isUserInteractionEnabled { self.view.isUserInteractionEnabled = true }
      }
    }
}
