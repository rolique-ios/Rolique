//
//  MeetingRoomTableViewCell.swift
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

final class MeetingRoomTableViewCell: UITableViewCell {
  private lazy var topSeparator = UIView()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  
    self.backgroundColor = Colors.mainBackgroundColor
    
    topSeparator.backgroundColor = Colors.separatorColor
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(isLast: Bool) {
    selectionStyle = isLast ? .none : .default
  }
  
  private func configureViews() {
    [topSeparator].forEach(self.addSubview)

    topSeparator.snp.makeConstraints { maker in
      maker.left.top.right.equalToSuperview()
      maker.height.equalTo(Constants.separatorHeight)
    }
  }
}
