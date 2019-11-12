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
  static var littleOffset: CGFloat { return 2.0 }
  static var separatorHeightWidth: CGFloat { return 1.0 }
  static var labelInsets: UIEdgeInsets { return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2) }
  static var separatorHeightOffset: CGFloat { return 500 }
  static var statusLabelInsets: UIEdgeInsets { return UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 2) }
  static var cornerRadius: CGFloat { return 5.0 }
}

final class GridCollectionViewCell: UICollectionViewCell {
  private lazy var topSeparator = UIView()
  private lazy var leftSeparator = UIView()
  private lazy var rightSeparator = UIView()
  private lazy var bottomSeparator = UIView()
  private lazy var statusLabel = LabelWithInsets(insets: Constants.labelInsets)
  private var leftSeparatorHeightConstraint: Constraint?
  private var statusLabelConstraint: Constraint?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    statusLabel.textAlignment = .center
    statusLabel.font = .systemFont(ofSize: 20.0)
    statusLabel.adjustsFontSizeToFitWidth = true
    statusLabel.textColor = .white
    
    for separator in [topSeparator, leftSeparator, rightSeparator, bottomSeparator] {
      separator.backgroundColor = Colors.separatorColor
    }
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with recordTypes: [SequentialRecordType]?, isTop: Bool, isRight: Bool) {
    let text = recordTypes?.compactMap { $0.total > 1 ? $0.type.abbreviation.0 + " " + "\($0.current)/\($0.total)" : $0.type.abbreviation.0 }.joined(separator: "\n")
    statusLabel.backgroundColor = recordTypes?.first?.type.abbreviation.1 ?? .clear
    statusLabel.numberOfLines = recordTypes?.count ?? 0 > 1 ? recordTypes!.count : 1
    statusLabel.text = text
    
    var moreThanOneDay = false
    var isFirst = false
    var isLast = false
    for recordType in recordTypes ?? [] {
      if recordType.total > 1 {
        moreThanOneDay = true
        isFirst = recordType.current == 1
        isLast = recordType.current == recordType.total
        break
      }
    }
    
    if moreThanOneDay {
      statusLabelConstraint?.update(inset: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0))
      statusLabel.roundCorner(radius: 0)
      
      if isFirst {
        statusLabel.roundCorner(radius: Constants.cornerRadius)
        statusLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
      }
      
      if isLast {
        statusLabel.roundCorner(radius: Constants.cornerRadius)
        statusLabel.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        statusLabelConstraint?.update(inset: Constants.statusLabelInsets)
      }
    } else {
      statusLabelConstraint?.update(inset: Constants.statusLabelInsets)
      statusLabel.roundCorner(radius: Constants.cornerRadius)
      statusLabel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
    }
    
    if isTop {
      configureTopSeparator()
      leftSeparatorHeightConstraint?.update(offset: Constants.separatorHeightOffset)
    } else {
      leftSeparatorHeightConstraint?.update(offset: 0)
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
    [leftSeparator, bottomSeparator, statusLabel].forEach(self.addSubviewAndDisableMaskTranslate)
    
    statusLabel.snp.makeConstraints { maker in
      statusLabelConstraint = maker.edges.equalToSuperview().inset(Constants.statusLabelInsets).constraint
    }
    
    leftSeparator.snp.makeConstraints { maker in
      leftSeparatorHeightConstraint = maker.height.equalToSuperview().constraint
      maker.left.bottom.equalToSuperview()
      maker.width.equalTo(Constants.separatorHeightWidth)
    }
    
    bottomSeparator.snp.makeConstraints { maker in
      maker.left.bottom.right.equalToSuperview()
      maker.height.equalTo(Constants.separatorHeightWidth)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    topSeparator.removeFromSuperview()
    rightSeparator.removeFromSuperview()
  }
    
}
