//
//  LoadingTableViewCell.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/10/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class LoadingTableViewCell: TableViewCell {
  private lazy var activityIndicator: UIActivityIndicatorView = {
    if #available(iOS 12.0, *) {
      return self.traitCollection.userInterfaceStyle == .dark ? UIActivityIndicatorView(style: .white) : UIActivityIndicatorView(style: .gray)
    }
    
    return UIActivityIndicatorView(style: .gray)
  }()
  
  override func configure() {
    attachViews()
  }
  
  func startAnimating() {
    activityIndicator.startAnimating()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    if #available(iOS 12.0, *) {
      activityIndicator.style = self.traitCollection.userInterfaceStyle == .dark ? .white : .gray
    }
  }
}

// MARK: - Private
private extension LoadingTableViewCell {
  func attachViews() {
    [activityIndicator].forEach(contentView.addSubview)
    
    activityIndicator.snp.makeConstraints {
      $0.size.equalTo(CGSize(width: 20, height: 20))
      $0.center.equalToSuperview()
    }
  }
}
