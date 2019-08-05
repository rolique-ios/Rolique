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
    login()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
}

// MARK: - Private
private extension LoginViewController {
  func configureUI() {
    view.backgroundColor = Colors.Login.backgroundColor
  }
  
  func login() {
    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) { [unowned self] in
      let lm = LoginManagerImpl()
      guard let url = lm.getLoginURL() else { return }
      self.authSession = SFAuthenticationSession(url: url, callbackURLScheme: "rolique", completionHandler: { (redirectUrl, error) in
        if error == nil {
          guard let redirectUrl = redirectUrl else { print("no redirect url"); return }
          lm.login(redirectUrl: redirectUrl, result: { result in
            print(result)
          })
        } else {
          print(error)
        }
        
      })
      self.authSession?.start()
    }
  }
}
