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
  static var littleOffset: CGFloat { return 6.0 }
}

final class DayCollectionViewCell: UICollectionViewCell {
  private lazy var dayLabel = UILabel()
  private lazy var separator = UIView()
  private lazy var selectView = UIView()
  private var selectViewSizeConstraint: Constraint?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = Colors.secondaryBackgroundColor
    
    dayLabel.textColor = Colors.mainTextColor
    dayLabel.adjustsFontSizeToFitWidth = true
    dayLabel.textAlignment = .center
    
    separator.backgroundColor = Colors.separatorColor
    
    selectView.backgroundColor = Colors.Colleagues.lightBlue
    
    configureViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with weekday: String, isPastDay: Bool, isToday: Bool) {
    addShadow()
    
    let size = frame.height > frame.width ? frame.width - Constants.littleOffset : frame.height - Constants.littleOffset
    selectView.roundCorner(radius: size / 2)
    selectViewSizeConstraint?.update(offset: size)
    selectView.isHidden = !isToday
    
    dayLabel.text = weekday
    dayLabel.textColor = isPastDay ? Colors.secondaryTextColor : isToday ? .white : Colors.mainTextColor
  }
  
  private func configureViews() {
    [selectView, dayLabel, separator].forEach(self.addSubviewAndDisableMaskTranslate)
    
    let size = frame.height > frame.width ? frame.width - Constants.littleOffset : frame.height - Constants.littleOffset
    selectView.snp.makeConstraints { maker in
      maker.center.equalToSuperview()
      selectViewSizeConstraint = maker.size.equalTo(size).constraint
    }
    
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
    deleteShadow()
  }
  
  private func addShadow() {
    let shadowHeight: CGFloat = 3.0
    let shadowRadius: CGFloat = 3.0
    let width = frame.width
    let height = frame.height
    
    let shadowPath = UIBezierPath()
    shadowPath.move(to: CGPoint(x: 0, y: height))
    shadowPath.addLine(to: CGPoint(x: width, y: height))
    shadowPath.addLine(to: CGPoint(x: width, y: height + shadowHeight))
    shadowPath.addLine(to: CGPoint(x: 0, y: height + shadowHeight))
    
    layer.shadowPath = shadowPath.cgPath
    layer.shadowRadius = shadowRadius
    layer.shadowOffset = .zero
    layer.shadowOpacity = 0.5
    layer.shadowColor = Colors.shadowColor
  }
  
  func deleteShadow() {
    layer.shadowPath = nil
    layer.shadowRadius = .zero
    layer.shadowOffset = .zero
    layer.shadowOpacity = .zero
  }
}
