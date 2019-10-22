//
//  WeekdayCollectionViewCell.swift
//  Rolique
//
//  Created by Maks on 10/22/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

final class WeekdayCollectionViewCell: UICollectionViewCell {
  private lazy var weekdayLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    weekdayLabel.textColor = Colors.mainTextColor
    weekdayLabel.adjustsFontSizeToFitWidth = true
    weekdayLabel.textAlignment = .center
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with weekday: String, isPastDay: Bool, isToday: Bool) {
    weekdayLabel.text = weekday
    weekdayLabel.textColor = isPastDay ? Colors.secondaryTextColor : isToday ? Colors.Colleagues.lightBlue : Colors.mainTextColor
  }
  
  private func configureViews() {
    [weekdayLabel].forEach(self.addSubviewAndDisableMaskTranslate)
    
    weekdayLabel.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    weekdayLabel.text = nil
  }
}
