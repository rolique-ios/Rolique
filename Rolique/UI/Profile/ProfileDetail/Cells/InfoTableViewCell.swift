//
//  InfoTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/20/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var defaultOffset: CGFloat { return 20.0 }
  static var littleOffset: CGFloat { return 8.0 }
  static var interactiveViewSize: CGFloat { return 20.0 }
}

final class InfoTableViewCell: UITableViewCell {
  private lazy var containerView = UIView()
  private lazy var titleLabel = UILabel()
  private lazy var iconImageView = UIImageView()
  private var titleTrailingConstraint: Constraint?
  private var containerBottomConstraint: Constraint?
  
  var onLongTap: Completion?
  var onTap: Completion?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    
    containerView.backgroundColor = Colors.secondaryBackgroundColor
    containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    containerView.layer.masksToBounds = false
    
    titleLabel.textColor = Colors.mainTextColor
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.font = .systemFont(ofSize: 16)
    
    iconImageView.contentMode = .scaleAspectFit
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(InfoTableViewCell.normalTap(sender:)))
    tapGesture.numberOfTapsRequired = 1
    self.addGestureRecognizer(tapGesture)
    
    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(InfoTableViewCell.longTap(sender:)))
    self.addGestureRecognizer(longGesture)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with title: String?, icon: UIImage? = nil, onLongTap: Completion? = nil, onTap: Completion? = nil, isLast: Bool) {
    configureViews()
    
    titleLabel.text = title
    
    if let icon = icon {
      iconImageView.image = icon
      iconImageView.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
      iconImageView.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
      
      [iconImageView].forEach(self.addSubviewAndDisableMaskTranslate)
      
      iconImageView.snp.makeConstraints { maker in
        maker.trailing.equalTo(containerView).offset(-Constants.defaultOffset)
        maker.size.equalTo(Constants.interactiveViewSize)
        maker.centerY.equalTo(titleLabel)
      }
      
      titleTrailingConstraint?.deactivate()
      titleLabel.snp.makeConstraints { maker in
        maker.trailing.equalTo(iconImageView.snp.leading).offset(-Constants.littleOffset)
      }
    }
    
    self.onLongTap = onLongTap
    self.onTap = onTap
    
    if isLast {
      containerView.layer.cornerRadius = 20
      containerView.setShadow()
      containerBottomConstraint?.update(offset: -10)
    } else {
      containerView.layer.cornerRadius = 0
      containerView.removeShadow()
      containerBottomConstraint?.update(offset: 0)
    }
  }
  
  private func configureViews() {
    [containerView].forEach(self.addSubviewAndDisableMaskTranslate)
    [titleLabel].forEach(self.containerView.addSubviewAndDisableMaskTranslate(_:))
    
    containerView.snp.makeConstraints { maker in
      maker.top.equalToSuperview()
      maker.leading.equalToSuperview()
      maker.trailing.equalToSuperview()
      containerBottomConstraint = maker.bottom.equalToSuperview().constraint
    }
    titleLabel.snp.makeConstraints { maker in
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
      titleTrailingConstraint = maker.trailing.equalTo(containerView).offset(Constants.defaultOffset).constraint
      maker.top.equalToSuperview().offset(4)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    containerView.removeFromSuperview()
    titleLabel.removeFromSuperview()
  }
  
  @objc func normalTap(sender: UITapGestureRecognizer) {
    onTap?()
  }
  
  @objc func longTap(sender: UILongPressGestureRecognizer) {
    sender.isEnabled.toggle()
    onLongTap?()
  }
}
