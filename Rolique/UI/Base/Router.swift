//
//  Router.swift
//  UI
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import Utils

public final class Router {
  static func getLoginViewController() -> LoginViewController<LoginViewModelImpl> {
    return LoginViewController(viewModel: LoginViewModelImpl(loginManager: LoginManagerImpl()))
  }
  
  static func getProfileViewController() -> ProfileViewController<ProfileViewModelImpl> {
    return ProfileViewController(viewModel: ProfileViewModelImpl())
  }
  
  static func getColleaguesViewController() -> ColleaguesViewController<ColleaguesViewModelImpl> {
    return ColleaguesViewController(viewModel: ColleaguesViewModelImpl(userManager: UserManagerImpl()))
  }
  
  static func getTabBarController() -> UITabBarController {
    let tabbar = BaseTabBarController()
    let colleagues = UINavigationController(rootViewController: getColleaguesViewController())
    colleagues.tabBarItem = UITabBarItem(title: "", image: Images.TabBar.stats, tag: 0)
    let profile = UINavigationController(rootViewController: getProfileViewController())
    profile.tabBarItem = UITabBarItem(title: Strings.TabBar.profile, image: Images.TabBar.profile, tag: 1)
    tabbar.viewControllers = [colleagues, profile]
    
    return tabbar
  }
  
  public static func getStartViewController() -> UINavigationController {
    let root = UserDefaultsManager.shared.userId == nil
      ? Router.getLoginViewController()
      : self.getTabBarController()
    
    let navigationController = UINavigationController(rootViewController: root)
  
    return navigationController
  }
}
