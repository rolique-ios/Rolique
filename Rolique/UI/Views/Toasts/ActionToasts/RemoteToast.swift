//
//  RemoteToast.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/29/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

final class RemoteToast: UIView {
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
  private lazy var titleLabel = UILabel()
  private lazy var todayButton = UIButton()
  private lazy var tomorrowButton = UIButton()
  private lazy var customDatesButton = UIButton()
  private lazy var confirmButton = ConfirmButton()
  private lazy var cancelButton = CancelButton()
  private lazy var startDateLabel = UILabel()
  private lazy var endDateLabel = UILabel()
  private lazy var startDateTextField = PickerTextField()
  private lazy var endDateTextField = PickerTextField()
  private lazy var startDatePicker = UIDatePicker()
  private lazy var endDatePicker = UIDatePicker()
  private var cancelButtonTopConstraint: Constraint?
  private var cancelButtonCenterXConstraint: Constraint?
  var onConfirm: ((RemoteType) -> Void)?
  var needsLayout: (() -> Void)?
  var onError: ((String) -> Void)?
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
    [titleLabel, todayButton, tomorrowButton, customDatesButton, confirmButton, cancelButton, startDateLabel, endDateLabel, startDateTextField, endDateTextField].forEach {
      $0.snp.removeConstraints()
      $0.removeFromSuperview()
    }
    configureConstraints()
    
