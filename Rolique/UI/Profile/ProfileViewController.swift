//
//  ProfileViewController.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import IgyToast

final class ProfileViewController<T: ProfileViewModel>: ViewController<T> {
  private struct Constants {
    static var defaultOffset: CGFloat { return 20.0 }
    static var littleOffset: CGFloat { return 10.0 }
    static var phoneImageSize: CGFloat { return 100.0 }
    static var logOutButtonWidth: CGFloat { return 110.0 }
    static var logOutButtonHeight: CGFloat { return 50.0 }
  }
  private lazy var containerView = ShadowView()
  private lazy var profileImage = UIImageView()
  private lazy var userNameLabel = UILabel()
  private lazy var titleLabel = UILabel()
  private lazy var logOutButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureBinding()
    viewModel.getUser()
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureNavigationBar()
  }
  
  private func configureNavigationBar() {
    navigationController?.navigationBar.prefersLargeTitles = true
    let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigationController?.navigationBar.titleTextAttributes = attributes
    navigationController?.navigationBar.largeTitleTextAttributes = attributes
    navigationController?.navigationBar.barTintColor = Colors.Login.backgroundColor
    navigationController?.navigationBar.tintColor = UIColor.white
  }
  
  private func configureConstraints() {
    [containerView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    [profileImage, userNameLabel, titleLabel, logOutButton ].forEach(self.containerView.addSubviewAndDisableMaskTranslate)
    containerView.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
    }
    profileImage.snp.makeConstraints { maker in
      maker.centerX.equalToSuperview()
      maker.top.equalToSuperview().offset(Constants.defaultOffset)
      maker.size.equalTo(Constants.phoneImageSize)
    }
    userNameLabel.snp.makeConstraints { maker in
      maker.top.equalTo(profileImage.snp.bottom).offset(Constants.defaultOffset)
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
    }
    titleLabel.snp.makeConstraints { maker in
      maker.top.equalTo(userNameLabel.snp.bottom).offset(Constants.littleOffset)
      maker.leading.equalToSuperview().offset(Constants.defaultOffset)
      maker.trailing.equalToSuperview().offset(-Constants.defaultOffset)
    }
    logOutButton.snp.makeConstraints { maker in
      maker.centerX.equalToSuperview()
      maker.top.equalTo(titleLabel.snp.bottom).offset(Constants.defaultOffset)
      maker.width.equalTo(Constants.logOutButtonWidth)
      maker.height.equalTo(Constants.logOutButtonHeight)
      maker.bottom.equalToSuperview().offset(-Constants.defaultOffset)
    }
  }
  
  private func configureUI() {
    title = Strings.TabBar.profile
    
    self.view.backgroundColor = Colors.Colleagues.softWhite
    
    containerView.backgroundColor = .white
    containerView.isHidden = true
    
    userNameLabel.textAlignment = .center
    
    titleLabel.textAlignment = .center
    titleLabel.textColor = UIColor.lightGray
    titleLabel.font = UIFont.italicSystemFont(ofSize: 14.0)
    
    profileImage.layer.cornerRadius = Constants.phoneImageSize / 2
    profileImage.clipsToBounds = true
    configureButton()
  }
  
  private func configureButton() {
    logOutButton.setTitle(Strings.Profile.logOutTitle, for: UIControl.State.normal)
    logOutButton.setTitleColor(UIColor.red, for: .normal)
    logOutButton.layer.cornerRadius = 5.0
    logOutButton.layer.borderWidth = 2.0
    logOutButton.layer.borderColor = UIColor.red.cgColor
    logOutButton.addTarget(self, action: #selector(buttonTap(_:)), for: UIControl.Event.touchUpInside)
  }
  
  private func configureBinding() {
    viewModel.onUserSuccess = { [weak self] user in
      guard let self = self else { return }
      
      self.userNameLabel.text = user.name
      self.titleLabel.text = user.slackProfile.title
      
      if let biggestImage = user.biggestImage, let url = URL(string: biggestImage) {
        self.profileImage.setImage(with: url)
      }
      
      self.containerView.isHidden = false
    }
    
    viewModel.onError = { [weak self] error in
      guard let self = self else { return }
      Spitter.showOkAlert(error, viewController: self)
    }
    
    viewModel.onLogOut = {
      let window = (UIApplication.shared.delegate as? AppDelegate)?.window
      window?.rootViewController = Router.getStartViewController()
      window?.makeKeyAndVisible()
    }
  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    Toast.current.layoutVertically()
  }
  
  @objc func buttonTap(_ button: UIButton) {
    Spitter.showConfirmation(Strings.Profile.logOutTitle + "?", message: Strings.Profile.logOutMessage, owner: self) {[weak self] in
      self?.viewModel.logOut()
    }
  }
}

