//
//  BookedTimeRoomTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/28/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var separatorHeight: CGFloat { return 1.0 }
  static var containerOffset: CGFloat { return 2.0 }
  static var titleLabelInsets: UIEdgeInsets { return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0) }
}

final class BookedTimeRoomTableViewCell: UITableViewCell {
  private lazy var topSeparator = UIView()
  private lazy var bottomSeparator = UIView()
  private lazy var containerView = UIView()
  private lazy var titleLabel = LabelWithInsets(insets: Constants.titleLabelInsets)
  private var containerViewTopConstraint: Constraint?
  private var containerViewBottomConstraint: Constraint?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    topSeparator.backgroundColor = Colors.separatorColor
    bottomSeparator.backgroundColor = Colors.separatorColor
    
    containerView.backgroundColor = Colors.Colleagues.lightBlue
    containerView.roundCorner(radius: 5.0)
    
    titleLabel.textColor = .white
    titleLabel.font = .systemFont(ofSize: 14.0)
    titleLabel.adjustsFontSizeToFitWidth = true
    titleLabel.minimumScaleFactor = 0.1
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with data: [BookedCellData], isLast: Bool) {
//    titleLabel.text = title
//    containerViewTopConstraint?.update(offset: containerTopOffset + 2)
//    containerViewBottomConstraint?.update(offset: containerBottomOffset < Constants.containerOffset ? -Constants.containerOffset : -containerBottomOffset)
    
    
    
    if isLast {
      [bottomSeparator].forEach(addSubview(_:))
      
      bottomSeparator.snp.makeConstraints { maker in
        maker.bottom.equalToSuperview().offset(1)
        maker.left.right.equalToSuperview()
        maker.height.equalTo(Constants.separatorHeight)
      }
    } else {
      bottomSeparator.removeFromSuperview()
    }
  }
  
  private func configureViews() {
    [topSeparator, containerView].forEach(self.addSubview)
    [titleLabel].forEach(containerView.addSubview)
    
    topSeparator.snp.makeConstraints { maker in
      maker.left.top.right.equalToSuperview()
      maker.height.equalTo(Constants.separatorHeight)
    }
    
    containerView.snp.makeConstraints { maker in
      containerViewTopConstraint = maker.top.equalTo(topSeparator).offset(2).constraint
      containerViewBottomConstraint = maker.bottom.equalToSuperview().constraint
      maker.left.equalToSuperview()
      maker.right.equalToSuperview().offset(-Constants.containerOffset)
    }
    
    titleLabel.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
}
