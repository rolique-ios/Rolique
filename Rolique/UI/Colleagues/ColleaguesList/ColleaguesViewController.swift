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

private struct Constants {
  static var headerHeight: CGFloat { return 50.0 }
}

final class ColleaguesViewController<T: ColleaguesViewModel>: ViewController<T>, UISearchBarDelegate, UINavigationControllerDelegate, UIViewControllerPreviewingDelegate, ProfileDetailViewControllerDelegate, Mailable {
  private lazy var tableView = UITableView()
  private lazy var tableViewHeader = UIView()
  private lazy var searchBar = UISearchBar()
  private lazy var recordTypeToast = constructRecordTypeToast()
  private lazy var recordTypeToastHeader = constructRecordTypeToastHeader()
  private var dataSource: ColleaguesDataSource!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: tableView)
    }
    
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
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    Toast.current.layoutVertically()
  }
  
  private func configureNavigationBar() {
    navigationController?.navigationBar.prefersLargeTitles = true
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigationController?.navigationBar.titleTextAttributes = attributes
    navigationController?.navigationBar.largeTitleTextAttributes = attributes
    navigationController?.navigationBar.barTintColor = Colors.Login.backgroundColor
    navigationController?.navigationBar.tintColor = .white
    let barButton = UIBarButtonItem()
    barButton.title = ""
    navigationItem.backBarButtonItem = barButton
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "🌀", style: UIBarButtonItem.Style.done, target: self, action: #selector(didSelectSortButton))
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
    searchBar.barTintColor = .clear
    searchBar.backgroundColor = .clear
    searchBar.isTranslucent = true
    searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
      if let backgroundview = textfield.subviews.first {
        backgroundview.backgroundColor = .white
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
    tableView.keyboardDismissMode = .interactive
    dataSource = ColleaguesDataSource(tableView: tableView, data: viewModel.users)
    dataSource.onUserTap = onUserSelect
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
    Toast.current.show(recordTypeToast, header: recordTypeToastHeader)
  }
  
  func onUserSelect(_ user: User) {
    Spitter.tap(.pop)
    view.endEditing(true)
    navigationController?.pushViewController(Router.getProfileDetailViewController(user: user), animated: true)
  }
  
  private func constructRecordTypeToastHeader() -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.snp.makeConstraints { maker in
      maker.height.equalTo(Constants.headerHeight)
    }
    
    let label = UILabel()
    view.addSubview(label)
    label.text = Strings.Collegues.showOptions
    label.font = .preferredFont(forTextStyle: .title2)
    label.textAlignment = .center
    label.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
    return view
  }
  
  private func constructRecordTypeToast() -> RecordTypeToast {
    let view = RecordTypeToast()
    view.update(data: RecordType.allCases,
                onSelectRow: { [weak self] recordType in
                  Toast.current.hide()
                  self?.viewModel.recordType = recordType
                  if recordType == .all {
                    self?.viewModel.listType = .all
                    self?.viewModel.all()
                  } else if recordType == .away {
                    self?.viewModel.listType = .filtered
                    self?.viewModel.away()
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
  
  // MARK: - UIViewControllerPreviewingDelegate
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
    let popVC = Router.getProfileDetailViewController(user: viewModel.users[indexPath.row])
    popVC.delegate = self
    return popVC
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    show(viewControllerToCommit, sender: self)
  }
  
  // MARK: - ProfileDetailViewControllerDelegate
  
  func sendEmail(_ emails: [String]) {
    self.sendEmail(to: emails)
  }
}
