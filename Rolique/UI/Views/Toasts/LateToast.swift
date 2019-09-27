//
//  LateToast.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/29/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

final class LateToast: UIView {
  private struct Constants {
    static var defaultOffset: CGFloat { return 20.0 }
    static var buttonHeight: CGFloat { return 50.0 }
    static var buttonWidth: CGFloat { return 110.0 }
    static var customButtonWidth: CGFloat { return 130.0 }
    static var centerOffset: CGFloat { return 60.0 }
    static var animationDuration: TimeInterval { return 0.3 }
    static var cornerRadius: CGFloat { return 5.0 }
    static var borderWidth: CGFloat { return 2.0 }
    static var textFieldHeight: CGFloat { return 35.0 }
  }
  private lazy var lateLabel = UILabel()
  private lazy var fromNowButton = UIButton()
  private lazy var fromTenOclockButton = UIButton()
  private lazy var in30minutesButton = UIButton()
  private lazy var in1hourButton = UIButton()
  private lazy var confirmButton = ConfirmButton()
  private lazy var cancelButton = CancelButton()
  private lazy var timePickerTextField = PickerTextField()
  private lazy var timePicker = UIPickerView()
  private lazy var data = [(title: "5 minutes", param: "5_m"), (title: "10 minutes", param: "10_m"), (title: "15 minutes", param: "15_m"), (title: "30 minutes", param: "30_m"), (title: "45 minutes", param: "45_m"), (title: "1 hour", param: "1_h"), (title: "2 hours", param: "2_h"), (title: "3 hours", param: "3_h"), (title: "4 hours", param: "4_h"), (title: "6 hours", param: "6_h")]
  private var from: From?
  var onConfirm: ((LateType) -> Void)?
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
    [lateLabel, fromNowButton, fromTenOclockButton, in30minutesButton, in1hourButton, confirmButton, cancelButton, timePickerTextField].forEach {
      $0.snp.removeConstraints()
      $0.removeFromSuperview()
    }
    configureConstraints()
    
