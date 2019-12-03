//
//  EmptyTimeRoomTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/11/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var separatorHeight: CGFloat { return 1.0 }
}

final class EmptyTimeRoomTableViewCell: UITableViewCell {
  private lazy var topSeparator = UIView()
  private lazy var bottomSeparator = UIView()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    topSeparator.backgroundColor = Colors.separatorColor
    bottomSeparator.backgroundColor = Colors.separatorColor
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(isLast: Bool) {
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
    [topSeparator].forEach(self.addSubview)

    topSeparator.snp.makeConstraints { maker in
      maker.left.top.right.equalToSuperview()
      maker.height.equalTo(Constants.separatorHeight)
    }
  }
}
