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
import Model
import SafariServices

private struct Constants {
  static var logoSize: CGSize { return CGSize(width: 150, height: 150) }
  static var edgeInsets: UIEdgeInsets { return UIEdgeInsets(top: 100, left: 8, bottom: 40, right: 8) }
  static var slackButtonSize: CGSize { return CGSize(width: 200, height: 150) }
}

public final class LoginViewController<T: LoginViewModel>: ViewController<T> {
  var authSession: SFAuthenticationSession?
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.viewModel.login()
  }
}

// MARK: - Private
private extension LoginViewController {
  func configureUI() {
    view.backgroundColor = Colors.Login.backgroundColor
  }
}