    timePickerTextField.text = ""
    timePicker.selectRow(0, inComponent: 0, animated: false)
  }
  
  private func configureConstraints() {
    [lateLabel, fromNowButton, fromTenOclockButton]
      .forEach(self.addSubviewAndDisableMaskTranslate)
    
    lateLabel.snp.makeConstraints { maker in
      maker.top.equalToSuperview().offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
    }
    fromNowButton.snp.makeConstraints { maker in
      maker.top.equalTo(lateLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
    }
    fromTenOclockButton.snp.makeConstraints { maker in
      maker.top.equalTo(fromNowButton.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
      maker.bottom.equalToSuperview().offset(-Constants.defaultOffset)
    }
  }
  
  private func configureUI() {
    self.backgroundColor = .secondaryBackgroundColor()
    
    lateLabel.font = .preferredFont(forTextStyle: .title2)
    lateLabel.text = Strings.Actions.lateTitle
    
    fromNowButton.addTarget(self, action: #selector(didSelectFromNowButton), for: .touchUpInside)
    fromTenOclockButton.addTarget(self, action: #selector(didSelectFromTenOclockButton), for: .touchUpInside)
    in30minutesButton.addTarget(self, action: #selector(didSelectIn30minutesButton), for: .touchUpInside)
    in1hourButton.addTarget(self, action: #selector(didSelectIn1hourButton), for: .touchUpInside)
    confirmButton.addTarget(self, action: #selector(didSelectConfirmButton), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(didSelectCancelButton), for: .touchUpInside)
    
    fromNowButton.setTitle(Strings.Actions.fromNow, for: .normal)
    fromTenOclockButton.setTitle(Strings.Actions.from10Oclock, for: .normal)
    in30minutesButton.setTitle(Strings.Actions.in30minutes, for: .normal)
    in1hourButton.setTitle(Strings.Actions.in1hour, for: .normal)
    [fromNowButton, fromTenOclockButton, in30minutesButton, in1hourButton].forEach { button in
      button.setTitleColor(.mainTextColor(), for: .normal)
      button.layer.cornerRadius = Constants.cornerRadius
      button.layer.borderWidth = Constants.borderWidth
      button.layer.borderColor = UIColor.black.cgColor
    }
    
    timePickerTextField.delegate = self
    timePickerTextField.layer.cornerRadius = Constants.cornerRadius
    timePickerTextField.layer.borderColor = Colors.Login.backgroundColor.cgColor
    timePickerTextField.layer.borderWidth = Constants.borderWidth
    timePickerTextField.placeholder = Strings.Actions.orChooseTime
    timePickerTextField.inputView = timePicker
    let doneButton = UIBarButtonItem(title: Strings.Actions.doneTitle, style: UIBarButtonItem.Style.done, target: self, action: #selector(LateToast.doneButton))
    timePickerTextField.inputAccessoryView = UIToolbar.toolbarPiker(rightButton: doneButton)
    
    timePicker.dataSource = self
    timePicker.delegate = self
  }
  
  func update(onConfirm: ((LateType) -> Void)?,
              needsLayout: Event,
              onCancel: Event) {
    self.onConfirm = onConfirm
    self.needsLayout = needsLayout
    self.onCancel = onCancel
  }
  
  @objc func didSelectFromNowButton() {
    from = .now
    redrawView()
  }
  
  @objc func didSelectFromTenOclockButton() {
    from = .tenOclock
    redrawView()
  }
  
  @objc func didSelectIn30minutesButton() {
    guard let from = from else { return }
    onConfirm?(.in30minutes(from: from))
  }
  
  @objc func didSelectIn1hourButton() {
    guard let from = from else { return }
    onConfirm?(.in1hour(from: from))
  }
  
  private func redrawView() {
    [fromNowButton, fromTenOclockButton].forEach{ $0.removeFromSuperview() }
    [in30minutesButton, in1hourButton, timePickerTextField, confirmButton, cancelButton].forEach(self.addSubviewAndDisableMaskTranslate)
    in30minutesButton.snp.makeConstraints { maker in
      maker.top.equalTo(lateLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
      maker.width.equalTo(Constants.customButtonWidth)
      maker.height.equalTo(Constants.buttonHeight)
    }
    in1hourButton.snp.makeConstraints { maker in
      maker.top.equalTo(in30minutesButton.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
      maker.width.equalTo(Constants.buttonWidth)
      maker.height.equalTo(Constants.buttonHeight)
    }
    timePickerTextField.snp.makeConstraints { maker in
      maker.top.equalTo(in1hourButton.snp.bottom).offset(Constants.defaultOffset)
      maker.height.equalTo(Constants.textFieldHeight)
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
    }
    confirmButton.snp.makeConstraints { maker in
      maker.top.equalTo(timePickerTextField.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview().offset(-Constants.centerOffset)
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
    }
    cancelButton.snp.makeConstraints { maker in
      maker.top.equalTo(timePickerTextField.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview().offset(Constants.centerOffset)
      maker.width.equalTo(Constants.buttonWidth)
      maker.height.equalTo(Constants.buttonHeight)
      maker.bottom.equalToSuperview().offset(-Constants.defaultOffset)
    }
    
    needsLayout?()
  }
  
  @objc func doneButton() {
    let title = data[timePicker.selectedRow(inComponent: 0)].title
    timePickerTextField.text = title
    self.endEditing(true)
  }
  
  @objc func didSelectConfirmButton() {
    guard let from = from else { return }
    let time = data[timePicker.selectedRow(inComponent: 0)].param
    onConfirm?(.choosen(from: from, time: time))
  }
  
  @objc func didSelectCancelButton() {
    onCancel?()
  }
}

// MARK: - UIPickerViewDataSource

extension LateToast: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return data.count
  }
}

// MARK: - UIPickerViewDelegate

extension LateToast: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    timePickerTextField.text = data[row].title
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return data[row].title
  }
}

// MARK: - UITextFieldDelegate

extension LateToast: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return false
  }
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
}
