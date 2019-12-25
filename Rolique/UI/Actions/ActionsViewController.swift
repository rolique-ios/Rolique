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
  private var pochavToast: PochavToast?
  private var dopracToast: DopracToast?
  private var remoteToast: RemoteToast?
  private var lateToast: LateToast?
  private var dataSource: ActionsDataSource!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureBinding()
    dataSource = ActionsDataSource(tableView: tableView, data: ActionType.allCases, delegate: self)
    loadToasts()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureNavigationBar()
  }
  
  override func updateColors() {
    tableView.reloadData()
  }
  
  private func loadToasts() {
    pochavToast = constructPochavToast()
    dopracToast = constructDopracToast()
    remoteToast = constructRemoteToast()
    lateToast = constructLateToast()
  }
  
  private func configureNavigationBar() {
    navigationController?.navigationBar.prefersLargeTitles = true
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigationController?.navigationBar.titleTextAttributes = attributes
    navigationController?.navigationBar.largeTitleTextAttributes = attributes
    navigationController?.navigationBar.barTintColor = Colors.Login.backgroundColor
    navigationController?.navigationBar.tintColor = .white
    navigationController?.setAppearance(with: attributes, backgroundColor: Colors.Login.backgroundColor)
  }
  
  private func configureConstraints() {
    [tableView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    
    tableView.snp.makeConstraints { maker in
      maker.edges.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
  
  private func configureUI() {
    title = Strings.NavigationTitle.actions
    view.backgroundColor = Colors.mainBackgroundColor
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    Toast.current.backgroundColor = Colors.secondaryBackgroundColor
  }
  
  private func configureBinding() {
    viewModel.onResponse = { [weak self] text in
      guard let self = self else { return }
      self.hideSpinner()
      UIResultNotifier.shared.showAndHideAfterTime(text: text)
    }
  }
  
  private func constructPochavToast() -> PochavToast {
    let view = PochavToast()
    view.update(onConfirm: {
      Toast.current.hide({ [weak self] in
        guard let self = self else { return }
        self.viewModel.pochav()
        self.showSpinner(shouldBlockUI: true)
      })
      }, onCancel: {
        Toast.current.hide()
    })
    return view
  }
  
  private func constructDopracToast() -> DopracToast {
    let view = DopracToast()
    view.update(onConfirm: { type in
      Toast.current.hide({ [weak self] in
        guard let self = self else { return }
        self.viewModel.doprac(type: type)
        self.showSpinner(shouldBlockUI: true)
      })
      }, needsLayout: {
        Toast.current.layoutVertically()
    }, onCancel: {
        Toast.current.hide()
    })
    return view
  }
  
  private func constructRemoteToast() -> RemoteToast {
    let view = RemoteToast()
    view.update(onConfirm: { type in
      Toast.current.hide({ [weak self] in
        guard let self = self else { return }
        self.viewModel.remote(type: type)
        self.showSpinner(shouldBlockUI: true)
      })
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
    view.update(onConfirm: { type in
      Toast.current.hide({ [weak self] in
        guard let self = self else { return }
        self.viewModel.late(type: type)
        self.showSpinner(shouldBlockUI: true)
      })
      }, needsLayout: {
        Toast.current.layoutVertically()
    }, onCancel: {
      Toast.current.hide()
    })
    return view
  }
  
  func didSelectCell(action: ActionType) {
    print("did select action \(action)")
    switch action {
    case .late:
      lateToast?.refreshView()
      guard let toast = lateToast else { return }
      Toast.current.hide {
        Toast.current.show(toast)
      }
    case .remote:
      remoteToast?.refreshView()
      guard let toast = remoteToast else { return }
      Toast.current.hide {
        Toast.current.show(toast)
      }
      
    case .doprac:
      dopracToast?.refreshView()
      guard let toast = dopracToast else { return }
      Toast.current.hide {
        Toast.current.show(toast)
      }
      
    case .pochav:
      guard let toast = pochavToast else { return }
      Toast.current.hide {
        Toast.current.show(toast)
      }
    case .other:
      viewModel.openSlackForBot()
    }
    print("action called")
  }
}
