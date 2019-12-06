//
//  BookMeetingRoomViewToast.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/25/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

private struct Constants {
  static var rowHeight: CGFloat { return 40.0 }
  static var separatorHeight: CGFloat { return 1.0 }
  static var participantLabelTopOffset: CGFloat { return 28.0 }
  static var addButtonSize: CGFloat { return 24.0 }
  static var defaultOffset: CGFloat { return 20.0 }
  static var buttonWidth: CGFloat { return 110.0 }
  static var buttonHeight: CGFloat { return 50.0 }
  static var buttonCenterXOffset: CGFloat { return 70.0 }
  static var timeInterspaceLabelInsets: UIEdgeInsets { return UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8) }
  static var tableViewRightOffset: CGFloat { return 10.0 }
}

final class BookMeetingRoomViewToast: UIView {
  private lazy var tableView = UITableView()
  private lazy var participantsLabel = UILabel()
  private lazy var addButton = UIButton()
  private lazy var participantSeparator = UIView()
  private lazy var titleTextField = UITextField()
  private lazy var timeInterspaceLabel = LabelWithInsets(insets: Constants.timeInterspaceLabelInsets)
  private lazy var cancelButton = CancelButton()
  private lazy var bookButton = UIButton()
  private var participants = [User]()
  private var tableViewHeightConstraint: Constraint?
  
  private var onAddUser: Completion?
  private var onRemoveUser: ((User) -> Void)?
  private var onBook: Completion?
  private var onCancel: Completion?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  private func initialize() {
    backgroundColor = Colors.mainBackgroundColor
    
    tableView.register([ParticipantTableViewCell.self])
    tableView.separatorStyle = .none
    tableView.isScrollEnabled = false
    tableView.setDelegateAndDataSource(self)
    
    participantsLabel.text = "Participants"
    participantsLabel.textColor = Colors.mainTextColor
    
    addButton.setImage(R.image.addParticipant(), for: .normal)
    addButton.addTarget(self, action: #selector(addButtonOnTap(_:)), for: .touchUpInside)
    
    participantSeparator.backgroundColor = Colors.separatorColor
    
    titleTextField.placeholder = "Title"
    titleTextField.delegate = self
    
    timeInterspaceLabel.textAlignment = .center
    timeInterspaceLabel.textColor = Colors.mainTextColor
    timeInterspaceLabel.font = .systemFont(ofSize: 20.0)
    timeInterspaceLabel.layer.borderWidth = 2.0
    timeInterspaceLabel.layer.borderColor = UIColor.orange.cgColor
    timeInterspaceLabel.roundCorner(radius: 5.0)
    
    bookButton.setTitle("Book", for: .normal)
    bookButton.backgroundColor = Colors.Actions.darkGray
    bookButton.roundCorner(radius: 5.0)
    bookButton.addTarget(self, action: #selector(bookButtonOnTap(_:)), for: .touchUpInside)
    
    cancelButton.addTarget(self, action: #selector(cancelButtonOnTap(_:)), for: .touchUpInside)
    
    configureConstraints()
  }
  
  private func configureConstraints() {
    [participantsLabel,
     tableView,
     addButton,
     participantSeparator,
     titleTextField,
     timeInterspaceLabel,
     cancelButton,
     bookButton].forEach(addSubviewAndDisableMaskTranslate(_:))
    
    participantsLabel.snp.makeConstraints { maker in
      maker.top.equalToSuperview().offset(Constants.participantLabelTopOffset)
      maker.left.equalToSuperview().offset(Constants.defaultOffset)
    }
    
    tableView.snp.makeConstraints { maker in
      maker.top.equalToSuperview().offset(Constants.defaultOffset)
      maker.left.equalToSuperview()
      maker.right.equalTo(addButton.snp.left).offset(-Constants.tableViewRightOffset)
      tableViewHeightConstraint = maker.height.equalTo(Constants.rowHeight).constraint
    }
    
    addButton.snp.makeConstraints { maker in
      maker.right.equalToSuperview().offset(-Constants.defaultOffset)
      maker.top.equalToSuperview().offset(Constants.participantLabelTopOffset)
      maker.size.equalTo(Constants.addButtonSize)
    }
    
    participantSeparator.snp.makeConstraints { maker in
      maker.top.equalTo(tableView.snp.bottom).offset(Constants.defaultOffset)
      maker.left.right.equalToSuperview()
      maker.height.equalTo(Constants.separatorHeight)
    }
    
    titleTextField.snp.makeConstraints { maker in
      maker.top.equalTo(participantSeparator.snp.bottom).offset(Constants.defaultOffset)
      maker.left.right.equalToSuperview().offset(Constants.defaultOffset)
    }
    
    timeInterspaceLabel.snp.makeConstraints { maker in
      maker.top.equalTo(titleTextField.snp.bottom).offset(Constants.defaultOffset)
      maker.centerX.equalToSuperview()
    }
    
    cancelButton.snp.makeConstraints { maker in
      maker.top.equalTo(timeInterspaceLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
      maker.centerX.equalToSuperview().offset(-Constants.buttonCenterXOffset)
      maker.bottom.equalTo(self.safeAreaLayoutGuide).offset(-Constants.defaultOffset)
    }
    
    bookButton.snp.makeConstraints { maker in
      maker.top.equalTo(timeInterspaceLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.height.equalTo(Constants.buttonHeight)
      maker.width.equalTo(Constants.buttonWidth)
      maker.centerX.equalToSuperview().offset(Constants.buttonCenterXOffset)
    }
  }
  
  func update(timeInterspace: TimeInterspace, onAddUser: Completion?, participants: [User], onRemoveUser: ((User) -> Void)?, onBook: Completion?, onCancel: Completion?) {
    timeInterspaceLabel.text = DateFormatters.timeDateFormatter.string(from: timeInterspace.startTime) + " - " + DateFormatters.timeDateFormatter.string(from: timeInterspace.endTime)
    self.onAddUser = onAddUser
    self.onRemoveUser = onRemoveUser
    self.onBook = onBook
    self.onCancel = onCancel
    self.participants = participants
    updateTableView()
  }
  
  @objc func addButtonOnTap(_ button: UIButton) {
    self.onAddUser?()
  }
  
  @objc func bookButtonOnTap(_ button: UIButton) {
    self.onBook?()
  }
  
  @objc func cancelButtonOnTap(_ button: UIButton) {
    self.onCancel?()
  }
  
  private func updateTableView() {
    tableView.reloadData()
    tableViewHeightConstraint?.update(offset: participants.isEmpty ? Constants.rowHeight : (CGFloat(participants.count) * Constants.rowHeight))
    tableView.isHidden = participants.count == 0
  }
}

extension BookMeetingRoomViewToast: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return participants.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = ParticipantTableViewCell.dequeued(by: tableView)
    let user = participants[indexPath.row]
    cell.selectionStyle = .none
    cell.update(fullName: user.slackProfile.realName,
                imageUrlString: user.optimalImage,
                removeButtonOnTap: { [weak self] in
                  guard let self = self else { return }
                  _ = self.participants.firstIndex(of: user).map { self.participants.remove(at: $0) }
                  self.updateTableView()
                  self.onRemoveUser?(user)
    })
    return cell
  }
}

extension BookMeetingRoomViewToast: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Constants.rowHeight
  }
}

extension BookMeetingRoomViewToast: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return true
  }
}
