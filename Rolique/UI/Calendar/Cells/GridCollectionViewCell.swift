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
  private lazy var stackView = UIStackView()
  private var leftSeparatorHeightConstraint: Constraint?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.spacing = 2.0
    
    topSeparator.backgroundColor = Colors.separatorColor
    leftSeparator.backgroundColor = Colors.separatorColor
    rightSeparator.backgroundColor = Colors.separatorColor
    bottomSeparator.backgroundColor = Colors.separatorColor
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with recordTypes: [SequentialRecordType]?, isTop: Bool, isRight: Bool) {
    for recordType in recordTypes ?? [] {
      let label = UILabel()
      label.textColor = .orange
      label.layer.borderWidth = 1.0
      label.layer.borderColor = UIColor.orange.cgColor
      label.layer.cornerRadius = 4
      
      label.text = recordType.total > 1 ? "\(recordType.current) / \(recordType.total)" + recordType.type.desctiption : recordType.type.desctiption
      label.textAlignment = .left
      label.numberOfLines = 0
      label.font = .systemFont(ofSize: 16.0)
      label.adjustsFontSizeToFitWidth = true
      label.minimumScaleFactor = 8.0 / 16.0
      stackView.addArrangedSubview(label)
    }
    
    if isTop {
      configureTopSeparator()
      leftSeparatorHeightConstraint?.update(offset: 400)
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
    [stackView, leftSeparator, bottomSeparator].forEach(self.addSubviewAndDisableMaskTranslate)
    
    stackView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
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
    
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    topSeparator.removeFromSuperview()
    rightSeparator.removeFromSuperview()
  }
    
}
