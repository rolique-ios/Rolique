//
//  ColleaguesViewController.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/15/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import SnapKit
import Utils

enum UsersStatus: Int {
  case all, remote, vacation
  
  var description: String {
    switch self {
    case .all:
      return "All"
    case .remote:
      return "Remote"
    case .vacation:
      return "Vacation"
    }
  }
}

final class ColleaguesViewController<T: ColleaguesViewModel>: ViewController<T> {  
  private lazy var tableView = UITableView()
  private lazy var segmentedControl = UISegmentedControl()
  private lazy var tableViewHeader = UIView()
  private var dataSource: ColleaguesDataSource!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureTableView()
    configureBinding()
    viewModel.refreshList()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = Strings.NavigationTitle.colleagues
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.prefersLargeTitles = true
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigationController?.navigationBar.titleTextAttributes = attributes
    navigationController?.navigationBar.largeTitleTextAttributes = attributes
    navigationController?.navigationBar.barTintColor = Colors.Login.backgroundColor
    navigationController?.navigationBar.tintColor = UIColor.white
    let searchController = UISearchController(searchResultsController: nil)
    navigationItem.searchController = searchController
  }
  
  private func configureConstraints() {
    [tableView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    
    tableView.snp.makeConstraints { maker in
      maker.edges.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    tableViewHeader.frame = CGRect(center: .zero, size: CGSize(width: tableView.bounds.width, height: 50))
    tableViewHeader.addSubview(segmentedControl)
    segmentedControl.snp.makeConstraints { maker in
      maker.center.equalTo(tableViewHeader)
    }
  }
  
  private func configureUI() {
    self.view.backgroundColor = Colors.Colleagues.softWhite
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    segmentedControl.insertSegment(withTitle: UsersStatus.all.description, at: UsersStatus.all.rawValue, animated: false)
    segmentedControl.insertSegment(withTitle: UsersStatus.remote.description, at: UsersStatus.remote.rawValue, animated: false)
    segmentedControl.insertSegment(withTitle: UsersStatus.vacation.description, at: UsersStatus.vacation.rawValue, animated: false)
    segmentedControl.tintColor = Colors.Login.backgroundColor
    segmentedControl.selectedSegmentIndex = viewModel.usersStatus.rawValue
    segmentedControl.addTarget(self, action: #selector(didChangeSegment(_:)), for: .valueChanged)
    tableView.tableHeaderView = tableViewHeader
  }
  
  private func configureTableView() {
    dataSource = ColleaguesDataSource(tableView: tableView, data: viewModel.users)
  }
  
  @objc func didChangeSegment(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex != viewModel.usersStatus.rawValue {
      guard let usersStatus = UsersStatus(rawValue: sender.selectedSegmentIndex) else { return }
      viewModel.usersStatus = usersStatus
      viewModel.refreshList()
    }
  }
  
  private func configureBinding() {
    viewModel.onRefreshList = { [weak self] in
      guard let self = self else { return }
      self.dataSource.update(dataSource: self.viewModel.users)
    }
  }
}
