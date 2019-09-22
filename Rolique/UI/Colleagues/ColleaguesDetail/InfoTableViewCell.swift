//
//  InfoTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/20/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
  static var defaultOffset: CGFloat { return 20.0 }
  static var littleOffset: CGFloat { return 8.0 }
  static var interactiveViewSize: CGFloat { return 20.0 }
}

final class InfoTableViewCell: UITableViewCell {
  private lazy var containerView = UIView()
  private lazy var titleLabel = CopyableLabel()
  private var interactiveView: UIView?
  private var titleTrailingConstraint: Constraint?
  private var containerBottomConstraint: Constraint?
  
  weak var delegate: ColleaguesTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    
    containerView.backgroundColor = .white
    containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    containerView.layer.masksToBounds = false
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.font = .systemFont(ofSize: 16)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with title: String?, interactiveView: UIView? = nil, target: Any? = nil, action: Selector? = nil, isLast: Bool) {
    configureViews()
    
    titleLabel.text = title
    
    if let interactiveView = interactiveView {
      self.interactiveView = interactiveView
      let gesture = UITapGestureRecognizer(target: target, action: action)
      interactiveView.addGestureRecognizer(gesture)
      interactiveView.isUserInteractionEnabled = true
      interactiveView.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
      interactiveView.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
      
      [interactiveView].forEach(self.addSubviewAndDisableMaskTranslate)
      
      interactiveView.snp.makeConstraints { maker in
        maker.trailing.equalTo(containerView).offset(-Constants.defaultOffset)
        maker.size.equalTo(Constants.interactiveViewSize)
        maker.centerY.equalTo(titleLabel)
      }
      
      titleTrailingConstraint?.deactivate()
      titleLabel.snp.makeConstraints { maker in
        maker.trailing.equalTo(interactiveView.snp.leading).offset(-Constants.littleOffset)
      }
    }
    
    if isLast {
      containerView.layer.cornerRadius = 20
      containerView.layer.shadowColor = UIColor.black.cgColor
      containerView.layer.shadowRadius = 6.0
      containerView.layer.shadowOffset = CGSize(width: 0, height: 7)
      containerView.layer.shadowOpacity = 0.1
      containerBottomConstraint?.update(offset: -10)
    } else {
      containerView.layer.cornerRadius = 0
      containerView.layer.shadowColor = nil
      containerView.layer.shadowRadius = 0
      containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
      containerView.layer.shadowOpacity = 0
      containerBottomConstraint?.update(offset: 0)
    }
  }
  
  private func configureViews() {
    [containerView, titleLabel].forEach(self.addSubviewAndDisableMaskTranslate)
    
    containerView.snp.makeConstraints { maker in
      maker.top.equalToSuperview()
      maker.leading.equalToSuperview()
      maker.trailing.equalToSuperview()
      containerBottomConstraint = maker.bottom.equalToSuperview().constraint
    }
    titleLabel.snp.makeConstraints { maker in
      maker.leading.equalTo(containerView).offset(Constants.defaultOffset)
      titleTrailingConstraint = maker.trailing.equalTo(containerView).offset(Constants.defaultOffset).constraint
      maker.top.equalTo(containerView).offset(4)
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    containerView.removeFromSuperview()
    titleLabel.removeFromSuperview()
    interactiveView?.removeFromSuperview()
  }
}
