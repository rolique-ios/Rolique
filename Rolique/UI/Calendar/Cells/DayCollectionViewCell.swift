//
//  DayCollectionViewCell.swift
//  Rolique
//
//  Created by Maks on 10/22/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var separatorHeight: CGFloat { return 15 }
  static var separatorWidth: CGFloat { return 1.0 }
}

final class DayCollectionViewCell: UICollectionViewCell {
  private lazy var dayLabel = UILabel()
  private lazy var separator = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    dayLabel.textColor = Colors.mainTextColor
    dayLabel.adjustsFontSizeToFitWidth = true
    dayLabel.textAlignment = .center
    
    separator.backgroundColor = Colors.separatorColor
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with weekday: String, isPastDay: Bool, isToday: Bool) {
    dayLabel.text = weekday
    dayLabel.textColor = isPastDay ? Colors.secondaryTextColor : isToday ? Colors.Colleagues.lightBlue : Colors.mainTextColor
  }
  
  private func configureViews() {
    [dayLabel, separator].forEach(self.addSubviewAndDisableMaskTranslate)
    
    dayLabel.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
    
    separator.snp.makeConstraints { maker in
      maker.height.equalTo(Constants.separatorHeight)
      maker.width.equalTo(Constants.separatorWidth)
      maker.left.bottom.equalToSuperview()
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    dayLabel.text = nil
  }
}
