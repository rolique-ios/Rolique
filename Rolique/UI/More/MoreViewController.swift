//
//  MoreViewController.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 11/7/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit

final class MoreViewController<T: MoreViewModel>: ViewController<T> {
  private var tableView = UITableView(frame: .zero, style: .grouped)
  private var dataSource: MoreDataSource?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    configureConstraints()
    configureBindings()
    self.navigationController?.addCustomTransitioning()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureNavigationBar()
  }
  
  private func configureUI() {
    title = Strings.NavigationTitle.more
    view.backgroundColor = Colors.seconaryGroupedBackgroundColor
  }
  
  private func configureConstraints() {
    [tableView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    
    tableView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
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
    navigationController?.setAppearance(with: attributes, backgroundColor: Colors.Login.backgroundColor)
  }
  
  private func configureBindings() {
    viewModel.onSuccess = { [weak self] in
      guard let self = self, let user = self.viewModel.user else { return }
      self.dataSource = MoreDataSource(tableView: self.tableView, user: user)
      self.configureDataSourceBindings()
      self.tableView.reloadData()
    }
    
    viewModel.onError = { [weak self] error in
      guard let self = self else { return }
      Spitter.showOkAlert(error, viewController: self)
    }
  }
  
  private func configureDataSourceBindings() {
    dataSource?.didSelectCell = { [weak self] type in
      guard let self = self else { return }
      switch type {
      case .user:
        self.navigationController?.pushViewController(Router.getProfileDetailViewController(user: self.viewModel.user), animated: true)
      case .meetingRooms:
        break
      }
    }
  }
}
