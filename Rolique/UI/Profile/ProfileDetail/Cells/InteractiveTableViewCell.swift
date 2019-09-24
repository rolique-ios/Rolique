//
//  InteractiveTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/24/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var defaultOffset: CGFloat { return 20.0 }
  static var topOffset: CGFloat { return 8.0 }
  static var containerViewCornerRadius: CGFloat { return 20.0 }
  static var containerViewBottomOffset: CGFloat { return 10.0 }
  static var separatorHeight: CGFloat { return 1.0 }
}

final class InteractiveTableViewCell: UITableViewCell {
  private lazy var containerView = UIView()
  private lazy var separator = UIView()
  private var button: UIButton?
  private var containerBottomConstraint: Constraint?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    
    containerView.backgroundColor = .white
    containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    containerView.layer.masksToBounds = false
    
    separator.backgroundColor = Colors.Profile.separatorColor
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with button: UIButton, isLast: Bool, showSeparator: Bool = false) {
    self.button = button
    configureViews(with: button)
    
    if isLast {
      containerView.layer.cornerRadius = Constants.containerViewCornerRadius
      containerView.addShadow()
      containerBottomConstraint?.update(offset: -Constants.containerViewBottomOffset)
    } else {
      containerView.layer.cornerRadius = 0
      containerView.removeShadow()
      containerBottomConstraint?.update(offset: 0)
    }
    
    if showSeparator {
      [separator].forEach(self.addSubviewAndDisableMaskTranslate)
      separator.snp.makeConstraints { maker in
        maker.top.equalToSuperview()
        maker.leading.equalToSuperview().offset(Constants.defaultOffset)
        maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
        maker.height.equalTo(Constants.separatorHeight)
      }
    }
  }
  
  private func configureViews(with button: UIView) {
    [containerView].forEach(self.addSubviewAndDisableMaskTranslate)
    [button].forEach(self.containerView.addSubviewAndDisableMaskTranslate)
    
    containerView.snp.makeConstraints { maker in
      maker.top.equalToSuperview()
      maker.leading.equalToSuperview()
      maker.trailing.equalToSuperview()
      containerBottomConstraint = maker.bottom.equalToSuperview().constraint
    }
    
    [button].forEach(self.containerView.addSubviewAndDisableMaskTranslate)
    
    button.snp.makeConstraints { maker in
      maker.top.equalToSuperview().offset(Constants.topOffset)
      maker.centerX.equalToSuperview()
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    containerView.removeFromSuperview()
    separator.removeFromSuperview()
    button?.removeFromSuperview()
  }
}
