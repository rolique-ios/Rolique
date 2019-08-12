//
//  LoginViewController.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import UIKit
import SnapKit
import Utils
import SafariServices

private struct Constants {
  static var logoSize: CGSize { return CGSize(width: 150, height: 150) }
  static var edgeInsets: UIEdgeInsets { return UIEdgeInsets(top: 100, left: 8, bottom: 40, right: 8) }
  static var slackButtonSize: CGSize { return CGSize(width: 200, height: 100) }
  static var slackButtonBottom: CGFloat { return 16 }
  static var logoCenterYOffset: CGFloat { return 64 }
}

final class LoginViewController<T: LoginViewModel>: ViewController<T> {
  private lazy var slackButton = UIButton()
  private lazy var logoImageView = UIImageView()

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureConstraints()
    configureUI()
    configureBinding()

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  // MARK: - Actions
  @objc func loginTouchUpInside(sender: UIButton) {
    viewModel.login()
  }
}

// MARK: - Private
private extension LoginViewController {
  func configureUI() {
    view.backgroundColor = Colors.Login.backgroundColor
    
    slackButton.setImage(Images.Login.slackButton, for: .normal)
    slackButton.imageView?.contentMode = .scaleAspectFit
    slackButton.addTarget(self, action: #selector(loginTouchUpInside(sender:)), for: .touchUpInside)
    
    logoImageView.contentMode = .scaleAspectFit
    logoImageView.image = Images.Login.fullLogo
  }
  
  func configureBinding() {
    self.viewModel.onError = { [weak self] error in
      guard let self = self else { return }
      
      Spitter.showOkAlert(error, title: Strings.General.appName, viewController: self)
    }
  }
  
  func configureConstraints() {
    [slackButton, logoImageView].forEach(self.view.addSubviewAndDisableMaskTranslate)
    
    slackButton.snp.makeConstraints { maker in
      maker.size.equalTo(Constants.slackButtonSize)
      maker.centerX.equalToSuperview()
      maker.bottom.equalToSuperview().offset(-Constants.slackButtonBottom)
    }
    
    logoImageView.snp.makeConstraints { maker in
      maker.centerX.equalToSuperview()
      maker.centerY.equalToSuperview().offset(-Constants.logoCenterYOffset)
      maker.size.equalTo(Constants.logoSize)
    }
  }
}
