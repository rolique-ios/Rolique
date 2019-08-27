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
    let userService = UserServiceImpl(userManager: UserManagerImpl(), coreDataManager: CoreDataManager<User>())
    return ColleaguesViewController(viewModel: ColleaguesViewModelImpl(userService: userService))
  }
  
  static func getActionsViewController() -> ActionsViewController<ActionsViewModelImpl> {
    return ActionsViewController(viewModel: ActionsViewModelImpl(actionManager: ActionMangerImpl()))
  }
  
  static func getTabBarController() -> UITabBarController {
    let tabbar = BaseTabBarController()
    let colleagues = UINavigationController(rootViewController: getColleaguesViewController())
    colleagues.tabBarItem = UITabBarItem(title: Strings.NavigationTitle.colleagues, image: Images.TabBar.stats, tag: 0)
    let actions = UINavigationController(rootViewController: getActionsViewController())
    actions.tabBarItem = UITabBarItem(title: Strings.NavigationTitle.actions, image: Images.TabBar.actions, tag: 1)
    let profile = UINavigationController(rootViewController: getProfileViewController())
    profile.tabBarItem = UITabBarItem(title: Strings.TabBar.profile, image: Images.TabBar.profile, tag: 2)
    tabbar.viewControllers = [colleagues, actions, profile]
    
    return tabbar
  }
  
  public static func getStartViewController() -> UIViewController {
    if UserDefaultsManager.shared.userId == nil {
      return UINavigationController(rootViewController: Router.getLoginViewController())
    } else {
      return self.getTabBarController()
    }
  }
}
