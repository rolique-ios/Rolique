//
//  GridCollectionViewCell.swift
//  Rolique
//
//  Created by Maks on 10/22/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var separatorHeightWidth: CGFloat { return 1.0 }
}

final class GridCollectionViewCell: UICollectionViewCell {
  private lazy var topSeparator = UIView()
  private lazy var leftSeparator = UIView()
  private lazy var rightSeparator = UIView()
  private lazy var bottomSeparator = UIView()
  private lazy var statusLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    statusLabel.textColor = Colors.mainTextColor
    statusLabel.adjustsFontSizeToFitWidth = true
    statusLabel.textAlignment = .center
    
    topSeparator.backgroundColor = Colors.separatorColor
    leftSeparator.backgroundColor = Colors.separatorColor
    rightSeparator.backgroundColor = Colors.separatorColor
    bottomSeparator.backgroundColor = Colors.separatorColor
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with status: String, isTop: Bool, isRight: Bool) {
    statusLabel.text = status
    
    if isTop {
      configureTopSeparator()
    }
    
    if isRight {
      configureRightSeparator()
    }
  }
  
  private func configureTopSeparator() {
    [topSeparator].forEach(self.addSubviewAndDisableMaskTranslate)
    
    topSeparator.snp.makeConstraints { maker in
      maker.top.left.right.equalToSuperview()
      maker.height.equalTo(Constants.separatorHeightWidth)
    }
  }
  
  private func configureRightSeparator() {
    [rightSeparator].forEach(self.addSubviewAndDisableMaskTranslate)
    
    rightSeparator.snp.makeConstraints { maker in
      maker.top.right.bottom.equalToSuperview()
      maker.width.equalTo(Constants.separatorHeightWidth)
    }
  }
  
  private func configureViews() {
    [statusLabel, leftSeparator, bottomSeparator].forEach(self.addSubviewAndDisableMaskTranslate)
    
    statusLabel.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
    
    leftSeparator.snp.makeConstraints { maker in
      maker.top.left.bottom.equalToSuperview()
      maker.width.equalTo(Constants.separatorHeightWidth)
    }
    
    bottomSeparator.snp.makeConstraints { maker in
      maker.left.bottom.right.equalToSuperview()
      maker.height.equalTo(Constants.separatorHeightWidth)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    statusLabel.text = nil
    topSeparator.removeFromSuperview()
    rightSeparator.removeFromSuperview()
  }
    
}
