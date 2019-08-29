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
import IgyToast

final class ColleaguesViewController<T: ColleaguesViewModel>: ViewController<T>, UISearchBarDelegate {
  private lazy var tableView = UITableView()
  private lazy var tableViewHeader = UIView()
  private lazy var searchBar = UISearchBar()
  private lazy var recordTypeToast = constructRecordTypeToast()
  private var dataSource: ColleaguesDataSource!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureTableViews()
    configureBinding()
    viewModel.all()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureNavigationBar()
  }
  
  private func configureNavigationBar() {
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.prefersLargeTitles = true
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigationController?.navigationBar.titleTextAttributes = attributes
    navigationController?.navigationBar.largeTitleTextAttributes = attributes
    navigationController?.navigationBar.barTintColor = Colors.Login.backgroundColor
    navigationController?.navigationBar.tintColor = UIColor.white
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: UIBarButtonItem.Style.done, target: self, action: #selector(didSelectSortButton))
  }
  
  private func configureConstraints() {
    [tableView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    tableView.snp.makeConstraints { maker in
      maker.top.equalTo(self.view.safeAreaLayoutGuide)
      maker.leading.equalTo(self.view.safeAreaLayoutGuide)
      maker.trailing.equalTo(self.view.safeAreaLayoutGuide)
      maker.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    tableViewHeader.frame = CGRect(center: .zero, size: CGSize(width: tableView.bounds.width, height: 60))
    tableViewHeader.addSubview(searchBar)
    searchBar.snp.makeConstraints { maker in
      maker.edges.equalTo(tableViewHeader)
    }
    tableView.tableHeaderView = tableViewHeader
  }
  
  private func configureUI() {
    title = Strings.NavigationTitle.colleagues
    self.view.backgroundColor = Colors.Colleagues.softWhite
    
    searchBar.delegate = self
    searchBar.returnKeyType = .done
    searchBar.barTintColor = UIColor.clear
    searchBar.backgroundColor = UIColor.clear
    searchBar.isTranslucent = true
    searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
      if let backgroundview = textfield.subviews.first {
        backgroundview.backgroundColor = UIColor.white
        backgroundview.layer.shadowColor = UIColor.black.cgColor
        backgroundview.layer.shadowRadius = 4.0
        backgroundview.layer.shadowOffset = CGSize(width: 0, height: 7)
        backgroundview.layer.shadowOpacity = 0.1
        backgroundview.layer.cornerRadius = 10.0;
      }
    }
  }
  
  private func configureTableViews() {
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    tableView.refreshControl = refreshControl
    dataSource = ColleaguesDataSource(tableView: tableView, data: viewModel.users)
  }
  
  private func configureBinding() {
    viewModel.onRefreshList = { [weak self] listType in
      guard let self = self else { return }
      
      if self.viewModel.isSearching {
        self.dataSource.update(dataSource: self.viewModel.searchedUsers)
      } else {
        switch listType {
        case .all:
          self.dataSource.update(dataSource: self.viewModel.users)
        case .filtered:
          self.dataSource.update(dataSource: self.viewModel.filteredUsers)
        }
      }
      self.dataSource.hideRefreshControl()
    }
    
    viewModel.onError = { [weak self] segment in
      guard let self = self else { return }
      self.dataSource.hideRefreshControl()
    }
  }
  
  @objc func refresh() {
    viewModel.refresh()
  }
  
  @objc func didSelectSortButton() {
    Toast.current.showToast(recordTypeToast)
  }
  
  private func constructRecordTypeToast() -> RecordTypeToast {
    let view = RecordTypeToast()
    view.update(data: RecordType.allCases,
                onSelectRow: { [weak self] recordType in
                  Toast.current.hideToast()
                  self?.viewModel.recordType = recordType
                  if recordType == .all {
                    self?.viewModel.listType = .all
                    self?.viewModel.all()
                  } else {
                    self?.viewModel.listType = .filtered
                    self?.viewModel.sort(recordType)
                  }
    })
    return view
  }
  
  // MARK: - UISearchBarDelegate
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    viewModel.isSearching = false
    viewModel.onRefreshList?(viewModel.listType)
    searchBar.resignFirstResponder()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text == nil || searchBar.text == "" {
      viewModel.isSearching = false
    } else {
      viewModel.isSearching = true
    }
    viewModel.searchUser(with: searchText)
  }
  
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.setShowsCancelButton(true, animated: true)
    return true
  }
  
  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.setShowsCancelButton(false, animated: true)
    return true
  }
}
