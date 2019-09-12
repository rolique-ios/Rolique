//
//  RecordTypeToast.swift
//  Rolique
//
//  Created by Maks on 8/29/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

final class RecordTypeToast: UIView {
  private struct Constants {
    static var defaultOffset: CGFloat { return 20.0 }
    static var tableViewSeparatorInset: UIEdgeInsets { return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) }
    static var tableViewRowHeight: CGFloat { return 50 }
  }
  private lazy var tableView = UITableView()
  private var data = [RecordType]()
  private var selectedIndex = 0
  private var tableViewHeightConstraint: Constraint?
  var onSelectRow: ((RecordType) -> Void)?
  
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
    [tableView].forEach(self.addSubviewAndDisableMaskTranslate)
    
    tableView.snp.makeConstraints { maker in
      maker.top.equalTo(self.safeAreaLayoutGuide).offset(Constants.defaultOffset)
      maker.bottom.equalTo(self.safeAreaLayoutGuide).offset(-Constants.defaultOffset)
      maker.leading.equalTo(self.safeAreaLayoutGuide).offset(Constants.defaultOffset)
      maker.trailing.equalTo(self.safeAreaLayoutGuide).offset(-Constants.defaultOffset)
      tableViewHeightConstraint = maker.height.equalTo(0).constraint
    }
  }
  
  private func configureUI() {
    tableView.separatorInset = Constants.tableViewSeparatorInset
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  func update(data: [RecordType],
              onSelectRow: ((RecordType) -> Void)?) {
    self.onSelectRow = onSelectRow
    self.data = data
    tableViewHeightConstraint?.update(offset: CGFloat(data.count) * Constants.tableViewRowHeight)
  }
}

extension RecordTypeToast: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    if selectedIndex == indexPath.row {
      cell.accessoryType = .checkmark
    }
    cell.selectionStyle = .none
    cell.textLabel?.text = data[indexPath.row].desctiption
    return cell
  }
}

extension RecordTypeToast: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
      cell.accessoryType = .checkmark
    }
    if selectedIndex != indexPath.row, let cell = tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) {
      cell.accessoryType = .none
    }
    selectedIndex = indexPath.row
    onSelectRow?(data[indexPath.row])
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Constants.tableViewRowHeight
  }
}
