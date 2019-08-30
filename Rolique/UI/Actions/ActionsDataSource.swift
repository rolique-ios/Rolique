//
//  ActionsDataSource.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/27/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils

protocol ActionsDelegate: class {
  func didSelectCell(action: ActionType)
}

final class ActionsDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let tableView: UITableView
  private var data: [ActionType]
  private let delegate: ActionsDelegate?
  
  init(tableView: UITableView, data: [ActionType], delegate: ActionsDelegate? = nil) {
    self.tableView = tableView
    self.data = data
    self.delegate = delegate
    
    super.init()
    
    self.tableView.setDelegateAndDataSource(self)
    self.tableView.register([ActionsTableViewCell.self])
  }
  
  func update(dataSource: [ActionType]) {
    self.data = dataSource
    self.tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = ActionsTableViewCell.dequeued(by: tableView)
    cell.configure(with: data[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.didSelectCell(action: data[indexPath.row])
    Spitter.tap(.pop)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
