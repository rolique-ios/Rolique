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
      maker.leading.equalToSuperview().offset(20)
      maker.trailing.equalToSuperview().offset(-20)
    }
    profileImage.snp.makeConstraints { maker in
      maker.centerX.equalToSuperview()
      maker.top.equalToSuperview().offset(20)
      maker.height.equalTo(60)
      maker.width.equalTo(60)
    }
    userNameLabel.snp.makeConstraints { maker in
      maker.top.equalTo(profileImage.snp.bottom).offset(20)
      maker.leading.equalToSuperview().offset(20)
      maker.trailing.equalToSuperview().offset(-20)
    }
    titleLabel.snp.makeConstraints { maker in
      maker.top.equalTo(userNameLabel.snp.bottom).offset(10)
      maker.leading.equalToSuperview().offset(20)
      maker.trailing.equalToSuperview().offset(-20)
    }
    logOutButton.snp.makeConstraints { maker in
      maker.centerX.equalToSuperview()
      maker.top.equalTo(titleLabel.snp.bottom).offset(20)
      maker.width.equalTo(110)
      maker.height.equalTo(50)
      maker.bottom.equalToSuperview().offset(-20)
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
    configureButton()
  }
  
  private func configureButton() {
    logOutButton.setTitle("Log out", for: UIControl.State.normal)
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
        DispatchQueue.global(qos: .userInteractive).async {
          URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
              DispatchQueue.main.async { [weak self] in
                self?.profileImage.image = image
              }
            }
          }).resume()
        }
      }
      
      self.containerView.isHidden = false
    }
    
    viewModel.onError = { error in
      
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
    Spitter.showConfirmation("Log out?", message: "you sure?", owner: self) {[weak self] in
      self?.viewModel.logOut()
    }
  }
}

