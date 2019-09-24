//
//  AdditionalInfoTableViewCell.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/24/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

private struct Constants {
  static var defaultOffset: CGFloat { return 16.0 }
  static var littleOffset: CGFloat { return 4.0 }
  static var containerViewCornerRadius: CGFloat { return 20.0 }
  static var containerViewBottomOffset: CGFloat { return 10.0 }
  static var separatorHeight: CGFloat { return 1.0 }
}

final class AdditionalInfoTableViewCell: UITableViewCell {
  private lazy var containerView = UIView()
  private lazy var textView = UITextView()
  private var containerBottomConstraint: Constraint?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.selectionStyle = .none
    
    containerView.backgroundColor = .white
    containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    containerView.layer.masksToBounds = false
    
    let doneButton = UIBarButtonItem(title: Strings.Actions.doneTitle, style: UIBarButtonItem.Style.done, target: self, action: #selector(donePressed))
    textView.inputAccessoryView = UIToolbar.toolbarPiker(rightButton: doneButton)
    textView.text = Strings.Profile.additionalInfoPlaceholder
    textView.textColor = .lightGray
    textView.font = .systemFont(ofSize: 16)
    textView.delegate = self
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func configure(with text: String?, isEditable: Bool, isLast: Bool) {
    configureViews()
    
    if let text = text {
      textView.text = text
      textView.textColor = .black
    }
    textView.isUserInteractionEnabled = isEditable
    
    if isLast {
      containerView.layer.cornerRadius = Constants.containerViewCornerRadius
      containerView.addShadow()
      containerBottomConstraint?.update(offset: -Constants.containerViewBottomOffset)
    } else {
      containerView.layer.cornerRadius = 0
      containerView.removeShadow()
      containerBottomConstraint?.update(offset: 0)
    }
  }
  
  private func configureViews() {
    [containerView, textView].forEach(self.addSubviewAndDisableMaskTranslate)
    
    containerView.snp.makeConstraints { maker in
      maker.top.equalToSuperview()
      maker.leading.equalToSuperview()
      maker.trailing.equalToSuperview()
      containerBottomConstraint = maker.bottom.equalToSuperview().constraint
    }
    textView.snp.makeConstraints { maker in
      maker.edges.equalTo(contentView).inset(UIEdgeInsets(top: Constants.littleOffset, left: Constants.defaultOffset, bottom: Constants.littleOffset, right: Constants.defaultOffset))
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    textView.removeFromSuperview()
  }
  
  @objc func donePressed() {
    self.endEditing(true)
  }
}

extension AdditionalInfoTableViewCell: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == .lightGray {
      textView.text = nil
      textView.textColor = .black
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = Strings.Profile.additionalInfoPlaceholder
      textView.textColor = .lightGray
    }
  }
}
