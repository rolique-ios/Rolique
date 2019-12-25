//
//  DayCollectionCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/13/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Utils

private struct Constants {
  static var heightMultiplier: CGFloat { return 0.8 }
}

struct DayCollectionCellConfig {
  var isToday: Bool
  var isSelected: Bool
  var isWeekend: Bool
  var isInCurrentMonth: Bool
  var text: String?
  var cellHeight: CGFloat
  
  init(isToday: Bool, isSelected: Bool, isWeekend: Bool, text: String?, isInCurrentMonth: Bool, cellHeight: CGFloat) {
    self.isToday = isToday
    self.isSelected = isSelected
    self.isWeekend = isWeekend
    self.text = text
    self.cellHeight = cellHeight
    self.isInCurrentMonth = isInCurrentMonth
  }
}

final class DayCollectionCell: JTAppleCell {
  private lazy var backView = UIView()
  private lazy var textLabel = UILabel()
  
  private var config: DayCollectionCellConfig?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    textLabel.font = .systemFont(ofSize: 12.0)
    
    configureConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureConstraints()
  }
  
  private func configureConstraints() {
    [backView, textLabel].forEach(addSubview(_:))
    
    textLabel.snp.makeConstraints { maker in
      maker.center.equalToSuperview()
    }
    
    backView.snp.makeConstraints { maker in
      maker.center.equalToSuperview()
      maker.height.equalToSuperview().multipliedBy(Constants.heightMultiplier)
      maker.width.equalTo(backView.snp.height)
    }
  }
  
  func update(_ config: DayCollectionCellConfig) {
    self.config = config
    
    backView.roundCorner(radius: config.cellHeight * Constants.heightMultiplier / 2)
    
    if !config.isInCurrentMonth {
      textLabel.textColor = Colors.secondaryTextColor
      textLabel.text = config.text
      self.backView.isHidden = true
    } else {
      self.backView.isHidden = !(config.isToday || config.isSelected)
      textLabel.text = config.text
      textLabel.textColor = config.isToday ? .white : config.isWeekend ? Colors.secondaryTextColor : Colors.mainTextColor
      backView.backgroundColor = config.isToday ? Colors.Colleagues.lightBlue : Colors.mainBackgroundColor
      backView.layer.borderColor = config.isSelected ? Colors.Colleagues.lightBlue.cgColor : UIColor.white.cgColor
      backView.layer.borderWidth = 1
    }
  }
}
