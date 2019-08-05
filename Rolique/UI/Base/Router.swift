//
//  Router.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Model

public final class Router {
  public static func getLoginViewController() -> LoginViewController<LoginViewModelImpl> {
    return LoginViewController(viewModel: LoginViewModelImpl(loginManager: LoginManagerImpl()))
  }
  
  public static func getStartViewController() -> UINavigationController {
    let root = Router.getLoginViewController()
    let navigationController = UINavigationController(rootViewController: root)
  
    return navigationController
  }
}
