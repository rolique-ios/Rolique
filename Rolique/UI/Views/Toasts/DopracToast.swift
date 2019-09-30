//
//  DopracToast.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/28/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

final class DopracToast: UIView {
  private struct Constants {
    static var defaultOffset: CGFloat { return 20.0 }
    static var buttonHeight: CGFloat { return 50.0 }
    static var buttonWidth: CGFloat { return 110.0 }
    static var customButtonWidth: CGFloat { return 130.0 }
    static var centerOffset: CGFloat { return 60.0 }
    static var maximumHour: Int { return 19 }
    static var animationDuration: TimeInterval { return 0.3 }
    static var cornerRadius: CGFloat { return 5.0 }
    static var borderWidth: CGFloat { return 2.0 }
  }
  private lazy var titleLabel = UILabel()
  private lazy var nowButton = UIButton()
  private lazy var inAhourButton = UIButton()
  private lazy var customTimeButton = UIButton()
  private lazy var confirmButton = ConfirmButton()
  private lazy var cancelButton = CancelButton()
  private lazy var datePicker = UIDatePicker()
  private var cancelButtonTopConstraint: Constraint?
  private var cancelButtonCenterXConstraint: Constraint?
  var onConfirm: ((DopracType) -> Void)?
  var needsLayout: (() -> Void)?
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
  
  func refreshView() {
    [titleLabel, nowButton, inAhourButton, customTimeButton, confirmButton, cancelButton, datePicker].forEach {
      $0.snp.removeConstraints()
      $0.removeFromSuperview()
    }
    configureConstraints()
    
    titleLabel.text = Strings.Actions.dopracTitle
    
    let calendar = Calendar.current
    let date = Date()
    datePicker.maximumDate = calendar.date(bySettingHour: Constants.maximumHour, minute: 00, second: 00, of: date)
    let hour = calendar.component(.hour, from: Date())
    let minute = calendar.component(.minute, from: Date())
    datePicker.minimumDate = calendar.date(bySettingHour: hour, minute: minute, second: 00, of: date)
  }
  
  private func configureConstraints() {
    [titleLabel, nowButton, inAhourButton, customTimeButton, cancelButton]
      .forEach(self.addSubviewAndDisableMaskTranslate)
    
    titleLabel.snp.makeConstraints { maker in
      maker.top.equalToSuperview().offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
    }
    nowButton.snp.makeConstraints { maker in
      maker.top.equalTo(titleLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
    }
    inAhourButton.snp.makeConstraints { maker in
      maker.top.equalTo(nowButton.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
    }
    customTimeButton.snp.makeConstraints { maker in
      maker.top.equalTo(inAhourButton.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.customButtonWidth)
    }
    cancelButton.snp.makeConstraints { maker in
      cancelButtonTopConstraint = maker.top.equalTo(customTimeButton.snp.bottom).offset(Constants.defaultOffset).constraint
      cancelButtonCenterXConstraint = maker.centerX.equalToSuperview().constraint
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
      maker.bottom.equalToSuperview().offset(-Constants.defaultOffset)
    }
  }
  
  private func configureUI() {
    backgroundColor = Colors.secondaryBackgroundColor
    
    titleLabel.font = .preferredFont(forTextStyle: .title2)
    
    nowButton.addTarget(self, action: #selector(didSelectNowButton), for: .touchUpInside)
    inAhourButton.addTarget(self, action: #selector(didSelectInAHourButton), for: .touchUpInside)
    customTimeButton.addTarget(self, action: #selector(didSelectCustomTimeButton), for: .touchUpInside)
    confirmButton.addTarget(self, action: #selector(didSelectConfirmButton), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(didSelectCancelButton), for: .touchUpInside)
    
    nowButton.setTitle(Strings.Actions.now, for: .normal)
    inAhourButton.setTitle(Strings.Actions.inAHour, for: .normal)
    customTimeButton.setTitle(Strings.Actions.customTime, for: .normal)
    [nowButton, inAhourButton, customTimeButton].forEach { button in
      button.setTitleColor(Colors.mainTextColor, for: .normal)
      button.layer.cornerRadius = Constants.cornerRadius
      button.layer.borderWidth = Constants.borderWidth
      button.layer.borderColor = UIColor.black.cgColor
    }
    
    datePicker.datePickerMode = .time
  }
  
  func update(onConfirm: ((DopracType) -> Void)?,
              needsLayout: Event,
              onCancel: Event) {
    self.onConfirm = onConfirm
    self.needsLayout = needsLayout
    self.onCancel = onCancel
  }
  
  @objc func didSelectNowButton() {
    onConfirm?(.now)
  }
  
  @objc func didSelectInAHourButton() {
    onConfirm?(.hour)
  }
  
  @objc func didSelectCustomTimeButton() {
    [nowButton, inAhourButton, customTimeButton].forEach{ $0.removeFromSuperview() }
    [datePicker, confirmButton].forEach(self.addSubviewAndDisableMaskTranslate)
    datePicker.snp.makeConstraints { maker in
      maker.top.equalTo(titleLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
    }
    cancelButtonCenterXConstraint?.update(offset: Constants.centerOffset)
    cancelButtonTopConstraint?.deactivate()
    cancelButton.snp.makeConstraints { maker in
      maker.top.equalTo(datePicker.snp.bottom).offset(Constants.defaultOffset)
    }
    confirmButton.snp.makeConstraints { maker in
      maker.top.equalTo(datePicker.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview().offset(-Constants.centerOffset)
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
    }
    
    titleLabel.text = Strings.Actions.chooseTime
    needsLayout?()
  }
  
  @objc func didSelectConfirmButton() {
    onConfirm?(.custom(datePicker.date))
  }
  
  @objc func didSelectCancelButton() {
    onCancel?()
  }
}
