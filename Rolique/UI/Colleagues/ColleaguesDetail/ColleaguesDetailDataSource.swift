//
//  ColleaguesDetailDataSource.swift
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
}

final class ColleaguesDetailDataSource: NSObject, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
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
    additionalInfo
    
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
  var onScroll: (() -> Void)?
  
  private(set) var sections = Section.allCases
  
  init(tableView: UITableView, user: User) {
    self.tableView = tableView
    self.user = user
    
    super.init()
    
    self.tableView.setDelegateAndDataSource(self)
    self.tableView.register([MajorTableViewCell.self, TitledSectionTableViewCell.self, InfoTableViewCell.self])
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
      
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: user.slackProfile.phone.trimmingCharacters(in: .whitespacesAndNewlines),
                         interactiveView: UIImageView(image: Images.Colleagues.phone),
                         target: self,
                         action: #selector(touchPhoneIcon),
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .email:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      let imageView = UIImageView(image: Images.Profile.email)
      imageView.contentMode = .scaleAspectFit
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: user.slackProfile.email,
                         interactiveView: imageView,
                         target: self,
                         action: #selector(touchEmailIcon),
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .skype:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: user.slackProfile.skype,
                         interactiveView: UIImageView(image: Images.Profile.skype),
                         target: self,
                         action: #selector(touchSkypeIcon),
                         isLast: lastCell(indexPath: indexPath))
      return infoCell
    case .vacationData:
      if indexPath.row == 0 {
        return setTitledCell(section: section)
      }
      
      guard let vacationData = user.vacationData else { return UITableViewCell() }
      let dateArray = vacationData.compactMap { $0.key }.sorted()
      let infoCell = InfoTableViewCell.dequeued(by: tableView)
      infoCell.configure(with: Strings.Profile.vacationDays(args: dateArray[indexPath.row - 1], vacationData[dateArray[indexPath.row - 1]].orZero),
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
    default:
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let section = sections[indexPath.section]
    if section == .title {
      return Constants.titleCellHeight
    } else if lastCell(indexPath: indexPath) {
      return 46
    } else {
      return Constants.infoCellHeight
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    onScroll?()
  }
  
  @objc func touchPhoneIcon() {
    print("phone")
  }
  
  @objc func touchEmailIcon() {
    print("email")
  }
  
  @objc func touchSkypeIcon() {
    print("skype")
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
      return (!isMe || (user.vacationData ?? [:]).isEmpty) ? 0 : user.vacationData!.count + 1
    case .dateOfJoining:
      return (!isMe || user.dateOfJoining.orEmpty.isEmpty) ? 0 : 2
    case .roles:
      return (!isMe || user.roles.isEmpty) ? 0 : user.roles.count + 1
    case .achievements, .additionalInfo:
      return 0
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
}
