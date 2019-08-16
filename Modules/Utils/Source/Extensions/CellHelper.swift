//
//  CellHelper.swift
//  Dip
//
//  Created by Maksym Ivanyk on 8/16/19.
//

import UIKit

public protocol CellInitializer {}
extension UITableViewCell: CellInitializer {}

extension UITableViewCell {
  static public var cellIdentifier: String {
    return String(describing: self)
  }
}

extension CellInitializer where Self: UITableViewCell {
  static public func dequeued(with identifier: String, by tableView: UITableView) -> Self {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
      fatalError("no cell for identifier: \(identifier) on tableView: \(tableView)")
    }
    return cell as! Self
  }
  
  static public func dequeued(by tableView: UITableView) -> Self {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) else {
      fatalError("no cell for identifier: \(self.cellIdentifier) on tableView: \(tableView)")
    }
    return cell as! Self
  }
}
