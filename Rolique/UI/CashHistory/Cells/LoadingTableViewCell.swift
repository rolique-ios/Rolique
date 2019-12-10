//
//  LoadingTableViewCell.swift
//  Rolique
//
//  Created by Bohdan Savych on 12/10/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit

final class LoadingTableViewCell: TableViewCell {
  private lazy var activityIndicator = UIActivityIndicatorView(style: .gray)
  
  override func configure() {
    attachViews()
  }
  
  func startAnimating() {
    activityIndicator.startAnimating()
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
