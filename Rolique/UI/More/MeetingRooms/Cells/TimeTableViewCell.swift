//
//  TimeTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/8/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var littleOffset: CGFloat { return 2.0 }
  static var separatorWidth: CGFloat { return 10.0 }
  static var separatorHeight: CGFloat { return 1.0 }
}

final class TimeTableViewCell: UITableViewCell {
  private lazy var separator = UIView()
  private lazy var timeLabel = UILabel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  
    self.backgroundColor = Colors.secondaryBackgroundColor
    self.selectionStyle = .none
    
    separator.backgroundColor = Colors.separatorColor
    
    timeLabel.font = .systemFont(ofSize: 14.0)
    timeLabel.textColor = Colors.secondaryTextColor
    timeLabel.textAlignment = .center
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with time: String) {
    timeLabel.text = time
  }
  
  private func configureViews() {
    [timeLabel, separator].forEach(self.addSubview)
    
    timeLabel.snp.makeConstraints { maker in
      maker.left.equalToSuperview().offset(Constants.littleOffset)
      maker.centerY.equalToSuperview()
      maker.right.equalTo(separator.snp.left).offset(Constants.littleOffset)
    }

    separator.snp.makeConstraints { maker in
      maker.width.equalTo(Constants.separatorWidth)
      maker.centerY.right.equalToSuperview()
      maker.height.equalTo(Constants.separatorHeight)
    }
  }
}
