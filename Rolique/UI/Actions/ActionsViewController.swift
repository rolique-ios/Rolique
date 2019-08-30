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
  private var tableView = UITableView()
  private var pochavToast: PochavToast?// = constructPochavToast()
  private var dopracToast: DopracToast?// = constructDopracToast()
  private var remoteToast: RemoteToast?// = constructRemoteToast()
  private var lateToast: LateToast?// = constructLateToast()
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
  
  private func loadToasts() {
    pochavToast = constructPochavToast()
    dopracToast = constructDopracToast()
    remoteToast = constructRemoteToast()
    lateToast = constructLateToast()
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
      Toast.current.hide({
        Spitter.showOkAlert(text, viewController: self)
      })
    }
  }
  
  private func constructPochavToast() -> PochavToast {
    let view = PochavToast()
    view.update(onConfirm: { [weak self] in
      self?.viewModel.pochav()
      }, onCancel: {
        Toast.current.hide()
    })
    return view
  }
  
  private func constructDopracToast() -> DopracToast {
    let view = DopracToast()
    view.update(onConfirm: { [weak self] type in
      self?.viewModel.doprac(type: type)
      }, needsLayout: {
        Toast.current.layoutVertically()
    }, onCancel: {
        Toast.current.hide()
    })
    return view
  }
  
  private func constructRemoteToast() -> RemoteToast {
    let view = RemoteToast()
    view.update(onConfirm: { [weak self] type in
      self?.viewModel.remote(type: type)
      }, needsLayout: {
        Toast.current.layoutVertically()
    }, onError: { error in
      Spitter.showOkAlertOnPVC(error)
    }, onCancel: {
      Toast.current.hide()
    })
    return view
  }
  
  private func constructLateToast() -> LateToast {
    let view = LateToast()
    view.update(onConfirm: { [weak self] type in
      self?.viewModel.late(type: type)
      }, needsLayout: {
        Toast.current.layoutVertically()
    }, onCancel: {
      Toast.current.hide()
    })
    return view
  }
  
  func didSelectCell(action: ActionType) {
    switch action {
    case .late:
      lateToast?.refreshView()
      guard let toast = lateToast else { return }
      Toast.current.show(toast)
    case .remote:
      remoteToast?.refreshView()
      guard let toast = remoteToast else { return }
      Toast.current.show(toast)
    case .doprac:
      dopracToast?.refreshView()
      guard let toast = dopracToast else { return }
      Toast.current.show(toast)
    case .pochav:
      guard let toast = pochavToast else { return }
      Toast.current.show(toast)
    }
  }
}
