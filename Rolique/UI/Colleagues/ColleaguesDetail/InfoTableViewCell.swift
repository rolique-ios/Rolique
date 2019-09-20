//
//  InfoTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/20/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit

class CopyableLabel: UILabel {
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    sharedInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    sharedInit()
  }
  
  func sharedInit() {
    isUserInteractionEnabled = true
    addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu)))
  }
  
  @objc func showMenu(sender: AnyObject?) {
    becomeFirstResponder()
    let menu = UIMenuController.shared
    if !menu.isMenuVisible {
      menu.setTargetRect(bounds, in: self)
      menu.setMenuVisible(true, animated: true)
    }
  }
  
  override func copy(_ sender: Any?) {
    let board = UIPasteboard.general
    board.string = text
    let menu = UIMenuController.shared
    menu.setMenuVisible(false, animated: true)
  }
  
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return action == #selector(UIResponderStandardEditActions.copy)
  }
}

private struct Constants {
  static var defaultOffset: CGFloat { return 20.0 }
  static var littleOffset: CGFloat { return 8.0 }
  static var interactiveViewSize: CGFloat { return 20.0 }
}

final class InfoTableViewCell: UITableViewCell {
  private lazy var titleLabel = CopyableLabel()
  private var titleTrailingConstraint: Constraint?
  
  weak var delegate: ColleaguesTableViewCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.backgroundColor = .clear
    self.selectionStyle = .none
    
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.font = .systemFont(ofSize: 16)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with title: String?, interactiveView: UIView? = nil, action: Selector? = nil) {
    configureViews()
    
    titleLabel.text = title
    
    if let interactiveView = interactiveView {
      let gesture = UITapGestureRecognizer(target: self, action: action)
      interactiveView.addGestureRecognizer(gesture)
      interactiveView.isUserInteractionEnabled = true
      interactiveView.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
      interactiveView.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
      
      [interactiveView].forEach(self.addSubviewAndDisableMaskTranslate)
      
      interactiveView.snp.makeConstraints { maker in
        maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
        maker.size.equalTo(Constants.interactiveViewSize)
        maker.centerY.equalToSuperview()
      }
      
      titleTrailingConstraint?.deactivate()
      titleLabel.snp.makeConstraints { maker in
        maker.trailing.equalTo(interactiveView.snp.leading).offset(-Constants.littleOffset)
      }
    }
  }
  
  private func configureViews() {
    [titleLabel].forEach(self.addSubviewAndDisableMaskTranslate)
    
    titleLabel.snp.makeConstraints { maker in
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
      titleTrailingConstraint = maker.trailing.equalToSuperview().offset(Constants.defaultOffset).constraint
      maker.centerY.equalToSuperview()
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    titleLabel.removeFromSuperview()
  }
}
