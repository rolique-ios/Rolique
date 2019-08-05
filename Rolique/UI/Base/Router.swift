//
//  Router.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Model
import Utils

public final class Router {
  static func getLoginViewController() -> LoginViewController<LoginViewModelImpl> {
    return LoginViewController(viewModel: LoginViewModelImpl(loginManager: LoginManagerImpl()))
  }
  
  static func getProfileViewController() -> ProfileViewController<ProfileViewModelImpl> {
    return ProfileViewController(viewModel: ProfileViewModelImpl())
  }
  
  static func getTabBarController() -> UITabBarController {
    let tabbar =  BaseTabBarController()
    let profile = UINavigationController(rootViewController: getProfileViewController())
    profile.tabBarItem = UITabBarItem(title: Strings.TabBar.profile, image: Images.TabBar.profile, tag: 0)
    tabbar.viewControllers = [profile]
    
    return tabbar
  }
  
  public static func getStartViewController() -> UINavigationController {
    let root = Router.getLoginViewController()
    let navigationController = UINavigationController(rootViewController: root)
  
    return navigationController
  }
}
