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
  private lazy var tableView = UITableView(frame: .zero, style: .grouped)
  private lazy var dataSource = MoreDataSource(tableView: tableView, user: viewModel.user)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    configureConstraints()
    self.navigationController?.addCustomTransitioning()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureNavigationBar()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationController?.renewCustomTransition()
  }
  
  private func configureUI() {
    title = Strings.NavigationTitle.more
    view.backgroundColor = Colors.seconaryGroupedBackgroundColor
    
    configureDataSourceBindings()
  }
  
  private func configureConstraints() {
    [tableView].forEach(self.view.addSubview(_:))
    
    tableView.snp.makeConstraints { maker in
      maker.edges.equalTo(self.view.safeAreaLayoutGuide)
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
  
  private func configureDataSourceBindings() {
    dataSource.didSelectCell = { [weak self] type in
      guard let self = self else { return }
      switch type {
      case .user:
        self.navigationController?.pushViewController(Router.getProfileDetailViewController(user: self.viewModel.user), animated: true)
      case .meetingRoom:
        self.navigationController?.removeCustomTransition()
        let vc = Router.getMeetingRoomsViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }
}
