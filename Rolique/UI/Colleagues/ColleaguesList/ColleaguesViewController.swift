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

enum ColleaguesUIMode {
  case regular, selectParticipant
}

private struct Constants {
  static var headerHeight: CGFloat { return 50.0 }
  static var delay: DispatchTime { return .now() + 0.4 }
}

final class ColleaguesViewController<T: ColleaguesViewModel>: ViewController<T>, UISearchBarDelegate, UINavigationControllerDelegate, UIViewControllerPreviewingDelegate, ProfileDetailViewControllerDelegate {
  private lazy var tableView = UITableView()
  private lazy var tableViewHeader = UIView()
  private lazy var searchBar = UISearchBar()
  private lazy var recordTypeToast = constructRecordTypeToast()
  private lazy var recordTypeToastHeader = constructRecordTypeToastHeader()
  private var dataSource: ColleaguesDataSource?
  private lazy var contextMenuConfigHandler = UIContextMenuConfigurationHandler()
  var selectedParticipant: User?
  var onPop: ((User?) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureTableView()
    configureBinding()
    
    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: tableView)
    }
    self.navigationController?.addCustomTransitioning()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureNavigationBar()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    if self.isMovingFromParent {
      onPop?(selectedParticipant)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    Toast.current.layoutVertically()
  }
  
  override func updateColors() {
    if let textfield = searchBar.value(forKey: "searchField") as? UITextField,
      let backgroundview = textfield.subviews.first {
      setShadow(to: backgroundview)
    }
    tableView.reloadData()
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
    navigationController?.setAppearance(with: attributes, backgroundColor: Colors.Login.backgroundColor)
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
    self.view.backgroundColor = Colors.mainBackgroundColor
    
    searchBar.delegate = self
    searchBar.returnKeyType = .done
    searchBar.barTintColor = .clear
    searchBar.backgroundColor = .clear
    searchBar.isTranslucent = true
    searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    if let textfield = searchBar.value(forKey: "searchField") as? UITextField,
      let backgroundview = textfield.subviews.first {
      if #available(iOS 13.0, *) {
        searchBar.searchTextField.backgroundColor = Colors.secondaryBackgroundColor
      } else {
        backgroundview.backgroundColor = Colors.secondaryBackgroundColor
      }
      backgroundview.layer.cornerRadius = 10.0
      setShadow(to: backgroundview)
    }
    
    Toast.current.backgroundColor = Colors.secondaryBackgroundColor
  }
  
  private func configureTableView() {
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.keyboardDismissMode = .interactive
    dataSource = ColleaguesDataSource(tableView: tableView, data: viewModel.users, contextMenuConfigHandler: contextMenuConfigHandler)
    dataSource?.onUserTap = onUserSelect
    dataSource?.onPhoneTap = onPhoneSelect
  }
  
  private func configureBinding() {
    viewModel.onRefreshList = { [weak self] users in
      guard let self = self else { return }
      
      self.dataSource?.update(dataSource: users)
      self.dataSource?.hideRefreshControl()
    }
    
    viewModel.onError = { [weak self] segment in
      guard let self = self else { return }
      self.dataSource?.hideRefreshControl()
    }
    
    contextMenuConfigHandler.previewProvider = { [weak self] (indexPath, location) in
      guard let self = self,
        let indexPath = indexPath else { return nil }
      let contextMenuContentPreviewProvider = { () -> ProfileDetailViewController<ProfileDetailViewModelImpl> in
        return self.previewVC(user: self.viewModel.getUsersByCurrentListType()[indexPath.row])
      }
      return contextMenuContentPreviewProvider
    }
    
    contextMenuConfigHandler.provideMenu = { [weak self] indexPath in
      var actions = [MenuAction]()
      if let self = self, let indexPath = indexPath {
        let user = self.viewModel.getUsersByCurrentListType()[indexPath.row]
        let slackId = user.id
        let slackAction = MenuAction(title: Strings.Profile.openSlack, image: nil, handler: {
          DispatchQueue.main.asyncAfter(deadline: Constants.delay) { [weak self] in
            self?.openSlack(with: slackId)
          }
        })
        actions.append(slackAction)
        let phone = user.slackProfile.phone
        if !phone.isEmpty {
          let callAction = MenuAction(title: Strings.Profile.call, image: nil, handler: { 
            DispatchQueue.main.asyncAfter(deadline: Constants.delay) { [weak self] in
              self?.call(to: phone)
            }
          })
          actions.append(callAction)
        }
        let email = user.slackProfile.email.orEmpty
        if !email.isEmpty {
          let emailAction = MenuAction(title: Strings.Profile.sendEmail, image: nil, handler: { [weak self] in
            self?.sendEmail(to: [email])
          })
          actions.append(emailAction)
        }
        let skype = user.slackProfile.skype.orEmpty
        if !skype.isEmpty {
          let skypeAction = MenuAction(title: Strings.Profile.openSkype, image: nil, handler: {
            DispatchQueue.main.asyncAfter(deadline: Constants.delay) { [weak self] in
              self?.openSkype()
            }
          })
          actions.append(skypeAction)
        }
      }
      return Menu(title: "", actions: actions)
    }
    
    contextMenuConfigHandler.willEndDisplayContextMenu = { [weak self] previewVC in
      guard let self = self, let previewVC = previewVC else { return }
      self.navigationController?.pushViewController(previewVC, animated: true)
    }
  }
  
  @objc func refresh() {
    viewModel.refresh()
  }
  
  @objc func didSelectSortButton() {
    Toast.current.show(recordTypeToast, header: recordTypeToastHeader)
  }
  
  func onUserSelect(_ user: User) {
    view.endEditing(true)
    switch viewModel.mode {
    case .regular:
      Spitter.tap(.pop)
      navigationController?.pushViewController(Router.getProfileDetailViewController(user: user), animated: true)
    case .selectParticipant:
      selectedParticipant = user
      navigationController?.popViewController(animated: true)
    }
  }
  
  func onPhoneSelect(_ phoneNumer: String) {
    self.call(to: phoneNumer)
  }
  
  private func constructRecordTypeToastHeader() -> UIView {
    let view = UIView()
    view.backgroundColor = Colors.secondaryBackgroundColor
    view.translatesAutoresizingMaskIntoConstraints = false
    view.snp.makeConstraints { maker in
      maker.height.equalTo(Constants.headerHeight)
    }
    
    let label = UILabel()
    label.textColor = Colors.mainTextColor
    label.text = Strings.Collegues.showOptions
    label.font = .preferredFont(forTextStyle: .title2)
    label.textAlignment = .center
    view.addSubview(label)
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
                  self?.viewModel.updateRecordType(recordType)
    })
    return view
  }
  
  private func setShadow(to view: UIView) {
    view.layer.shadowColor = Colors.shadowColor
    view.layer.shadowRadius = 4.0
    view.layer.shadowOffset = CGSize(width: 0, height: 7)
    view.layer.shadowOpacity = 0.1
  }
  
  private func previewVC(user: User) -> ProfileDetailViewController<ProfileDetailViewModelImpl> {
    let popVC = Router.getProfileDetailViewController(user: user)
    popVC.delegate = self
    return popVC
  }
  
  // MARK: - UISearchBarDelegate
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    viewModel.cancelSearch()
    searchBar.resignFirstResponder()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text == nil || searchBar.text == "" {
      viewModel.cancelSearch()
    } else {
      viewModel.searchUser(with: searchText)
    }
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
    previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
    let popVC = Router.getProfileDetailViewController(user: viewModel.getUsersByCurrentListType()[indexPath.row])
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

// MARK: - Mixins

extension ColleaguesViewController: Mailable, Slackable, Callable, Skypable {}
