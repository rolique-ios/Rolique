//
//  PochavToast.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/27/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

typealias Event = (() -> Void)?

final class PochavToast: UIView {
  private struct Constants {
    static var defaultOffset: CGFloat { return 20.0 }
    static var buttonHeight: CGFloat { return 50.0 }
    static var buttonWidth: CGFloat { return 110.0 }
    static var centerOffset: CGFloat { return 60.0 }
  }
  private lazy var titleLabel = UILabel()
  private lazy var confirmButton = ConfirmButton()
  private lazy var cancelButton = CancelButton()
  var onConfirm: (() -> Void)?
  var onCancel: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  private func initialize() {
    configureConstraints()
    configureUI()
  }
  
  private func configureConstraints() {
    [titleLabel, confirmButton, cancelButton].forEach(self.addSubviewAndDisableMaskTranslate)
    
    titleLabel.snp.makeConstraints { maker in
      maker.top.equalToSuperview().offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
    }
    confirmButton.snp.makeConstraints { maker in
      maker.top.equalTo(titleLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview().offset(-Constants.centerOffset)
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
    }
    cancelButton.snp.makeConstraints { maker in
      maker.top.equalTo(titleLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview().offset(Constants.centerOffset)
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
      maker.bottom.equalToSuperview().offset(-Constants.defaultOffset)
    }
  }
  
  private func configureUI() {
    self.backgroundColor = .secondaryBackgroundColor()
    titleLabel.text = Strings.Actions.pochavTitle
    titleLabel.font = .preferredFont(forTextStyle: .title2)
    titleLabel.textColor = .mainTextColor()
    confirmButton.addTarget(self, action: #selector(didSelectConfirmButton), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(didSelectCancelButton), for: .touchUpInside)
  }
  
  func update(onConfirm: Event,
              onCancel: Event) {
    self.onConfirm = onConfirm
    self.onCancel = onCancel
  }
  
  @objc func didSelectConfirmButton() {
    onConfirm?()
  }
  
  @objc func didSelectCancelButton() {
    onCancel?()
  }
}
