//
//  ColleaguesDetailViewController.swift
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

final class ColleaguesDetailViewController<T: ColleaguesDetailViewModel>: ViewController<T>, UIScrollViewDelegate {
  private lazy var tableView = UITableView()
  private var dataSource: ColleaguesDetailDataSource!
  private var panGR: UIPanGestureRecognizer!
  private lazy var headerView = configureHeaderView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureTableView()
    configureGesture()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.prefersLargeTitles = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.hero.navigationAnimationType = .pageOut(direction: .right)
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
    
    dataSource = ColleaguesDetailDataSource(tableView: tableView, user: viewModel.user)
    dataSource.onScroll = { [weak self] in
      self?.updateHeaderView()
    }
  }
  
  private func configureUI() {
    title = viewModel.user.name
    view.backgroundColor = Colors.Colleagues.softWhite
  }
  
  private func configureHeaderView() -> UIView {
    let view = UIView(frame: CGRect(x: 0, y: -Constants.kTableHeaderHeight, width: tableView.bounds.width, height: Constants.kTableHeaderHeight))
    view.clipsToBounds = true
    var userImageView = UIImageView()
    let statusLabel = UILabel()
    let slackButton = UIButton()
    
    userImageView.contentMode = .scaleAspectFill
    userImageView.hero.id = viewModel.user.biggestImage.orEmpty
    URL(string: viewModel.user.biggestImage.orEmpty).map(userImageView.setImage(with: ))
    view.addSubview(userImageView)
    
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
    
    slackButton.setImage(Images.Profile.slackLogo, for: .normal)
    slackButton.imageEdgeInsets = Constants.slackButtonImageInset
    slackButton.backgroundColor = .white
    slackButton.layer.cornerRadius = Constants.slackButtonSize / 2
    slackButton.layer.shadowColor = UIColor.black.cgColor
    slackButton.layer.shadowRadius = 6.0
    slackButton.layer.shadowOffset = CGSize(width: 0, height: 7)
    slackButton.layer.shadowOpacity = 0.1
    slackButton.addTarget(self, action: #selector(ColleaguesDetailViewController.didSelectSlackButton), for: .touchUpInside)
    
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
    viewModel.openSlack()
  }
}

