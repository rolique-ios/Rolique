//
//  ActionsViewController.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 8/27/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import SnapKit
import IgyToast

final class ActionsViewController<T: ActionsViewModel>: ViewController<T>, ActionsDelegate {
  private lazy var tableView = UITableView()
  private lazy var pochavToast = constructPochavToast()
  private lazy var dopracToast = constructDopracToast()
  private lazy var remoteToast = constructRemoteToast()
  private lazy var lateToast = constructLateToast()
  private var dataSource: ActionsDataSource!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureBinding()
    dataSource = ActionsDataSource(tableView: tableView, data: ActionType.allCases, delegate: self)
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
  }
  
  private func configureConstraints() {
    [tableView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    
    tableView.snp.makeConstraints { maker in
      maker.edges.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
  
  private func configureUI() {
    title = Strings.NavigationTitle.actions
    self.view.backgroundColor = Colors.Colleagues.softWhite
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
  }
  
  private func configureBinding() {
    viewModel.onResponse = { [weak self] text in
      guard let self = self else { return }
      Toast.current.hideToast({
        Spitter.showOkAlert(text, viewController: self)
      })
    }
  }
  
  private func constructPochavToast() -> PochavToast {
    let view = PochavToast()
    view.update(onConfirm: { [weak self] in
      self?.viewModel.pochav()
      }, onCancel: {
        Toast.current.hideToast()
    })
    return view
  }
  
  private func constructDopracToast() -> DopracToast {
    let view = DopracToast()
    view.update(onConfirm: { [weak self] type in
      self?.viewModel.doprac(type: type)
      }, needsLayout: {
        Toast.current.toastVC?.layoutVertically()
    }, onCancel: {
        Toast.current.hideToast()
    })
    return view
  }
  
  private func constructRemoteToast() -> RemoteToast {
    let view = RemoteToast()
    view.update(onConfirm: { [weak self] type in
      self?.viewModel.remote(type: type)
      }, needsLayout: {
        Toast.current.toastVC?.layoutVertically()
    }, onError: { error in
      Spitter.showOkAlertOnPVC(error)
    }, onCancel: {
      Toast.current.hideToast()
    })
    return view
  }
  
  private func constructLateToast() -> LateToast {
    let view = LateToast()
    view.update(onConfirm: { [weak self] type in
      self?.viewModel.late(type: type)
      }, needsLayout: {
        Toast.current.toastVC?.layoutVertically()
    }, onCancel: {
      Toast.current.hideToast()
    })
    return view
  }
  
  func didSelectCell(action: ActionType) {
    switch action {
    case .late:
      lateToast.refreshView()
      Toast.current.showToast(lateToast)
    case .remote:
      remoteToast.refreshView()
      Toast.current.showToast(remoteToast)
    case .doprac:
      dopracToast.refreshView()
      Toast.current.showToast(dopracToast)
    case .pochav:
      Toast.current.showToast(pochavToast)
    }
  }
}
