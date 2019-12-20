//
//  MoreDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/7/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

private struct CellInfo {
  let icon: UIImage?
  let title: String
}

private struct Constants {
  static var userCellHeight: CGFloat { return 80 }
  static var defaultCellHeight: CGFloat { return 50 }
  static var heightForHeaderInSection: CGFloat { return 15.0 }
  static var heightForFooterInSection: CGFloat { return 0.0001 }
}

private enum Section: Int, CaseIterable {
  case profile,
  general
  
  var rows: [Row] {
    switch self {
    case .profile:
      return [.user]
    case .general:
      return [.meetingRoom]
    }
  }
}

enum Row: Int, CaseIterable {
  case user,
  meetingRoom
}

private extension Row {
  var data: CellInfo? {
    switch self {
    case .meetingRoom:
      return CellInfo(icon: R.image.meetingRoom(), title: Strings.More.meetingRooms)
    default:
      return nil
    }
  }
}

final class MoreDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let tableView: UITableView
  private let user: User
  private lazy var sections = Section.allCases
  var didSelectCell: ((Row) -> Void)?
  
  init(tableView: UITableView,
       user: User) {
    self.tableView = tableView
    self.user = user
    
    super.init()
    
    tableView.backgroundColor = Colors.seconaryGroupedBackgroundColor
    tableView.setDelegateAndDataSource(self)
    tableView.register([ProfileTableViewCell.self,
                        MoreTableViewCell.self])
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].rows.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = sections[indexPath.section]
    let row = section.rows[indexPath.row]
    
    switch (section, row) {
    case (.profile, .user):
      let cell = ProfileTableViewCell.dequeued(by: tableView)
      cell.configure(with: user.slackProfile.realName,
                     userImage: user.biggestImage,
                     todayStatus: user.todayStatus,
                     title: user.slackProfile.title)
      return cell
    case (.general, .meetingRoom):
      let cell = MoreTableViewCell.dequeued(by: tableView)
      let cellInfo = row.data!
      cell.configure(with: cellInfo.title, icon: cellInfo.icon)
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let section = sections[indexPath.section]
    let row = section.rows[indexPath.row]
    
    switch (section, row) {
    case (.profile, .user):
      return Constants.userCellHeight
    case (.general, .meetingRoom):
      return Constants.defaultCellHeight
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = sections[indexPath.section]
    let row = section.rows[indexPath.row]
    didSelectCell?(row)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return Constants.heightForHeaderInSection
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return Constants.heightForFooterInSection
  }
  
}