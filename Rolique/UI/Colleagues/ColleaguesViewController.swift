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

final class ColleaguesViewController<T: ColleaguesViewModel>: ViewController<T>, UIScrollViewDelegate, UISearchBarDelegate {
  private lazy var scrollView = UIScrollView()
  private lazy var segmentedView = SegmentedView()
  private lazy var tableViews = [UITableView(), UITableView(), UITableView()]
  private lazy var tableViewHeader = UIView()
  private lazy var searchBar = UISearchBar()
  private var dataSources = [ColleaguesDataSource]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureTableViews()
    configureBinding()
    viewModel.all()
    viewModel.onRemote()
    viewModel.onVacation()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
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
  }
  
  override func performOnceInViewDidAppear() {
    self.segmentedView.configure(with: [UsersStatus.all.description,
                                        UsersStatus.remote.description,
                                        UsersStatus.vacation.description],
                                 titleColor: Colors.Colleagues.lightBlue,
                                 indicatorHeight: 3,
                                 indicatorColor: Colors.Login.backgroundColor)
    setupScrollView()
  }
  
  private func configureConstraints() {
    [segmentedView, scrollView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    
    segmentedView.snp.makeConstraints { maker in
      maker.top.equalTo(self.view.safeAreaLayoutGuide)
      maker.leading.equalTo(self.view.safeAreaLayoutGuide)
      maker.trailing.equalTo(self.view.safeAreaLayoutGuide)
      maker.height.equalTo(40)
    }
    
    scrollView.snp.makeConstraints { maker in
      maker.top.equalTo(self.segmentedView.snp.bottom)
      maker.leading.equalTo(self.view.safeAreaLayoutGuide)
      maker.trailing.equalTo(self.view.safeAreaLayoutGuide)
      maker.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    tableViewHeader.frame = CGRect(center: .zero, size: CGSize(width: tableViews[UsersStatus.all.rawValue].bounds.width, height: 60))
    tableViewHeader.addSubview(searchBar)
    searchBar.snp.makeConstraints { maker in
      maker.edges.equalTo(tableViewHeader)
    }
  }
  
  private func configureUI() {
    self.view.backgroundColor = Colors.Colleagues.softWhite
    
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isPagingEnabled = true
    scrollView.bounces = false
    scrollView.isDirectionalLockEnabled = true
    
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
    for (index, tableView) in tableViews.enumerated() {
      tableView.separatorStyle = .none
      tableView.backgroundColor = .clear
      
      guard let status = UsersStatus(rawValue: index) else { return }
      switch status {
      case .all:
        tableView.tableHeaderView = tableViewHeader
        dataSources.append(ColleaguesDataSource(tableView: tableView, data: viewModel.users))
      case .remote:
        dataSources.append(ColleaguesDataSource(tableView: tableView, data: viewModel.usersOnRemote))
      case .vacation:
        dataSources.append(ColleaguesDataSource(tableView: tableView, data: viewModel.usersOnVacation))
      }
    }
  }
  
  private func setupScrollView() {
    self.segmentedView.selectedSegmentDidChanged = { [weak self] selectedIndex in
      guard let strongSelf = self else { return }
      
      let scrollViewWidth = strongSelf.scrollView.frame.width
      let contentOffsetX = scrollViewWidth * CGFloat(selectedIndex)
      let contentOffsetY = strongSelf.scrollView.contentOffset.y
      strongSelf.scrollView.setContentOffset(
        CGPoint(x: contentOffsetX, y: contentOffsetY),
        animated: true
      )
      strongSelf.changeTableViewDelegate(currentPage: selectedIndex)
    }
    
    scrollView.contentSize = CGSize(
      width: UIScreen.main.bounds.width * CGFloat(tableViews.count),
      height: scrollView.frame.height
    )
    
    for (index, tableView) in tableViews.enumerated() {
      tableView.frame = CGRect(
        x: UIScreen.main.bounds.width * CGFloat(index),
        y: 0,
        width: scrollView.frame.width,
        height: scrollView.frame.height
      )
      scrollView.addSubview(tableView)
    }
    
    scrollView.delegate = self
  }
  
  private func configureBinding() {
    viewModel.onRefreshList = { [weak self] status in
      guard let self = self else { return }
      switch status {
      case .all:
        if self.viewModel.isSearching {
          self.dataSources[status.rawValue].update(dataSource: self.viewModel.searchedUsers)
        } else {
          self.dataSources[status.rawValue].update(dataSource: self.viewModel.users)
        }
      case .remote:
        self.dataSources[status.rawValue].update(dataSource: self.viewModel.usersOnRemote)
      case .vacation:
        self.dataSources[status.rawValue].update(dataSource: self.viewModel.usersOnVacation)
      }
    }
  }
  
  private func changeTableViewDelegate(currentPage: Int) {
    segmentedView.selectedSegmentIndex = currentPage
  }
  
  // MARK: - UIScrollViewDelegate
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let page = floor(scrollView.contentOffset.x / scrollView.frame.width)
    changeTableViewDelegate(currentPage: Int(page))
  }
  
  // MARK: - UISearchBarDelegate
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    viewModel.isSearching = false
    viewModel.onRefreshList?(.all)
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
