//
//  ProfileDetailDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/19/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

private struct Constants {
  static var titleCellHeight: CGFloat { return 46 }
  static var infoCellHeight: CGFloat { return 30 }
  static var lastCellHeight: CGFloat { return 46 }
  static var clearCacheCellHeight: CGFloat { return 46 }
  static var logOutCellHeight: CGFloat { return 60 }
}

final class ProfileDetailDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  enum Section: Int, CaseIterable {
    case title,
    phone,
    email,
    skype,
    vacationData,
    roles,
    eduPoints,
    dateOfJoining,
    emergencyDays,
    birthday,
    achievements,
    additionalInfo,
    clearCache,
    logOut
    
    var description: String {
      switch self {
      case .phone:
        return Strings.Profile.phoneNumber
      case .email:
        return Strings.Profile.email
      case .skype:
        return Strings.Profile.skype
      case .vacationData:
        return Strings.Profile.vacationDays
      case .eduPoints:
        return Strings.Profile.eduPoints
      case .dateOfJoining:
        return Strings.Profile.dateOfJoining
      case .emergencyDays:
        return Strings.Profile.emergencyDays
      case .birthday:
        return Strings.Profile.birthday
      case .roles:
        return Strings.Profile.roles
      default:
        return ""
      }
    }
  }
  
  private let tableView: UITableView
  private var user: User
  private var lastIndexPath = IndexPath(row: 0, section: 0)
  private lazy var clearCacheButton = configureCacheButton()
  private lazy var logOutButton = configureLogOutButton()
  var onScroll: (() -> Void)?
  var copyString: ((String) -> Void)?
  var call: ((String) -> Void)?
  var sendEmail: (([String]) -> Void)?
  var openSkype: Completion?
  var clearCache: Completion?
  var logOut: Completion?
  
  private(set) var sections = Section.allCases
  
  init(tableView: UITableView, user: User) {
    self.tableView = tableView
    self.user = user
    
    super.init()
    
    self.tableView.setDelegateAndDataSource(self)
    self.tableView.register([MajorTableViewCell.self,
                             TitledSectionTableViewCell.self,
                             InfoTableViewCell.self,
                             AdditionalInfoTableViewCell.self,
                             InteractiveTableViewCell.self])
    self.findLastIndexPath()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let section = sections[section]
    return rowsCount(for: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = sections[indexPath.section]
    switch section {
    case .title:
      let cell = MajorTableViewCell.dequeued(by: tableView)
      cell.configure(with: user.slackProfile.title)
      return cell
    case .phone:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      let phone = user.slackProfile.phone.trimmingCharacters(in: .whitespacesAndNewlines)
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: phone,
                         icon: R.image.phone(),
                         onLongTap: { [unowned self] in
                          self.copyString?(phone)
        }, onTap: { [unowned self] in
          self.call?(phone)
        },
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .email:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      let email = self.user.slackProfile.email.orEmpty
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: user.slackProfile.email,
                         icon: R.image.email(),
                         onLongTap: { [unowned self] in
                          self.copyString?(email)
        }, onTap: { [unowned self] in
          self.sendEmail?([email])
        },
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .skype:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      let skype = user.slackProfile.skype.orEmpty
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: user.slackProfile.skype,
                         icon: R.image.skype(),
                         onLongTap: { [unowned self] in
                          self.copyString?(skype)
        }, onTap: { [unowned self] in
          self.openSkype?()
        },
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .vacationData:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      guard let vacationData = user.vacationData else { return UITableViewCell() }
      let dateArray = vacationData.compactMap { $0.key }.sorted(by: >)
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      let args = vacationData[dateArray[indexPath.row - 1]].orZero
      let title = indexPath.row == 1
        ? Strings.Profile.vacationDays(args: args)
        : Strings.Profile.vacationDaysFromPreviousYear(args: args)
      infoCell.configure(with: title,
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .roles:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: user.roles[indexPath.row - 1],
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .eduPoints:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: "\(user.eduPoints.orZero)",
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .dateOfJoining:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: user.dateOfJoining,
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .emergencyDays:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: "\(user.emergencyDays.orZero)",
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .birthday:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: user.birthday,
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .clearCache:
      let interactiveCell = InteractiveTableViewCell.dequeued(by: tableView)
      interactiveCell.configure(with: configureCacheButton(), isLast: lastCell(indexPath: indexPath), showSeparator: true)
      return interactiveCell
    case .logOut:
      let interactiveCell = InteractiveTableViewCell.dequeued(by: tableView)
      interactiveCell.configure(with: configureLogOutButton(), isLast: lastCell(indexPath: indexPath))
      return interactiveCell
    default:
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let section = sections[indexPath.section]
    if section == .title {
      return Constants.titleCellHeight
    } else if section == .clearCache {
      return Constants.clearCacheCellHeight
    } else if section == .logOut {
      return Constants.logOutCellHeight
    } else if lastCell(indexPath: indexPath) {
      return Constants.lastCellHeight
    } else {
      return Constants.infoCellHeight
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    onScroll?()
  }
  
  private func setTitledCell(section: Section) -> UITableViewCell {
    let titledCell = TitledSectionTableViewCell.dequeued(by: tableView)
    titledCell.configure(with: section.description.uppercased())
    return titledCell
  }
  
  private func rowsCount(for section: Section) -> Int {
    let isMe = user.id == UserDefaultsManager.shared.userId
    switch section {
    case .title:
      return user.slackProfile.title.isEmpty ? 0 : 1
    case .phone:
      return user.slackProfile.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 2
    case .email:
      return user.slackProfile.email.orEmpty.isEmpty ? 0 : 2
    case .skype:
      return user.slackProfile.skype.orEmpty.isEmpty ? 0 : 2
    case .vacationData:
      let vacationData = user.vacationData ?? [:]
      if (!isMe || vacationData.isEmpty) {
        return 0
      } else {
        let dateComponent = Calendar.current.dateComponents([.year], from: Date())
        let previousYears = vacationData.filter { $0.key != "\(dateComponent.year.orZero)" }
        let filtered = previousYears.filter { $0.value != 0 }
        return 1 + filtered.count + 1
      }
    case .dateOfJoining:
      return (!isMe || user.dateOfJoining.orEmpty.isEmpty) ? 0 : 2
    case .roles:
      return (!isMe || user.roles.isEmpty) ? 0 : user.roles.count + 1
    case .achievements, .additionalInfo:
      return 0
    case .clearCache, .logOut:
      return !isMe ? 0 : 1
    default:
      return !isMe ? 0 : 2
    }
  }
  
  private func findLastIndexPath() {
    sections.forEach { section in
      let rows = rowsCount(for: section)
      if rows > 0 {
        lastIndexPath.section = section.rawValue
        lastIndexPath.row = rows - 1
      }
    }
  }
  
  private func lastCell(indexPath: IndexPath) -> Bool {
    return lastIndexPath.section == indexPath.section && lastIndexPath.row == indexPath.row
  }
  
  private func configureCacheButton() -> UIButton {
    let clearCacheButton = UIButton()
    clearCacheButton.setTitle(getClearCacheTitle(), for: .normal)
    clearCacheButton.backgroundColor = .black
    clearCacheButton.roundCorner(radius: 5.0)
    clearCacheButton.addTarget(self, action: #selector(clearCacheButtonTap(_:)), for: UIControl.Event.touchUpInside)
    return clearCacheButton
  }
  
  private func configureLogOutButton() -> UIButton {
    let logOutButton = UIButton()
    logOutButton.setTitle(" " + Strings.Profile.logOutTitle + " ", for: UIControl.State.normal)
    logOutButton.setTitleColor(.red, for: .normal)
    logOutButton.layer.cornerRadius = 5.0
    logOutButton.layer.borderWidth = 2.0
    logOutButton.layer.borderColor = UIColor.red.cgColor
    logOutButton.addTarget(self, action: #selector(logOutButtonTap(_:)), for: UIControl.Event.touchUpInside)
    return logOutButton
  }
  
  func updateClearCacheButtonTitle() {
    guard rowsCount(for: .clearCache) != 0 else { return }
    tableView.reloadRows(at: [IndexPath(row: 0, section: Section.clearCache.rawValue)], with: .none)
  }
  
  @objc func logOutButtonTap(_ button: UIButton) {
    logOut?()
  }
  
  @objc func clearCacheButtonTap(_ button: UIButton) {
    clearCache?()
  }
  
  private func getClearCacheTitle() -> String {
    return " "
      + Strings.Profile.clearCache
      + "(\(ByteCountFormatters.fileSizeFormatter.string(fromByteCount: Int64(ImageManager.shared.findImagesDirectorySize()))))"
      + " "
  }
}
