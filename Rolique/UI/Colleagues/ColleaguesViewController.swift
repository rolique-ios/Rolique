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

final class ColleaguesViewController<T: ColleaguesViewModel>: ViewController<T> {
  private lazy var tableView = UITableView()
  private lazy var segmentedControl = UISegmentedControl()
  private var dataSource: ColleaguesDataSource!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureTableView()
    configureBinding()
    viewModel.all()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    title = Strings.NavigationTitle.colleagues
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigationController?.navigationBar.barTintColor = Colors.Login.backgroundColor
    navigationController?.navigationBar.tintColor = .black
    let searchController = UISearchController(searchResultsController: nil)
    navigationItem.searchController = searchController
  }
  
  private func configureConstraints() {
    [tableView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    
    tableView.snp.makeConstraints { maker in
      maker.edges.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
  
  private func configureUI() {
    self.view.backgroundColor = Colors.Colleagues.softWhite
  }
  
  private func configureTableView() {
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    dataSource = ColleaguesDataSource(tableView: tableView, data: viewModel.users)
  }
  
  private func configureBinding() {
    viewModel.onSuccess = { [weak self] in
      guard let self = self else { return }
      self.dataSource.update(dataSource: self.viewModel.users)
    }
  }
  
}
