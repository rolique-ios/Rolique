//
//  ProfileDetailViewController.swift
//  Rolique
//
//  Created by Maksym Ivanyk on 9/18/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import Foundation
import Hero
import Utils

private struct Constants {
  static var kTableHeaderHeight: CGFloat { return 300.0 }
  static var defaultOffset: CGFloat { return 10.0 }
  static var tableViewContentInset: UIEdgeInsets { return UIEdgeInsets(top: Constants.kTableHeaderHeight, left: 0, bottom: 0, right: 0) }
  static var tableViewContentOffset: CGPoint { return CGPoint(x: 0, y: -Constants.kTableHeaderHeight) }
  static var slackButtonSize: CGFloat { return 50.0 }
  static var slackButtonImageInset: UIEdgeInsets { return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) }
}

protocol ProfileDetailViewControllerDelegate: class {
  func sendEmail(_ emails: [String])
}

final class ProfileDetailViewController<T: ProfileDetailViewModel>: ViewController<T> {
  private lazy var tableView = UITableView()
  private lazy var headerView = configureHeaderView()
  private var dataSource: ProfileDetailDataSource!
  private var panGR: UIPanGestureRecognizer!
  weak var delegate: ProfileDetailViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureTableView()
    configureGesture()
    configureBindings()
    NotificationCenter.default.addObserver(self, selector: #selector(ProfileDetailViewController.keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(ProfileDetailViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureNavigationBar()
    self.dataSource.updateClearCacheButtonTitle()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.hero.navigationAnimationType = .pageOut(direction: .right)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true)
  }
  
  private func configureNavigationBar() {
    navigationController?.navigationBar.prefersLargeTitles = false
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigationController?.navigationBar.titleTextAttributes = attributes
    navigationController?.navigationBar.largeTitleTextAttributes = attributes
    navigationController?.navigationBar.barTintColor = Colors.Login.backgroundColor
    navigationController?.navigationBar.tintColor = .white
  }
  
  override var previewActionItems: [UIPreviewActionItem] {
    let slackAction = UIPreviewAction(title: Strings.Profile.openSlack, style: .default, handler: { [weak self] (action, controller) in
      guard let self = self else { return }
      self.openSlack(with: self.viewModel.user.id)
    })
    var actions = [slackAction]
    let phone = viewModel.user.slackProfile.phone.replacingOccurrences(of: " ", with: "")
    if !phone.isEmpty {
      let callAction = UIPreviewAction(title: Strings.Profile.call, style: .default, handler: { [weak self] (action, controller) in
        guard let self = self else { return }
        self.call(to: phone)
      })
      actions.append(callAction)
    }
    let email = viewModel.user.slackProfile.email.orEmpty
    if !email.isEmpty {
      let emailAction = UIPreviewAction(title: Strings.Profile.sendEmail, style: .default, handler: { [weak self] (action, controller) in
        guard let self = self else { return }
        self.delegate?.sendEmail([email])
      })
      actions.append(emailAction)
    }
    let skype = viewModel.user.slackProfile.skype.orEmpty
    if !skype.isEmpty {
      let skypeAction = UIPreviewAction(title: Strings.Profile.openSkype, style: .default, handler: { [weak self] (action, controller) in
        guard let self = self else { return }
        self.openSkype()
      })
      actions.append(skypeAction)
    }
    return actions
  }
  
  private func configureConstraints() {
    [tableView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    
    tableView.snp.makeConstraints { maker in
      maker.top.equalTo(self.view.safeAreaLayoutGuide)
      maker.leading.equalTo(self.view.safeAreaLayoutGuide)
      maker.trailing.equalTo(self.view.safeAreaLayoutGuide)
      maker.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
  
  private func configureTableView() {
    tableView.separatorStyle = .none
    tableView.backgroundColor = .clear
    tableView.keyboardDismissMode = .interactive
    tableView.addSubview(headerView)
    tableView.contentInset = Constants.tableViewContentInset
    tableView.contentOffset = Constants.tableViewContentOffset
    
    dataSource = ProfileDetailDataSource(tableView: tableView, user: viewModel.user)
  }
  
  private func configureUI() {
    navigationItem.title = viewModel.user.name
    view.backgroundColor = Colors.Colleagues.softWhite
  }
  
  private func configureBindings() {
    dataSource.onScroll = { [weak self] in
      self?.updateHeaderView()
    }
    dataSource.copyString = { [weak self] string in
      self?.copyString(string)
    }
    dataSource.call = { [weak self] string in
      self?.call(to: string)
    }
    dataSource.sendEmail = { [weak self] strings in
      self?.sendEmail(to: strings)
    }
    dataSource.openSkype = { [weak self] in
      self?.openSkype()
    }
    dataSource.clearCache = { [weak self] in
      self?.viewModel.clearCache()
    }
    dataSource.logOut = { [weak self] in
      Spitter.showConfirmation(Strings.Profile.logOutQuestion, message: Strings.Profile.logOutMessage, owner: self) { [weak self] in
        self?.viewModel.logOut()
      }
    }
    viewModel.onLogOut = {
      let window = (UIApplication.shared.delegate as? AppDelegate)?.window
      window?.rootViewController = Router.getStartViewController()
      window?.makeKeyAndVisible()
    }
    
    viewModel.onClearCache = { [weak self] in
      self?.dataSource.updateClearCacheButtonTitle()
    }
  }
  
  private func configureHeaderView() -> UIView {
    let view = UIView(frame: CGRect(x: 0, y: -Constants.kTableHeaderHeight, width: self.view.bounds.width, height: Constants.kTableHeaderHeight))
    view.clipsToBounds = true
    var userImageView = UIImageView()
    
    userImageView.isUserInteractionEnabled = true
    userImageView.contentMode = .scaleAspectFill
    userImageView.hero.id = viewModel.user.biggestImage.orEmpty
    URL(string: viewModel.user.biggestImage.orEmpty).map(userImageView.setImage(with: ))
    [userImageView].forEach(view.addSubviewAndDisableMaskTranslate)
    
    let statusLabel = UILabel()
    statusLabel.font = .systemFont(ofSize: 20.0)
    statusLabel.textColor = .orange
    statusLabel.layer.borderWidth = 1.0
    statusLabel.layer.borderColor = UIColor.orange.cgColor
    statusLabel.layer.cornerRadius = 4
    let statusIsEmpty = viewModel.user.todayStatus.orEmpty.isEmpty
    statusLabel.isHidden = statusIsEmpty
    statusLabel.text = statusIsEmpty ? nil : " " + viewModel.user.todayStatus.orEmpty + " "
    
    let blur = UIBlurEffect(style: .extraLight)
    let blurView = UIVisualEffectView(effect: blur)
    blurView.layer.cornerRadius = 4
    blurView.clipsToBounds = true
    
    let slackButton = UIButton()
    slackButton.setImage(Images.Profile.slackLogo, for: .normal)
    slackButton.imageEdgeInsets = Constants.slackButtonImageInset
    slackButton.backgroundColor = .white
    slackButton.layer.cornerRadius = Constants.slackButtonSize / 2
    slackButton.addShadow()
    slackButton.addTarget(self, action: #selector(ProfileDetailViewController.didSelectSlackButton(sender:)), for: .touchUpInside)
    
    [blurView, statusLabel, slackButton].forEach(userImageView.addSubviewAndDisableMaskTranslate)
    
    userImageView.snp.makeConstraints { maker in
      maker.edges.equalToSuperview()
    }
    slackButton.snp.makeConstraints { maker in
      maker.bottom.equalToSuperview().offset(-Constants.defaultOffset)
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
      maker.size.equalTo(Constants.slackButtonSize)
    }
    blurView.snp.makeConstraints { maker in
      maker.edges.equalTo(statusLabel)
    }
    statusLabel.snp.makeConstraints { maker in
      maker.centerY.equalTo(slackButton)
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
    }
    
    return view
  }
  
  private func updateHeaderView() {
    var headerRect = CGRect(x: 0, y: -Constants.kTableHeaderHeight, width: tableView.bounds.width, height: Constants.kTableHeaderHeight)
    if tableView.contentOffset.y < -Constants.kTableHeaderHeight {
      headerRect.origin.y = tableView.contentOffset.y
      headerRect.size.height = -tableView.contentOffset.y
    }
    headerView.frame = headerRect
  }
  
  private func configureGesture() {
    panGR = UIPanGestureRecognizer(target: self,
                                   action: #selector(handlePan(gestureRecognizer:)))
    view.addGestureRecognizer(panGR)
  }
  
  @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
    let translation = panGR.translation(in: nil)
    let progress = translation.x / 2 / view.bounds.width
    
    switch panGR.state {
    case .began:
      hero.dismissViewController()
    case .changed:
      Hero.shared.update(progress)
    default:
      if progress + panGR.velocity(in: nil).x / view.bounds.width > 0.3 {
        Hero.shared.finish()
      } else {
        Hero.shared.cancel()
      }
    }
  }
  
  @objc func didSelectSlackButton(sender: UIButton) {
    self.openSlack(with: viewModel.user.id)
  }
  
  private func copyString(_ str: String) {
    Spitter.showWord(word: Strings.Profile.copied, completion: {})
    UIPasteboard.general.string = str
  }
  
  @objc func keyboardWillShow(_ notification:Notification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      let insets = UIEdgeInsets(top: Constants.kTableHeaderHeight, left: 0, bottom: keyboardSize.height, right: 0)
      tableView.contentInset = insets
      tableView.scrollIndicatorInsets = insets
      tableView.scrollToRow(at: IndexPath(row: 0, section: ProfileDetailDataSource.Section.additionalInfo.rawValue), at: .bottom, animated: true)
    }
  }
  
  @objc func keyboardWillHide(_ notification:Notification) {
    if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
      let insets = UIEdgeInsets(top: Constants.kTableHeaderHeight, left: 0, bottom: 0, right: 0)
      tableView.contentInset = insets
      tableView.scrollIndicatorInsets = insets
    }
  }
}

// MARK: - Mixins

extension ProfileDetailViewController: Callable, Mailable, Slackable, Skypable {}