    titleLabel.text = Strings.Actions.remoteTitle
    startDateTextField.text = ""
    endDateTextField.text = ""
  }
  
  private func configureConstraints() {
    [titleLabel, todayButton, tomorrowButton, customDatesButton, cancelButton]
      .forEach(self.addSubviewAndDisableMaskTranslate)
    
    titleLabel.snp.makeConstraints { maker in
      maker.top.equalToSuperview().offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
    }
    todayButton.snp.makeConstraints { maker in
      maker.top.equalTo(titleLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
    }
    tomorrowButton.snp.makeConstraints { maker in
      maker.top.equalTo(todayButton.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
    }
    customDatesButton.snp.makeConstraints { maker in
      maker.top.equalTo(tomorrowButton.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.customButtonWidth)
    }
    cancelButton.snp.makeConstraints { maker in
      cancelButtonTopConstraint = maker.top.equalTo(customDatesButton.snp.bottom).offset(Constants.defaultOffset).constraint
      cancelButtonCenterXConstraint = maker.centerX.equalToSuperview().constraint
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
      maker.bottom.equalToSuperview().offset(-Constants.defaultOffset)
    }
  }
  
  private func configureUI() {
    backgroundColor = Colors.secondaryBackgroundColor
    
    titleLabel.font = .preferredFont(forTextStyle: .title2)
    
    todayButton.addTarget(self, action: #selector(didSelectTodayButton), for: .touchUpInside)
    tomorrowButton.addTarget(self, action: #selector(didSelectInAHourButton), for: .touchUpInside)
    customDatesButton.addTarget(self, action: #selector(didSelectCustomTimeButton), for: .touchUpInside)
    confirmButton.addTarget(self, action: #selector(didSelectConfirmButton), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(didSelectCancelButton), for: .touchUpInside)
    
    todayButton.setTitle(Strings.Actions.today, for: .normal)
    tomorrowButton.setTitle(Strings.Actions.tomorrow, for: .normal)
    customDatesButton.setTitle(Strings.Actions.customDates, for: .normal)
    [todayButton, tomorrowButton, customDatesButton].forEach { button in
      button.setTitleColor(Colors.mainTextColor, for: .normal)
      button.layer.cornerRadius = Constants.cornerRadius
      button.layer.borderWidth = Constants.borderWidth
      button.layer.borderColor = UIColor.black.cgColor
    }
    
    startDateLabel.text = Strings.Actions.startTitle
    endDateLabel.text = Strings.Actions.endTitle
    startDateLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
    endDateLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
    
    startDatePicker.datePickerMode = .date
    endDatePicker.datePickerMode = .date
    startDatePicker.minimumDate = Date()
    startDatePicker.maximumDate = Date().addingTimeInterval(60 * 60 * 24 * 7 * 4)
    endDatePicker.minimumDate = Date()
    endDatePicker.maximumDate = Date().addingTimeInterval(60 * 60 * 24 * 7 * 4)
    startDatePicker.addTarget(self, action: #selector(handleStartDatePicker(_:)), for: .valueChanged)
    endDatePicker.addTarget(self, action: #selector(handleEndDatePicker(_:)), for: .valueChanged)
    
    [startDateTextField, endDateTextField].forEach { textField in
      textField.delegate = self
      textField.placeholder = Strings.Actions.dateFormatterPlaceholder
      textField.layer.cornerRadius = Constants.cornerRadius
      textField.layer.borderColor = Colors.Login.backgroundColor.cgColor
      textField.layer.borderWidth = Constants.borderWidth
    }
    startDateTextField.inputView = startDatePicker
    endDateTextField.inputView = endDatePicker
    let nextButton = UIBarButtonItem(title: Strings.Actions.nextTitle, style: UIBarButtonItem.Style.done, target: self, action: #selector(RemoteToast.nextButton))
    startDateTextField.inputAccessoryView = UIToolbar.toolbarPiker(rightButton: nextButton)
    let doneButton = UIBarButtonItem(title: Strings.Actions.doneTitle, style: UIBarButtonItem.Style.done, target: self, action: #selector(RemoteToast.doneButton))
    endDateTextField.inputAccessoryView = UIToolbar.toolbarPiker(rightButton: doneButton)
  }
  
  func update(onConfirm: ((RemoteType) -> Void)?,
              needsLayout: Event,
              onError: ((String) -> Void)?,
              onCancel: Event) {
    self.onConfirm = onConfirm
    self.needsLayout = needsLayout
    self.onError = onError
    self.onCancel = onCancel
  }
  
  @objc func nextButton() {
    startDateTextField.text = DateFormatters.remoteDateFormatter.string(from: startDatePicker.date)
    endDateTextField.becomeFirstResponder()
  }
  
  @objc func doneButton() {
    endDateTextField.text = DateFormatters.remoteDateFormatter.string(from: endDatePicker.date)
    self.endEditing(true)
  }
  
  @objc func didSelectTodayButton() {
    onConfirm?(.today)
  }
  
  @objc func didSelectInAHourButton() {
    onConfirm?(.tommorow)
  }
  
  @objc func didSelectCustomTimeButton() {
    [todayButton, tomorrowButton, customDatesButton].forEach{ $0.removeFromSuperview() }
    [startDateLabel, endDateLabel, startDateTextField, endDateTextField, confirmButton].forEach(self.addSubviewAndDisableMaskTranslate)
    startDateLabel.snp.makeConstraints { maker in
      maker.centerY.equalTo(startDateTextField)
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
    }
    endDateLabel.snp.makeConstraints { maker in
      maker.centerY.equalTo(endDateTextField)
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
    }
    startDateTextField.snp.makeConstraints { maker in
      maker.top.equalTo(titleLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.height.equalTo(Constants.textFieldHeight)
      maker.leading.equalTo(startDateLabel.snp.trailing)
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
    }
    endDateTextField.snp.makeConstraints { maker in
      maker.top.equalTo(startDateTextField.snp.bottom).offset(Constants.defaultOffset)
      maker.height.equalTo(Constants.textFieldHeight)
      maker.width.equalTo(startDateTextField)
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
    }
    cancelButtonCenterXConstraint?.update(offset: Constants.centerOffset)
    cancelButtonTopConstraint?.deactivate()
    cancelButton.snp.makeConstraints { maker in
      maker.top.equalTo(endDateTextField.snp.bottom).offset(Constants.defaultOffset)
    }
    confirmButton.snp.makeConstraints { maker in
      maker.top.equalTo(endDateTextField.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview().offset(-Constants.centerOffset)
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
    }
    
    titleLabel.text = Strings.Actions.remoteDates
    needsLayout?()
  }
  
  @objc func handleStartDatePicker(_ datePicker: UIDatePicker) {
    startDateTextField.text = DateFormatters.remoteDateFormatter.string(from: datePicker.date)
  }
  
  @objc func handleEndDatePicker(_ datePicker: UIDatePicker) {
    endDateTextField.text = DateFormatters.remoteDateFormatter.string(from: datePicker.date)
  }
  
  @objc func didSelectConfirmButton() {
    guard let startDate = startDateTextField.text, !startDate.isEmpty else {
      onError?(Strings.Actions.Error.chooseStart)
      return
    }
    
    guard let endDate = endDateTextField.text, !endDate.isEmpty else {
      onError?(Strings.Actions.Error.chooseEnd)
      return
    }
    
    guard startDatePicker.date <= endDatePicker.date else {
      onError?(Strings.Actions.Error.startLargerEnd)
      return
    }
    onConfirm?(.custom(start: startDatePicker.date, end: endDatePicker.date))
  }
  
  @objc func didSelectCancelButton() {
    onCancel?()
  }
}

// MARK: - UITextFieldDelegate

extension RemoteToast: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return false
  }
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
}
